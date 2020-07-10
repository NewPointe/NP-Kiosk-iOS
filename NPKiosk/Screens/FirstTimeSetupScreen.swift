//
//  UrlEntryView.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 4/27/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI

struct FirstTimeSetupScreen: View {
    @EnvironmentObject var screenService: ScreenService
    @EnvironmentObject var settingsService: SettingsService
    @State private var kioskAddress: String = ""
    @State private var scanerMode: Bool = false
    
    @ViewBuilder
    var body: some View {
        if !scanerMode {
            VStack(spacing: 0) {
                Rectangle().fill(Color(hex: "#8bc540")).frame(height: 40.0)
                ZStack {
                    Rectangle().fill(Color(hex: "#fafafa"))
                    KeyboardHost {
                        VStack(alignment: .leading) {
                            Text("Kiosk Address").fontWeight(.semibold)
                            TextField("https://yourserver.com/kiosk", text: self.$kioskAddress)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .bsPadding(vertical: 10.0, horizontal: 15.0)
                                .bsColors(fg: "#000", bg: "#fff", border: "#ccc")
                                .onAppear {
                                    self.kioskAddress = self.settingsService.kioskAddress ?? ""
                            }
                            HStack {
                                Button("Save Settings") {
                                    self.saveUrl(url: self.kioskAddress)
                                }
                                .bsPadding(vertical: 10.0, horizontal: 15.0)
                                .bsColors(fg: "#fff", bg: "#8bc540", border: "#699431")
                                Spacer()
                                Button("Scan Code") {
                                    self.scanerMode = true
                                }
                                .bsPadding(vertical: 10.0, horizontal: 15.0)
                                .bsColors(fg: "#fff", bg: "#5bc0de", border: "#4694ab")
                            }
                            .padding(.vertical, 10.0)
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(Color(hex: "515151"))
                        .padding(.all)
                        .frame(maxWidth: 600)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
        else {
            CodeScannerView(codeTypes: [.qr]) { result in
                switch result {
                    case .success(let string):
                        self.saveUrl(url: string)
                    case .failure(_):
                        self.scanerMode = false
                }
            }
        }
    }
    
    func saveUrl(url: String) {
        self.settingsService.kioskAddress = url
        self.screenService.current = .kiosk
    }
}

struct FirstTimeSetupScreen_Previews: PreviewProvider {
    static var previews: some View {
        FirstTimeSetupScreen()
            .environmentObject(SettingsService())
            .environmentObject(ScreenService())
            .statusBar(hidden: true)
            .edgesIgnoringSafeArea(.all)
    }
}
