//
//  NewsPost.swift
//  AI Syndicate
//
//

import Foundation
struct NewsPost{
    //var createdBy: User
    let identifier: String
    var userEmail: String
    var dateTime: String
    var title: String
    var caption: String
    var image: URL?
    var numberOfComments: Int?
    var numberOfLikes: Int?
}
