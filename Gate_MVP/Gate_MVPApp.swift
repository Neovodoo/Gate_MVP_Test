//
//  Gate_MVPApp.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 30.04.2024.
//

import SwiftUI

@main
struct Gate_MVPApp: App {
    var body: some Scene {
        WindowGroup {
            ChatListView(viewModel: ChatViewModel())
        }
    }
}
