//
//  ProgressBar.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 6/23/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
    var height: CGFloat = 20
    var barColor: Color = Color(hex: "#0a0")
    var trackColor: Color = Color(hex: "#0002")
    @Binding var value: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().fill(self.trackColor)
                Rectangle()
                    .fill(self.barColor)
                    .frame(width: geometry.size.width * self.value)
                    .animation(.default)
            }
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
