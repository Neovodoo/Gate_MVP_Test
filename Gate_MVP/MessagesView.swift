//
//  MessagesView.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 30.04.2024.
//

import SwiftUI

struct MessagesView: View {
    var chatId: Int
    var messages: [Message]

    var body: some View {
        List(messages.sorted(by: { $0.date < $1.date }), id: \.id) { message in
            HStack {
                if message.isOutgoing {
                    Spacer()
                    messageView(message: message, color: .blue)
                } else {
                    messageView(message: message, color: .gray)
                    Spacer()
                }
            }
        }
        .navigationTitle("Messages")
    }

    @ViewBuilder
    private func messageView(message: Message, color: Color) -> some View {
        VStack(alignment: .trailing) {
            Text(message.text)
                .padding()
                .background(color)
                .clipShape(Capsule())
                .foregroundColor(.white)
            Text(message.formattedTime)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: 300, alignment: message.isOutgoing ? .trailing : .leading)
    }
}



