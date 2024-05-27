//
//  ChatListView.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 30.04.2024.
//

import SwiftUI

struct ChatListView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var newFolderName = ""
    @State private var isCreatingFolder = false
    @State private var showingMoveOptions = false
    @State private var selectedChat: Chat?

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.folders, id: \.id) { folder in
                            Button(folder.name) {
                                viewModel.setActiveFolder(folder)
                            }
                            .padding()
                            .background(viewModel.activeFolder?.id == folder.id ? Color.blue : Color.gray)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                        }
                        Button(action: {
                            isCreatingFolder = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                
                List {
                    ForEach(viewModel.activeFolder?.chats ?? [], id: \.id) { chat in
                        NavigationLink(destination: MessagesView(chatId: chat.id, messages: chat.messages)) {
                            ChatRow(chat: chat)
                                .contextMenu {
                                    Button("Move") {
                                        selectedChat = chat
                                        showingMoveOptions = true
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Chats")
            .alert("New Folder", isPresented: $isCreatingFolder, actions: {
                TextField("Folder Name", text: $newFolderName)
                Button("Create") {
                    viewModel.createFolder(named: newFolderName)
                    newFolderName = ""
                    isCreatingFolder = false
                }
            }, message: {
                Text("Enter the name for the new folder.")
            })
            .actionSheet(isPresented: $showingMoveOptions) {
                ActionSheet(title: Text("Move Chat to Folder"), message: Text("Select a folder"), buttons: actionSheetButtons())
            }
        }
    }
    
    private func actionSheetButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        for folder in viewModel.folders {
            buttons.append(.default(Text(folder.name)) {
                if let selectedChat = selectedChat {
                    if let toFolder = viewModel.folders.first(where: { $0.id == folder.id }) {
                        viewModel.moveChatToFolder(chatId: selectedChat.id, fromFolder: viewModel.activeFolder, toFolder: toFolder)
                    }
                }
            })
        }
        buttons.append(.cancel())
        return buttons
    }
}


struct ChatRow: View {
    var chat: Chat

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: chat.iconUrl)) { phase in
                if let image = phase.image {
                    image.resizable() // Apply resizable to the image, not the AsyncImage
                         .aspectRatio(contentMode: .fill)
                         .frame(width: 30, height: 30)
                         .clipShape(Circle())
                } else if phase.error != nil {
                    Color.gray // Indicates an error
                         .frame(width: 30, height: 30)
                         .clipShape(Circle())
                } else {
                    Color.gray // Placeholder while loading
                         .frame(width: 30, height: 30)
                         .clipShape(Circle())
                }
            }

            AsyncImage(url: URL(string: chat.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable()
                         .aspectRatio(contentMode: .fill)
                         .frame(width: 50, height: 50)
                         .clipShape(Circle())
                } else if phase.error != nil {
                    Color.gray
                         .frame(width: 50, height: 50)
                         .clipShape(Circle())
                } else {
                    Color.gray
                         .frame(width: 50, height: 50)
                         .clipShape(Circle())
                }
            }

            VStack(alignment: .leading) {
                Text("\(chat.name) \(chat.surname)").font(.headline)
                Text(chat.lastMessage).font(.subheadline).foregroundColor(.gray)
            }
        }
    }
}



#Preview {
    ChatListView(viewModel: ChatViewModel())
}
