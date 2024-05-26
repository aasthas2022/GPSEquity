//
//  BlogViewModel.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseStorage


class BlogViewModel: ObservableObject{
    @Published var posts: [Post]?
    
    @Published var alertMsg = ""
    @Published var showAlert = false
    
    @Published var createPost = false
    @Published var isWriting = false
    func fetchPosts() async {
        do {
            let db = Firestore.firestore().collection("Blog")
            let posts = try await db.getDocuments()
            DispatchQueue.main.async { // Make UI updates on the main thread
                self.posts = posts.documents.compactMap { post in
                    return try? post.data(as: Post.self)
                }
            }
        } catch {
            alertMsg = error.localizedDescription
            showAlert.toggle()
        }
    }
    
    func deletePost(post: Post) {
        guard let user = Auth.auth().currentUser else {
            self.alertMsg = "You must be logged in to delete posts."
            self.showAlert = true
            return
        }

        guard post.authorUID == user.uid else {
            self.alertMsg = "You can only delete your own posts."
            self.showAlert = true
            return
        }

        guard let postIndex = posts?.firstIndex(where: { $0.id == post.id }) else {
            self.alertMsg = "Post not found."
            self.showAlert = true
            return
        }

        let db = Firestore.firestore()
        if let postId = post.id {
            db.collection("Blog").document(postId).delete { error in
                if let error = error {
                    print("Error deleting post: \(error)")
                    self.alertMsg = "Failed to delete post: \(error.localizedDescription)"
                    self.showAlert = true
                } else {
                    withAnimation {
                        self.posts?.remove(at: postIndex)
                    }
                }
            }
        }
    }

    func writePost(content: [PostContent],author: String,postTitle: String){
        guard Auth.auth().currentUser != nil else {
            return
        }
        do{
            withAnimation{
                isWriting = true
            }
            let post = Post(authorUID: Auth.auth().currentUser!.uid,title: postTitle, author: author, postContent: content, date: Timestamp(date: Date()))
            let _ = try Firestore.firestore().collection("Blog").document().setData(from: post)
            withAnimation{
                posts?.append(post)
                isWriting = false
                createPost = false
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return completion(.failure(UploadError.invalidImageData))
        }

        let storageRef = Storage.storage().reference()
        let storagePath = "images/\(UUID().uuidString).jpg"

        storageRef.child(storagePath).putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.child(storagePath).downloadURL { url, error in
                if let url = url {
                    completion(.success(url.absoluteString))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }

    enum UploadError: Error {
        case invalidImageData
    }
}
