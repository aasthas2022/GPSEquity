//
//  CardView.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/29/24.
//

import Foundation

struct CardView(post: Post)->some View{
    
    // Detail View...
    NavigationLink {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(alignment: .leading, spacing: 15) {
                
                
                Text("Written By: \(post.author)")
                    .foregroundColor(.gray)
                
                Text("DateF: \(            post.date.dateValue().formatted(date: .numeric, time: .shortened))")
                    .foregroundColor(.gray)
                
                ForEach(post.postContent){content in
                    
                    if content.type == .Image{
                        WebImage(url: content.value)
                    }
                    else{
                        Text(content.value)
                            .font(.system(size: getFontSize(type: content.type)))
                            .lineSpacing(10)
                    }
                }
            }
            .padding()
        }.background(Color(hex: 0x010b26))
        .navigationTitle(post.title).environment(\.colorScheme, .dark)
        
    } label: {
        
        VStack(alignment: .leading, spacing: 12) {
            Text(post.title)
                .fontWeight(.bold)
            HStack {
                Text("Written by:")
                Text(post.author)
                    .fontWeight(.semibold)
                Spacer()
                if let user = Auth.auth().currentUser {
                    if let photoURL = user.photoURL {
                        AsyncImage(url: photoURL)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                }
            }
        }.background(Color(hex: 0x010b26)).environment(\.colorScheme, .dark)
        
        Text(post.date.dateValue().formatted(date: .numeric, time: .shortened))
            .font(.caption.bold())
            .foregroundColor(.gray)
        
    }
}
