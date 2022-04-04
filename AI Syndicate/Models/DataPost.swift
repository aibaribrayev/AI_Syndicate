//
//  DataPost.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 27.09.2021.
//

import Foundation

struct DataPost {
    let postType: String
    let identifier: String
    var userEmail: String
    var dateTime: String
    var title: String
    var caption: String
    var image: URL?
    var numberOfComments: Int?
    var numberOfLikes: Int?
    
    init(startupPost post: Post) {
        self.identifier = post.identifier
        self.userEmail = post.userEmail
        self.dateTime = post.dateTime
        self.title = post.title
        self.caption = post.caption
        self.image = post.image
        self.numberOfComments = post.numberOfComments
        self.numberOfLikes = post.numberOfLikes
        self.postType = "posts"
    }
    
    init(newsPost post: NewsPost) {
        self.identifier = post.identifier
        self.userEmail = post.userEmail
        self.dateTime = post.dateTime
        self.title = post.title
        self.caption = post.caption
        self.image = post.image
        self.numberOfComments = post.numberOfComments
        self.numberOfLikes = post.numberOfLikes
        self.postType = "news"
    }
}
