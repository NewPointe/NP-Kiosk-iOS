//
//  ProgressBar.swift
//  https://github.com/gualtierofrigerio/SwiftUIProgressBar
//
//  Created by Gualtiero Frigerio on 26/07/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
    var trackColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    var barColor: UIColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
    var height: CGFloat = 10
    @Binding var value: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .trailing) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .opacity(Double(self.trackColor.rgba.alpha))
                        .background(Color(self.trackColor))
                    Rectangle()
                        .frame(minWidth: 0, idealWidth:self.getProgressBarWidth(geometry: geometry),
                               maxWidth: self.getProgressBarWidth(geometry: geometry))
                               .opacity(Double(self.barColor.rgba.alpha))
                               .background(Color(self.barColor))
                        .animation(.default)
                }
                .frame(height: self.height)
            }.frame(height: self.height)
        }.frame(height: self.height)
    }
    
    func getProgressBarWidth(geometry:GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        return frame.size.width * value
    }
}

struct ProgressBar_Previews: PreviewProvider {
    @State static var value: CGFloat = 0.5
    static var previews: some View {
        ProgressBar(value: self.$value)
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}
