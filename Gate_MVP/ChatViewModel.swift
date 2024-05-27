//
//  ChatViewModel.swift
//  Gate_MVP
//
//  Created by Даниил Аношенко on 30.04.2024.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var activeFolder: Folder?
    @Published var allChatsFolder: Folder?
    @Published var chats: [Chat] = []
    
    private var vkMethods = VK_Methods()
    
    
    init() {
        loadChats {
                 // Execute these once chats are loaded
                 self.setupInitialFolders()
                 print("Здесь должны быть чаты: ", self.chats)
             }
       }
    
    func loadChats(completion: @escaping () -> Void) {
         vkMethods.getConversations { [weak self] result in
             guard let self = self else { return }
             switch result {
             case .success(let userIDs):
                 self.loadUserDetailsAndAvatar(userIDs: userIDs, completion: completion)
             case .failure(let error):
                 print("Error getting conversations: \(error)")
                 completion()
             }
         }
     }
    
    private func loadUserDetailsAndAvatar(userIDs: [String], completion: @escaping () -> Void) {
           let group = DispatchGroup()
           for userID in userIDs {
               group.enter()
               vkMethods.getUserInfo(userID: userID) { [weak self] result in
                   guard let self = self else {
                       group.leave()
                       return
                   }
                   switch result {
                   case .success(let (name, surname)):
                       self.vkMethods.getUserAvatar(userID: userID) { result in
                           switch result {
                           case .success(let imageUrl):
                               DispatchQueue.main.async {
                                   let newChat = Chat(
                                       id: Int(userID) ?? 0,
                                       name: name,
                                       surname: surname,
                                       imageUrl: imageUrl,
                                       iconUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/VK.com-logo.svg/1024px-VK.com-logo.svg.png",
                                       messages: []
                                   )
                                   self.chats.append(newChat)
                                   group.leave()
                               }
                           case .failure(let error):
                               print("Error getting user avatar: \(error)")
                               group.leave()
                           }
                       }
                   case .failure(let error):
                       print("Error getting user info: \(error)")
                       group.leave()
                   }
               }
           }

           group.notify(queue: .main) {
               self.chats.sort(by: { $0.lastMessageDate > $1.lastMessageDate })
               completion()
           }
       }
    
    
    
    
    
    private func setupInitialFolders() {
          let allChatsFolder = Folder(name: "All Chats", chats: self.chats)
          self.allChatsFolder = allChatsFolder
          self.folders.append(allChatsFolder)
          self.activeFolder = allChatsFolder
      }

    
    func createFolder(named name: String) {
        guard !name.isEmpty else { return }
        let newFolder = Folder(name: name, chats: [])
        DispatchQueue.main.async {
            self.folders.append(newFolder)
        }
    }
    
    func setActiveFolder(_ folder: Folder) {
           activeFolder = folder
       }
    
    
    func moveChatToFolder(chatId: Int, fromFolder: Folder?, toFolder: Folder) {
        guard let fromFolderUnwrapped = fromFolder else { return }

        // First, find the chat in the global list of chats
        guard let chatToAdd = chats.first(where: { $0.id == chatId }) else {
            print("Chat with ID \(chatId) not found.")
            return
        }

        // Find indexes for from and to folders
        guard let fromFolderIndex = folders.firstIndex(where: { $0.id == fromFolderUnwrapped.id }),
              let toFolderIndex = folders.firstIndex(where: { $0.id == toFolder.id }) else {
            return
        }

        // Remove the chat from the original folder if it's not "All Chats"
        if fromFolderUnwrapped.name != "All Chats" {
            folders[fromFolderIndex].chats.removeAll { $0.id == chatId }
        }

        // Add the chat to the new folder, ensuring it's not duplicated
        if !folders[toFolderIndex].chats.contains(where: { $0.id == chatId }) {
            folders[toFolderIndex].chats.append(chatToAdd)
        }

        // Ensure the chat is in "All Chats" folder
        if let allChatsIndex = folders.firstIndex(where: { $0.name == "All Chats" }) {
            if !folders[allChatsIndex].chats.contains(where: { $0.id == chatId }) {
                folders[allChatsIndex].chats.append(chatToAdd)
            }
        }
    }

}
