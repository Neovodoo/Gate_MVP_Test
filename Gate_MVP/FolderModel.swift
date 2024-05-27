//
//  FolderModel.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 01.05.2024.
//

import Foundation
struct Folder: Identifiable {
    let id: UUID = UUID()
    var name: String
    var chats: [Chat]
}
