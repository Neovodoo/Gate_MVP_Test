//
//  MessagesViewModel.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 30.04.2024.
//

import Foundation

class MessagesViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    func loadMessages(for chatId: Int) {
            let now = Date()
            let earlier = Date(timeIntervalSinceNow: -300)  // 5 minutes ago

        
            
            // Load messages with test data including actual dates
            messages = [
                Message(id: 1, text: "Hey, how are you?", date: earlier, isOutgoing: false),
                Message(id: 2, text: "I'm good, thanks for asking!", date: now, isOutgoing: true)
            ]
        }
}
