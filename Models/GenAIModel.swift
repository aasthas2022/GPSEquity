//
//  ChatGPTAPIModels.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import Foundation

//struct Message: Codable {
//    let role: String
//    let content: String
//}
//
//extension Array where Element == Message {
//    
//    var contentCount: Int { reduce(0, { $0 + $1.content.count })}
//}
//
//struct Request: Codable {
//    let model: String
//    let temperature: Double
//    let messages: [Message]
//    let stream: Bool
//}
//
//struct ErrorRootResponse: Decodable {
//    let error: ErrorResponse
//}
//
//struct ErrorResponse: Decodable {
//    let message: String
//    let type: String?
//}
//
//struct StreamCompletionResponse: Decodable {
//    let choices: [StreamChoice]
//}
//
//struct CompletionResponse: Decodable {
//    let choices: [Choice]
//    let usage: Usage?
//}
//
//struct Usage: Decodable {
//    let promptTokens: Int?
//    let completionTokens: Int?
//    let totalTokens: Int?
//}
//
//struct Choice: Decodable {
//    let message: Message
//    let finishReason: String?
//}
//
//struct StreamChoice: Decodable {
//    let finishReason: String?
//    let delta: StreamMessage
//}
//
//struct StreamMessage: Decodable {
//    let role: String?
//    let content: String?
//}

enum GeminiAPIKey {
  // Fetch the API key from `GenerativeAI-Info.plist`
  static var `default`: String {
    guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
    else {
      fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
    }
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
    }
    if value.starts(with: "_") {
      fatalError(
        "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
      )
    }
    return value
  }
}


enum ChatRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID().uuidString
    var role: ChatRole
    var message: String
    var images: [Data]?
}




struct GPTChatMessage: Identifiable {
    var id = UUID()
    var message: String
    var isUser: Bool
}
