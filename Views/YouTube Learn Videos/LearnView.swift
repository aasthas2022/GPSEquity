//
//  LearnView.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI
import WebKit
import FirebaseAuth

struct LearnView: View {
    var body: some View {
            ScrollView{
                VStack{
                    Text("Learn")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text("Stock Market Basics")
                        .font(.title3)
                        .fontWeight(.bold)
                    YTView(ID: "p7HKvqRI_Bo")
                        .padding()
                    
                    Text("Technical Analysis")
                        .font(.title3)
                        .fontWeight(.bold)
                    YTView(ID: "mBTPvvgRICQ")
                        .padding()

                    Text("Fundamental Analysis")
                        .font(.title3)
                        .fontWeight(.bold)
                    YTView(ID: "PQqfeyUQbyE")
                        .padding()

                    Text("Options Trading for Beginners")
                        .font(.title3)
                        .fontWeight(.bold)
                    YTView(ID: "M86YwBWxygI")
                        .padding()
                }
            }
//            .background(Color(hex: 0x010b26))


    }
}


struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}


