//
//  MessageModel.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 30.04.2024.
//

import Foundation

struct Message: Identifiable, Decodable {
    var id: Int
    var text: String
    var date: Date
    var isOutgoing: Bool

    // Computed property to format date
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


