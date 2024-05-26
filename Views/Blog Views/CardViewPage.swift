//
//  CardViewPage.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/30/24.
//

import Foundation
import SwiftUI
import Firebase

struct CardViewPageView: View {
    var post: Post;
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack{
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Written by:") .foregroundColor(.gray)
                        Text(post.author)
                            .fontWeight(.semibold) .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Date:") .foregroundColor(.gray)
                        Text(post.date.dateValue().formatted(date: .numeric, time: .shortened))
                            .fontWeight(.semibold) .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    ForEach(post.postContent){content in
                        
                        if (content.type == .Image || content.type == .ImageUpload){
                                WebImage(url: content.value)
                            }
                            else{
                                Text(content.value)
                                    .font(.system(size: getFontSize(type: content.type)))
                                    .lineSpacing(10)
                            }
                        }
                }
//                .background(Color(hex: 0x010b26))
                .background(Color.black)
                Spacer()
            }.padding()
//                .background(Color(hex: 0x010b26))
                .background(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environment(\.colorScheme, .dark)
                .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        Text(post.title).foregroundColor(.white)
                                }
                }
            }.environment(\.colorScheme, .dark)
        }
    }


struct CardViewPageView_Previews: PreviewProvider {
    static var previews: some View {
        CardViewPageView(post: Post(
            id: "001",
            authorUID: "0000001",
            title: "Daily Roundup: Innovation and Earth",
            author: "Jane Doe",
            postContent: [
                PostContent(value: "Welcome to Our Blog", type: .Header),
                PostContent(value: "Today's Highlights", type: .SubHeading),
                PostContent(value: "We bring you the latest updates on technology, environment, and culture with in-depth analysis and insights.", type: .Paragraph),
                PostContent(value: "https://www.example.com/sample-image.jpg", type: .Image)  // Assuming you have a mechanism to handle image URLs
            ],
            date: Timestamp(date: Date())  // Create a Timestamp with the current date
        ))
    }
}
