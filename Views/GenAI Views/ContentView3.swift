//
//  ContentView3.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/24/24.
//

import SwiftUI
import Combine
import GoogleGenerativeAI

struct ContentView3: View {
    let model = GenerativeModel(name: "gemini-pro", apiKey: GeminiAPIKey.default)
    @State var textInput = ""
    @State var aiResponse = "Hello! How can I help you today?"
    @State var logoAnimating = false
    @State private var timer: Timer?

    var body: some View {
        VStack {
            
            // MARK: AI response
            ScrollView {
                Text(aiResponse)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            }

            // MARK: Input fields
            HStack {
                TextField("Enter a message", text: $textInput)
                    .textFieldStyle(.roundedBorder)
//                    .foregroundStyle(Color(hex: 0x010b26))
                Button(action: sendMessage, label: {
                    Image(systemName: "paperplane.fill")
                })
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background {
            // MARK: Background
            ZStack {
//                Color(hex: 0x010b26)
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: Fetch response
    func sendMessage() {
        aiResponse = ""
        startLoadingAnimation()
        
        Task {
            do {
                let response = try await model.generateContent(textInput)
                
                stopLoadingAnimation()
                
                guard let text = response.text else  {
                    textInput = "Sorry, I could not process that.\nPlease try again."
                    return
                }
                
                textInput = ""
                aiResponse = text
                
            } catch {
                stopLoadingAnimation()
                aiResponse = "Something went wrong!\n\(error.localizedDescription)"
            }
        }
    }
    
    // MARK: Response loading animation
    func startLoadingAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            logoAnimating.toggle()
        })
    }
    
    func stopLoadingAnimation() {
        logoAnimating = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView3()
}
