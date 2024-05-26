//
//  Post.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

//Post Model
struct Post: Identifiable, Codable{
    @DocumentID var id: String?
    var authorUID: String
    var title: String
    var author: String
    var postContent: [PostContent]
    var date: Timestamp
    
    enum CodingKeys: String, CodingKey{
        case id
        case title
        case author
        case authorUID
        case postContent
        case date
    }
}

struct PostContent: Identifiable, Codable{
    var id = UUID().uuidString
    var value: String
    var type: PostType
    var image: UIImage?
    var isDirectURL: Bool = true
    
    var height: CGFloat = 0
    var showImage: Bool = false
    var showDeleteAlert: Bool = false
    
    enum CodingKeys: String, CodingKey{
        case id
        case type = "key"
        case value
    }
}

enum PostType: String, CaseIterable, Codable{
    case Header = "Header"
    case SubHeading = "SubHeading"
    case Paragraph = "Paragraph"
    case Image = "Image"
    case ImageUpload = "Image Upload"
}
