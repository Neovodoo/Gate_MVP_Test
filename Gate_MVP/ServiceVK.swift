
//
//  VK_API_Methods.swift
//  Prototipe
//
//  Created by Даниил Аношенко on 12.02.2023.
//

import Foundation
import Alamofire
import SwiftyJSON

//Расширение, для кодировки строк под кириллицу
extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}

enum VKError: Error {
    case invalidResponse
    case apiError(message: String)
}

struct VK_Methods{
 
    var token: String = "vk1.a.hinirpFbQ-NqcCxEG165KXhmcK_tEdLy1pMPJUMHKk1ry6yJKOo47Lw4Fst14vM2jXJibZUN4P5N1px9a7PIMNjcG3sroXGcEKX2SCsH3DSuy7jbiqXNvZcMBciuyJC8SQFqlj1t7k2ilq2EkvFvAH7oE_Hkcs24IXcLKy70PO8hZDtYtJLuL16lfPdrItP07rYLY6oA-2L5X5Eaok_WKg"
   
    var version: String = "5.199"
    
    
    
    let baseURL = "https://api.vk.com/method/"
       let usersGet = "users.get"
       let messagesSend = "messages.send"
       
    func getUserInfo(userID: String, completion: @escaping (Result<(name: String, surname: String), VKError>) -> Void) {
           let url = baseURL + "users.get"
           let parameters: Parameters = [
               "user_ids": userID,
               "access_token": token,
               "v": version
           ]
           
         AF.request(url, method: .get, parameters: parameters).validate().responseJSON { response in
               switch response.result {
               case .success(let value):
                   let json = JSON(value)
                   guard let name = json["response"][0]["first_name"].string,
                         let surname = json["response"][0]["last_name"].string else {
                       completion(.failure(.invalidResponse))
                       return
                   }
                   completion(.success((name: name, surname: surname)))
               case .failure(let error):
                   completion(.failure(.apiError(message: error.localizedDescription)))
               }
           }
        
       }
       
    /*   func sendMessage(message: String, userID: String, completion: @escaping (Result<Void, VKError>) -> Void) {
           let url = baseURL + messagesSend
           let parameters: [String: Any] = [            "user_id": userID,            "message": message,            "access_token": token,            "v": version        ]
           AF.request(url, method: .post, parameters: parameters).responseJSON { response in
               if let error = response.error {
                   completion(.failure(.apiError(message: error.localizedDescription)))
               } else {
                   completion(.success(Void()))
               }
           }
       }
    */
     
   /* func loadMessages(userID: String, afterTimestamp: Double?, completion: @escaping (Result<[Message], VKError>) -> Void) {
        let method = "messages.getHistory"
        let url = baseURL + method
        var parameters: [String: Any] = [
            "user_id": userID,
            "count": 200,
            "access_token": token,
            "v": version
        ]
        
        if let timestamp = afterTimestamp {
            parameters["start_time"] = timestamp + 1
        }
        
        AF.request(url, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let items = json["response"]["items"].array {
                    let messages = items.compactMap { item -> Message? in
                        guard let text = item["text"].string,
                              let timestamp = item["date"].double,
                              let isIncoming = item["out"].int else {
                            return nil
                        }
                        return Message(text: text, timestamp: timestamp, isIncoming: isIncoming == 0 ? true : false)
                    }
                    completion(.success(messages))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(.apiError(message: error.localizedDescription)))
            }
        }
    }


*/
    
    func getConversations(completion: @escaping (Result<[String], VKError>) -> Void) {
        let method = "messages.getConversations"
        let url = baseURL + method
        let parameters: [String: Any] = [
            "count": 10,
            "access_token": token,
            "v": version
        ]
        
        AF.request(url, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let items = json["response"]["items"].array {
                    let conversations = items.compactMap { item -> String? in
                        guard let peer = item["conversation"]["peer"].dictionary,
                              let type = peer["type"]?.stringValue,
                              let id = peer["id"]?.stringValue else {
                                  return nil
                              }
                        if type == "user" {
                            return id
                        } else {
                            return nil
                        }
                    }
                    completion(.success(conversations))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(.apiError(message: error.localizedDescription)))
            }
        }
    }
    
    func getUserAvatar(userID: String, completion: @escaping (Result<String, VKError>) -> Void) {
            let url = baseURL + "users.get"
            let parameters: Parameters = [
                "user_ids": userID,
                "fields": "photo_max_orig",
                "access_token": token,
                "v": version
            ]
            
            AF.request(url, method: .get, parameters: parameters).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard let avatarUrl = json["response"][0]["photo_max_orig"].string else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    completion(.success(avatarUrl))
                case .failure(let error):
                    completion(.failure(.apiError(message: error.localizedDescription)))
                }
            }
        }
   }
