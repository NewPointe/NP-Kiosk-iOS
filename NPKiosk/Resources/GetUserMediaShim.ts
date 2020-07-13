
type JsonPrimitive = string | number | boolean | null;
type JsonValue = JsonPrimitive | JsonArray | JsonObject;
type JsonArray = Array<JsonValue>;
type JsonObject = { [key: string]: JsonValue };

interface RpcNotification {
    jsonrpc: "2.0";
    method: string;
    params?: JsonArray | JsonObject;
}

interface RpcRequest extends RpcNotification {
    id: string | number | null;
}

interface RpcSuccessResponse {
    jsonrpc: "2.0";
    result: JsonValue;
    id: string | number | null;
}

interface RpcErrorResponse {
    jsonrpc: "2.0";
    error: RpcError;
    id: string | number | null;
}

type RpcResponse = RpcSuccessResponse | RpcErrorResponse

interface RpcError {
    code: number;
    message: string;
    data?: JsonValue;
}

interface Window {
    webkit: {
        messageHandlers: {
            RpcClient: {
                postMessage(message: JsonValue): void;
            }
        }
    }
}

interface StartSessionResponse { 
    sessionId: string;
    sessionDescription: RTCSessionDescriptionInit;
}

type Writeable<T> = { -readonly [P in keyof T]: T[P] };


(() => {

    // Hex conversion table
    const hex = Array(256).fill(0).map((_, i) => i.toString(16).padStart(2, '0'));

    /**
     * Generates a random (v4) GUID.
     */
    function generateGuid() {
        const b = new Uint8Array(16);
        window.crypto.getRandomValues(b);
        return hex[b[0]] + hex[b[1]] + hex[b[2]] + hex[b[3]] + '-' + hex[b[4]] + hex[b[5]] + '-' + hex[b[6] | 0x40] + hex[b[7]] + '-' + hex[b[8] | 0x80] + hex[b[9]] + '-' + hex[b[10]] + hex[b[11]] + hex[b[12]] + hex[b[13]] + hex[b[14]] + hex[b[15]]
    }

    /** A simple promise wrapper for outside resolution. */
    class Deferred<T> {
        /** The promise. */
        public promise: Promise<T>;

        /**
         * Resolves the Promise.
         * @param value Argument to be resolved by this Promise. Can also be a Promise or a thenable to resolve.
         */
        public resolve!: (value?: T | PromiseLike<T> | undefined) => void;

        /**
         * Rejects the Promise.
         * @param reason Reason why this Promise rejected.
         */
        public reject!: (reason?: any) => void;

        /** Creates a new Deferred */
        constructor() {
            // Create a new promise and save it's resolution functions.
            this.promise = new Promise<T>((resolve, reject) => { this.resolve = resolve; this.reject = reject; });
        }
    }

    type SimpleEventListener = (...args: any[]) => void;
    class SimpleEventHandler {
        private listeners = new Map<string, Set<SimpleEventListener>>();
        on(event: string, callback: SimpleEventListener): void {
            let stack = this.listeners.get(event);
            if (!stack) this.listeners.set(event, stack = new Set());
            stack.add(callback);
        }
        off(type: string, callback: EventListener): void {
            const stack = this.listeners.get(type);
            if (stack) stack.delete(callback);
        }
        trigger(event: string, ...args: any[]): void {
            const stack = this.listeners.get(event);
            if (stack) stack.forEach(item => item.apply(this, args));
        }
    }

    class RpcClient extends SimpleEventHandler {
        private callbacks = new Map();

        constructor() {
            super();
            window.addEventListener('message', this.onWindowMessage.bind(this));
        }

        async sendRequest<T>(method: string, params?: JsonArray | JsonObject): Promise<T> {
            const id = generateGuid();
            const callback = new Deferred<T>();
            this.callbacks.set(id, callback);
            this.send({ jsonrpc: "2.0", id, method, params });
            return callback.promise;
        }

        sendNotification(method: string, params?: JsonArray | JsonObject): void {
            this.send({ jsonrpc: "2.0", method, params });
        }

        sendResult(id: string | number | null, result: JsonValue) {
            this.send({ jsonrpc: "2.0", id, result });
        }

        sendError(id: string | number | null, error: RpcError) {
            this.send({ jsonrpc: "2.0", id, error });
        }

        private send(data: RpcNotification | RpcRequest | RpcResponse) {
            window.webkit.messageHandlers.RpcClient.postMessage(JSON.stringify(data));
        }

        private onWindowMessage(event: MessageEvent) {
            if (event.data && event.data.jsonrpc === "2.0") {
                if (event.data.method) {
                    this.trigger(event.data.method, event.data.params);
                }
                else if (event.data.id) {
                    const callback = this.callbacks.get(event.data.id);
                    if (callback) {
                        this.callbacks.delete(event.data.id);
                        if (event.data.result) callback.resolve(event.data.result);
                        else if (event.data.error) callback.reject(new Error(event.data.error.message));
                    }
                }
            }
        }
    }
    
    // The RPC client
    const rpcClient = new RpcClient();

    // Shim mediaDevices
    if (!window.navigator.mediaDevices) (window.navigator.mediaDevices as any) = {};

    // Shim getUserMedia
    window.navigator.mediaDevices.getUserMedia = async (constraints?: MediaStreamConstraints): Promise<MediaStream> => {
        // Check constraints
        if (!constraints || (!constraints.audio && !constraints.video)) {
            throw new TypeError("Failed to execute 'getUserMedia' on 'MediaDevices': At least one of audio and video must be requested");
        }

        // Create a deferred promise
        const deferred = new Deferred<MediaStream>()

        // Connect to native
        const { sessionId: mediaSessionId, sessionDescription: remoteDescription} = await rpcClient.sendRequest<StartSessionResponse>("GetUserMediaShim.native.connect", [generateGuid(), constraints as JsonObject]);
        
        // Start a new WebRTC connection
        const peerConnection = new RTCPeerConnection({ iceServers: [] });

        // Resolve once we get a track
        peerConnection.ontrack = (event: RTCTrackEvent) => {
            if (event.streams && event.streams[0]) {
                deferred.resolve(event.streams[0]);
            }
        }

        // Forward candidates to native
        peerConnection.onicecandidate = (event: RTCPeerConnectionIceEvent) => {
            if (event.candidate) {
                rpcClient.sendNotification("GetUserMediaShim.native.candidate", [mediaSessionId, event.candidate as unknown as JsonObject]);
            }
        }

        // Listen for candidates
        rpcClient.on("GetUserMediaShim.javascript.candidate", ([candidateMediaSessionId, candidate]: [string, RTCIceCandidateInit]) => {
            if (candidateMediaSessionId == mediaSessionId) {
                peerConnection.addIceCandidate(new RTCIceCandidate(candidate));
            }
        });

        // Set the remote description
        await peerConnection.setRemoteDescription(remoteDescription);

        // Get an answer
        const localDescription = await peerConnection.createAnswer();

        // Set the local description
        await peerConnection.setLocalDescription(localDescription);

        // Send the local description to the native side
        rpcClient.sendNotification("GetUserMediaShim.native.answer", [mediaSessionId, localDescription as JsonObject]);

        // Return the promise
        return deferred.promise;
    }

    // Shim getSupportedConstraints
    window.navigator.mediaDevices.getSupportedConstraints = (): MediaTrackSupportedConstraints => {
        return {
            aspectRatio: true,
            autoGainControl: false,
            channelCount: false,
            deviceId: true,
            echoCancellation: false,
            facingMode: true,
            frameRate: true,
            groupId: false,
            height: true,
            latency: false,
            noiseSuppression: false,
            resizeMode: false,
            sampleRate: false,
            sampleSize: false,
            width: true
        };
    }

})();
