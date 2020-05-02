//
//  UrlEntryView.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/27/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI

struct UrlEntryView: View {
    @Binding var currentAppScreen: AppScreen
    @State private var checkinUrl: String = SettingsService.kioskAddress
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color(hex: "#8bc540")).frame(height: 40.0)
            ZStack {
                Rectangle().fill(Color(hex: "#fafafa"))
                KeyboardHost {
                    VStack(alignment: .leading) {
                        Text("Kiosk Address").fontWeight(.semibold)
                        TextField("https://yourserver.com/kiosk", text: self.$checkinUrl)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .bsPadding(vertical: 10.0, horizontal: 15.0)
                            .bsColors(fg: "#000", bg: "#fff", border: "#ccc")
                        HStack {
                            Button("Save Settings", action: onSaveClick)
                                .bsPadding(vertical: 10.0, horizontal: 15.0)
                                .bsColors(fg: "#fff", bg: "#8bc540", border: "#699431")
                            Spacer()
                            Button("Scan Code", action: onScanClick)
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
    
    func onSaveClick() {
        SettingsService.kioskAddress = self.checkinUrl
        self.currentAppScreen = .webview
    }
    func onScanClick() {
        self.currentAppScreen = .codescanner
    }
}

struct UrlEntryView_Previews: PreviewProvider {
    @State static private var currentViewState: AppScreen = AppScreen.urlentryview
    static var previews: some View {
        UrlEntryView(currentAppScreen: self.$currentViewState)
    }
}
