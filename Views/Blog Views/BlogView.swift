//
//  Home.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI
import FirebaseAuth


struct Home: View {
    @StateObject var blogData = BlogViewModel()
    
    
    // Color Based on ColorScheme...
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        
        VStack{
            
            Text("GPSEquity - Blog")
                .fontWeight(.bold)
                .padding(.leading, -8) // adjust the padding as needed
            
            
                UserAuthenticatedView(blogData: blogData)
             
        }
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            alignment: .bottomTrailing
        ) {
            FAB(blogData: blogData).environment(\.colorScheme, .dark)
        }
        
         .task {
            await blogData.fetchPosts()
        }
        .background(Color.black)
        .fullScreenCover(isPresented: $blogData.createPost, content: {
            
            // Create Post View....
            CreatePost()
                .overlay(
                    ZStack{
                        Color.primary.opacity(0.25)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .frame(width: 80, height: 80)
                            .background(scheme == .dark ?  .black : .white, in:RoundedRectangle(cornerRadius: 15))
                    }
                        .opacity(blogData.isWriting ? 1 : 0)
                )
                .environment(\.colorScheme, .dark)
                .environmentObject(blogData)
                .background(Color.black)
        })
        .background(Color.black)
        .alert(blogData.alertMsg, isPresented: $blogData.showAlert) {
        }
        .background(Color.black)
        .environment(\.colorScheme, .dark)
    }
    
    
}

struct FAB: View {
    @ObservedObject var blogData: BlogViewModel
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Button(action: {
            blogData.createPost.toggle()
        }, label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(scheme == .dark ? Color.black : Color.white)
                .padding()
                .background(.primary, in: Circle())
        })
        .padding()
        .foregroundStyle(.primary)
    }
}


struct CardView: View {
    var post: Post
    var body: some View {
        VStack{
            NavigationLink {
                CardViewPageView(post:post).environment(\.colorScheme, .dark)
                    .background(Color.black)
            }
            
            label: {
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
                }.environment(\.colorScheme, .dark)
                
                Text(post.date.dateValue().formatted(date: .numeric, time: .shortened))
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }.environment(\.colorScheme, .dark)
        }.environment(\.colorScheme, .dark)
    }
}


struct UserAuthenticatedView: View {

    @ObservedObject var blogData: BlogViewModel
    var body: some View {
        if let posts = blogData.posts {
            if posts.isEmpty {
                Text("Start Writing Blog")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            } else {
                NavigationView {
                    List(posts) { post in
                        CardView(post: post)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    blogData.deletePost(post: post)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                    }
                    .listStyle(.insetGrouped)
                }
                .background(Color.black)
                .environment(\.colorScheme, .dark)
            }
        } else {
            ProgressView()
        }
//        Spacer()
    }
}







struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
