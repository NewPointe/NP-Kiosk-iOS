//
//  Other.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 7/9/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    /// Adds a Bootstrap-like foreground, background, and border to the `View`.
    /// - Parameters:
    ///   - fg: The foreground color
    ///   - bg: The background color
    ///   - border: The border color
    /// - Returns: The view
    func bsColors(fg: String, bg: String, border: String) -> some View {
        self.background(Color(hex: bg))
            .foregroundColor(Color(hex: fg))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: border), lineWidth: 1)
            )
    }
    
    /// Adds padding to a `View`. This is just a shortcut for horizontal and vertical `.padding()`.
    /// - Parameters:
    ///   - vertical: The vertical padding
    ///   - horizontal: The horizontal padding
    /// - Returns: The view
    func bsPadding(vertical: CGFloat, horizontal: CGFloat) -> some View {
        self.padding(.vertical, vertical)
            .padding(.horizontal, horizontal)
    }
}

extension Color {
    /// Grab a section of a binary number
    /// - Parameters:
    ///   - num: The number
    ///   - size: The size of each section in bits
    ///   - index: The index of the section to get
    /// - Returns: The section
    private static func shifty(_ num: UInt64, size: Int, index: Int) -> Int {
        let mask = ~(~0x0 << size)
        let shift = size * index
        return (Int(num) & (mask << shift)) >> shift
    }
    
    /// Duplicates the first `size` bits of a binary number
    /// - Parameters:
    ///   - num: The number
    ///   - size: The number of bits to duplicate
    /// - Returns: A new number
    private static func dupe(_ num: Int, size: Int) -> Int {
        return num | num << size
    }
    
    /// Creates a new color from RGB(A) integers.
    /// - Parameters:
    ///   - red: The red component
    ///   - green: The green component
    ///   - blue: The blue component
    ///   - alpha: The alpha component
    init(red: Int, green: Int, blue: Int, alpha: Int = 255) {
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: Double(alpha) / 255)
    }

    /// Creates a new color from a hex code
    /// - Parameter hex: A hex code representing the color
    init(hex: String) {
        let hex = hex.hasPrefix("#") ? String(hex[hex.index(hex.startIndex, offsetBy: 1)...]) : hex
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            switch hex.count {
                case 8:
                    self.init(
                        red:   Color.shifty(hexNumber, size: 8, index: 3),
                        green: Color.shifty(hexNumber, size: 8, index: 2),
                        blue:  Color.shifty(hexNumber, size: 8, index: 1),
                        alpha: Color.shifty(hexNumber, size: 8, index: 0)
                    )
                case 6:
                    self.init(
                        red:   Color.shifty(hexNumber, size: 8, index: 2),
                        green: Color.shifty(hexNumber, size: 8, index: 1),
                        blue:  Color.shifty(hexNumber, size: 8, index: 0)
                    )
                case 4:
                    self.init(
                        red:   Color.dupe(Color.shifty(hexNumber, size: 4, index: 3), size: 4),
                        green: Color.dupe(Color.shifty(hexNumber, size: 4, index: 2), size: 4),
                        blue:  Color.dupe(Color.shifty(hexNumber, size: 4, index: 1), size: 4),
                        alpha: Color.dupe(Color.shifty(hexNumber, size: 4, index: 0), size: 4)
                    )
                case 3:
                    self.init(
                        red: Color.dupe(Color.shifty(hexNumber, size: 4, index: 2), size: 4),
                        green: Color.dupe(Color.shifty(hexNumber, size: 4, index: 1), size: 4),
                        blue: Color.dupe(Color.shifty(hexNumber, size: 4, index: 0), size: 4)
                    )
                default:
                    self.init(.red)
            }
            return
        }
        self.init(.red)
        return
    }
}

extension Bundle {
    /// Gets the name of the app
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

extension String {
    /// Creates a new string from the contents of a resource file
    /// - Parameters:
    ///   - contentsOfResource: The resource file name
    ///   - ofType: The resource file extension
    init?(contentsOfResource: String, ofType: String) {
        if
            let filepath = Bundle.main.path(forResource: contentsOfResource, ofType: ofType),
            let contents = try? String(contentsOfFile: filepath)
        {
            self = contents
        }
        else {
            return nil
        }
    }
}

extension StringProtocol {
    /// Trims whitespace and newlines
    /// - Returns: The trimmed `String`
    func trimWhitespace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// Trims whitespace, newlines, and the specified characters
    /// - Parameter charactersIn: The additional characters to trim
    /// - Returns: The trimmed `String`
    func trimWhitespace(and charactersIn: String) -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: charactersIn)))
    }
}
