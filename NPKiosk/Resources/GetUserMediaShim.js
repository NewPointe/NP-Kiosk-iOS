(() => {
    const hex = Array(256).fill(0).map((_, i) => i.toString(16).padStart(2, '0'));

    function generateGuid() {
        const b = new Uint8Array(16);
        window.crypto.getRandomValues(b);
        return hex[b[0]] + hex[b[1]] + hex[b[2]] + hex[b[3]] + '-' + hex[b[4]] + hex[b[5]] + '-' + hex[b[6] | 0x40] + hex[b[7]] + '-' + hex[b[8] | 0x80] + hex[b[9]] + '-' + hex[b[10]] + hex[b[11]] + hex[b[12]] + hex[b[13]] + hex[b[14]] + hex[b[15]]
    }

    class Deferred {
        constructor() {
            this.promise = new Promise((resolve, reject) => { this.resolve = resolve; this.reject = reject; });
        }
    }

    class CustomEventTarget {
        constructor() {
            this.listeners = new Map();
        }
        addEventListener(type, callback) {
            let stack = this.listeners.get(type);
            if (!stack) this.listeners.set(type, stack = new Set());
            stack.add(callback);
        }
        removeEventListener(type, callback) {
            const stack = this.listeners.get(type);
            if (stack) stack.delete(callback);
        }
        dispatchEvent(event) {
            const stack = this.listeners.get(event.type);
            if (stack) stack.forEach(item => item.call(this, event));
            return !event.defaultPrevented;
        }
    }

    class RpcClient extends CustomEventTarget {
        constructor() {
            super();
            this.callbacks = new Map();
            window.addEventListener('message', this._onWindowMessage.bind(this));
        }
        sendRequest(method, params) {
            const id = generateGuid();
            const callback = new Deferred();
            this.callbacks.set(id, callback);
            this._send({ id, method, params });
            return callback.promise;
        }
        sendNotification(method, params) {
            this._send({ method, params });
        }
        sendResult(id, result) {
            this._send({ id, result });
        }
        sendError(id, error) {
            this._send({ id, error });
        }
        _send(data) {
            window.webkit.messageHandlers.RpcClient.postMessage(JSON.stringify({ jsonrpc: "2.0", ...data }));
        }
        _onWindowMessage(event) {
            if (event.data && event.data.jsonrpc === "2.0") {
                if (event.data.method) {
                    this.dispatchEvent(new CustomEvent(event.data.method, { detail: event.data.params }));
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

    class MediaSession {
        constructor(signalingChannel) {
            this.id = generateGuid();
            this._deffered = new Deferred();
            this._started = false;

            this.peerConnection = new RTCPeerConnection({ iceServers: [] });
            this.peerConnection.onicecandidate = this._onLocalIceCandidate.bind(this);
            this.peerConnection.ontrack = this._ontrack.bind(this);

            this.signalingChannel = signalingChannel;
            this.signalingChannel.addEventListener("GetUserMediaShim.javascript.candidate", this._onRemoteIceCandidate.bind(this))

        }

        async start() {
            if (this._started) return this._deffered.promise;
            this._started = true;
            const offer = await this.signalingChannel.sendRequest("GetUserMediaShim.native.connectCamera", [this.id, "video"]);
            await this.peerConnection.setRemoteDescription(offer);
            const answer = await this.peerConnection.createAnswer();
            await this.peerConnection.setLocalDescription(answer);
            this.signalingChannel.sendNotification("GetUserMediaShim.native.answer", [this.id, answer]);
            return this._deffered.promise;
        }

        _onLocalIceCandidate(event) {
            if (event.candidate) {
                this.signalingChannel.sendRequest("GetUserMediaShim.native.candidate", [this.id, event.candidate]);
            }
        }

        _ontrack(event) {
            if (event.streams && event.streams[0]) {
                this._deffered.resolve(event.streams[0]);
            }
        }

        _onRemoteIceCandidate(event) {
            const [mediaSessionId, candidate] = event.detail;
            if (this.id = mediaSessionId) {
                this.peerConnection.addIceCandidate(new RTCIceCandidate(candidate));
            }
        }
    }
    
    let mediaSession = null;
    const rpcClient = new RpcClient();
    if (!window.navigator.mediaDevices) window.navigator.mediaDevices = {};
    window.navigator.mediaDevices.getUserMedia = (constraints) => {
        if (!constraints.audio && !constraints.video) {
            throw new TypeError("Failed to execute 'getUserMedia' on 'MediaDevices': At least one of audio and video must be requested");
        }
        if (constraints.audio) {
            throw new Error("Audio is not supported yet");
        }
        mediaSession = mediaSession || new MediaSession(rpcClient);
        return mediaSession.start();
    }

})();
