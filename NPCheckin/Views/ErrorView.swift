//
//  ErrorView.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 7/7/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import SwiftUI

struct ErrorView<Content> : View where Content : View {
    let onRetryClick: () -> Void
    let onResetClick: () -> Void
    let content: () -> Content
    
    public init(onRetryClick: @escaping () -> Void, onResetClick: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onRetryClick = onRetryClick
        self.onResetClick = onResetClick
        self.content = content
    }
    
    public var body: some View {
        VStack {
            VStack(content: content)
                .bsPadding(vertical: 10.0, horizontal: 15.0)
            HStack {
                Button("Retry", action: onRetryClick)
                    .bsPadding(vertical: 10.0, horizontal: 15.0)
                    .bsColors(fg: "#fff", bg: "#8bc540", border: "#699431")
                Spacer().frame(maxWidth: 15)
                Button("Reset", action: onResetClick)
                    .bsPadding(vertical: 10.0, horizontal: 15.0)
                    .bsColors(fg: "#fff", bg: "#5bc0de", border: "#4694ab")
            }
            .padding(.vertical, 10.0)
            .frame(maxWidth: .infinity)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(onRetryClick: {}, onResetClick: {}) {
            Text("404").font(.largeTitle)
            Text("An error occured")
        }
            .statusBar(hidden: true)
            .edgesIgnoringSafeArea(.all)
    }
}
