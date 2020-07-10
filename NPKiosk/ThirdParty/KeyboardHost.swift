//
//  KeyboardHost.swift
//  https://stackoverflow.com/a/57235093
//
//  Created by Benjamin Kindle on 27/7/2019.
//
//  This work is licensed under the terms of CC BY-SA 4.0.
//  See https://creativecommons.org/licenses/by-sa/4.0/
//

import SwiftUI

struct KeyboardHost<Content: View>: View {
    let view: Content

    @State private var keyboardHeight: CGFloat = 0

    private let showPublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillShowNotification
    ).map { (notification) -> CGFloat in
        if let rect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            return rect.size.height
        } else {
            return 0
        }
    }

    private let hidePublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillHideNotification
    ).map {_ -> CGFloat in 0}

    // Like HStack or VStack, the only parameter is the view that this view should layout.
    // (It takes one view rather than the multiple views that Stacks can take)
    init(@ViewBuilder content: () -> Content) {
        view = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            view
            Rectangle()
                .frame(height: keyboardHeight)
                .foregroundColor(.clear)
        }.onReceive(showPublisher.merge(with: hidePublisher)) { (height) in
            withAnimation(.spring()) {
                self.keyboardHeight = height
            }
        }
    }
}
