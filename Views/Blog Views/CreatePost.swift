//
//  CreatePost.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI

struct CreatePost: View {
    @EnvironmentObject var blogData : BlogViewModel
    // Color Based on ColorScheme...
    // Post Properties...
    @State var postTitle = ""
    @State var authorName = ""
    @State var postContent : [PostContent] = []
    @State private var showImagePicker = false
    @State private var imageUploaded = false
    @State private var imageToUpload: UIImage?
    
    // Keyboard Focus State for TextViews...
    @FocusState var showKeyboard: Bool
    
    var body: some View {
        
        // Since we need Nav Buttons...
        // So Including NavBar...
        NavigationView{
            
            ScrollView(.vertical, showsIndicators: false, content: {
                
                VStack(spacing: 15){
                    
                    VStack(alignment: .leading){
                        
                        TextField("Post Title", text: $postTitle)
                            .font(.title2).foregroundColor(Color.white)
                        
                        Divider()
                    }
                    
                    VStack(alignment: .leading,spacing: 11){
                        
                        Text("Author:")
                            .font(.caption.bold())
                        
                        TextField("Sydney", text: $authorName).foregroundColor(Color.white)
                        
                        Divider()
                    }
                    .padding(.top,5)
                    .padding(.bottom,20)
                    
                    // iterating Post Content...
                    ForEach($postContent){$content in
                        
                        VStack{
                            
                            // Image URL...
                            if content.type == .Image{
                                
                                if content.showImage && content.value != ""{
                                    
                                    WebImage(url: content.value)
                                    // if tap change url..
                                        .onTapGesture {
                                            withAnimation{
                                                content.showImage = false
                                            }
                                        }
                                }
                                else{
                                    
                                    // Textfield For URL...
                                    VStack{
                                        
                                        TextField("Image URL", text: $content.value, onCommit:  {
                                            
                                            withAnimation{
                                                content.showImage = true
                                            }
                                            // To Show Image when Pressed Retrun....
                                        })
                                        
                                        Divider()
                                    }
                                    .padding(.leading,5)
                                }
                            }
                            else if (content.type == .ImageUpload) {
                                if let image = imageToUpload {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 250)
                                    if (imageUploaded == false) {
                                        Button("Upload") {
                                            blogData.uploadImage(image) { result in
                                                switch result {
                                                case .success(let url):
                                                    content.value = url
                                                    content.showImage = true
                                                    imageUploaded = true
                                                    //                                                imageToUpload = nil // Reset the image after uploading
                                                case .failure(let error):
                                                    print("Upload failed: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Button("Select Image") {
                                        showImagePicker = true
                                    }
                                    .sheet(isPresented: $showImagePicker) {
                                        ImagePicker(selectedImage: $imageToUpload)
                                    }
                                }
                            }
                            else{
                                
                                // Custom Text Editor From UIKit...
                                TextView(text: $content.value, height: $content.height, fontSize: getFontSize(type: content.type))
                                    .focused($showKeyboard)
                                // Approx Height Based on Font for First Display...
                                    .frame(height: content.height == 0 ? getFontSize(type: content.type) * 2 : content.height)
                                    .background(
                                    
                                        Text(content.type.rawValue)
                                            .font(.system(size: getFontSize(type: content.type)))
                                            .foregroundColor(.gray)
                                            .opacity(content.value == "" ? 0.7 : 0)
                                            .padding(.leading,5)
                                        
                                        ,alignment: .leading
                                    )
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 30)
                        .contentShape(Rectangle())
                        .contentShape(Rectangle())
                        // Swipe To Delete...
                        .gesture(DragGesture().onEnded({ value in
                            
                            if -value.translation.width < (UIScreen.main.bounds.width / 2.5) && !content.showDeleteAlert{
                                // Showing ALert....
                                content.showDeleteAlert = true
                            }
                            
                        }))
                        .alert("Sure to delete this content?", isPresented: $content.showDeleteAlert) {
                            
                            Button("Delete",role: .destructive){
                                // Deleting Content...
                                let index = postContent.firstIndex { currentPost in
                                    return currentPost.id == content.id
                                } ?? 0
                                
                                withAnimation{
                                    postContent.remove(at: index)
                                }
                            }
                        }
                    }
                    
                    // Menu Button to insert Post Content...
                    Menu {
                        
                        // Iterating Cases...
                        ForEach(PostType.allCases,id: \.rawValue){type in
                            
                            Button(type.rawValue){
                                let isDirectURL = type == .Image
                                            let newContent = PostContent(value: "", type: type, isDirectURL: isDirectURL)
                                withAnimation{
                                    postContent.append(newContent)
                                }
                                            if type == .ImageUpload {
                                                showImagePicker = true
                                                imageUploaded = false
                                            }
                                // Appending New PostCOntent...
                            }
                        }
                        
                    } label: {
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(.primary)
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity,alignment: .leading)

                }
                .padding()
            })
            // Changing Post Title Dynamic...
            .navigationTitle(postTitle == "" ? "Post Title" : postTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    if !showKeyboard{
                        Button("Cancel"){
                            blogData.createPost.toggle()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    if showKeyboard{
                        Button("Done"){
                            // Closing Keyboard...
                            showKeyboard.toggle()
                        }
                    }
                    else{
                        Button("Post"){
                            blogData.writePost(content: postContent,author: authorName,postTitle: postTitle)
                        }.foregroundColor(Color.white)
                        .disabled(authorName == "" || postTitle == "")
                    }
                }
            }
//            .background(Color(hex: 0x010b26))
        }
//        .background(Color(hex: 0x010b26))
    }
}

struct CreatePost_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

// Dynamic height...
func getFontSize(type: PostType)->CGFloat{
    // Your Own...
    switch type {
    case .Header:
        return 24
    case .SubHeading:
        return 22
    case .Paragraph:
        return 18
    case .Image:
        return 18
    case .ImageUpload:
        return 18
    }
}

// Async Image....
struct WebImage: View{
    
    var url: String
    
    var body: some View{
        
        AsyncImage(url: URL(string: url)) { phase in
            
            if let image = phase.image{
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 30,height: 250)

                    .cornerRadius(15)
            }
            else{
                
                if let _ = phase.error{
                    Text("Failed to load Image")
                }
                else{
                    ProgressView()
                }
            }
        }
        .frame(height: 250)

    }
}
