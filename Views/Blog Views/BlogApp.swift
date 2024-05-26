//
//  BlogApp.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI
import Firebase

struct BlogApp: App {
    
    //Initializing Firebase...
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene{
        WindowGroup {
            ContentView()
        }
    }
}


struct ContentView: View {
    var body: some View{
            Home()
        }
   
}
