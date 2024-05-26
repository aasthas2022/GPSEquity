//
//  GeminiViewModel.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/24/24.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

@Observable
class ChatService {
    private var proModel = GenerativeModel(name: "gemini-pro", apiKey: GeminiAPIKey.default)
    private(set) var messages = [ChatMessage]()
    private(set) var loadingResponse = false
    
    func sendMessage(message: String) async {
        
        loadingResponse = true
        
        messages.append(.init(role: .user, message: message))
        messages.append(.init(role: .model, message: "", images: nil))
        
        do {
            let chatModel = proModel
            
           
            
            // MARK: Request and stream the response
            let outputStream = chatModel.generateContentStream(message)
            for try await chunk in outputStream {
                guard let text = chunk.text else {
                    return
                }
                let lastChatMessageIndex = messages.count - 1
                messages[lastChatMessageIndex].message += text
            }
            
            loadingResponse = false
        }
        catch {
            loadingResponse = false
            messages.removeLast()
            messages.append(.init(role: .model, message: "Something went wrong. Please try again."))
            print(error.localizedDescription)
        }
    }
}
