//
//  Extensions.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/29/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI

extension View {
    func bsColors(fg: String, bg: String, border: String) -> some View {
        self.background(Color(hex: bg))
            .foregroundColor(Color(hex: fg))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: border), lineWidth: 1)
            )
    }
    func bsPadding(vertical: CGFloat, horizontal: CGFloat) -> some View {
        self.padding(.vertical, vertical)
            .padding(.horizontal, horizontal)
    }
}

extension Color {
    public init(hex: String) {
        var hexColor:String = hex
        
        if (hexColor.hasPrefix("#")) {
            hexColor.remove(at: hexColor.startIndex)
        }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            if hexColor.count == 8 {
                self.init(UIColor(
                    red: CGFloat((hexNumber & 0xff000000) >> 24) / 255,
                    green: CGFloat((hexNumber & 0x00ff0000) >> 16) / 255,
                    blue: CGFloat((hexNumber & 0x0000ff00) >> 8) / 255,
                    alpha: CGFloat(hexNumber & 0x000000ff) / 255
                ))
                return
            }
            else if hexColor.count == 6 {
                self.init(UIColor(
                    red: CGFloat((hexNumber & 0xff0000) >> 16) / 255,
                    green: CGFloat((hexNumber & 0x00ff00) >> 8) / 255,
                    blue: CGFloat(hexNumber & 0x0000ff) / 255,
                    alpha: 1
                ))
                return
            }
            else if hexColor.count == 3 {
                self.init(UIColor(
                    red: CGFloat(((hexNumber & 0xf00) >> 4) | ((hexNumber & 0xf00) >> 8)) / 255,
                    green: CGFloat(((hexNumber & 0x0f0)) | ((hexNumber & 0x0f0) >> 4)) / 255,
                    blue: CGFloat(((hexNumber & 0x00f) << 4) | ((hexNumber & 0x00f))) / 255,
                    alpha: 1
                ))
                return
            }
        }
        
        self.init(.red)
        return
    }
}
