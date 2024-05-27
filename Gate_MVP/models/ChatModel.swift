//
//  ChatModel.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 30.04.2024.
//

import Foundation

struct Chat: Identifiable, Decodable {
    var id: Int
    var name: String
    var surname: String
    var imageUrl: String
    var iconUrl: String // URL for the social network icon
    var messages: [Message]
    var folderId: UUID?  // Link chat to a folder
    
    // Computed property to get the last message for displaying in list
      var lastMessage: String {
          messages.sorted { $0.date > $1.date }.first?.text ?? "No messages"
      }
      
      // For sorting by the most recent message date
      var lastMessageDate: Date {
          messages.sorted { $0.date > $1.date }.first?.date ?? Date()
      }
}
