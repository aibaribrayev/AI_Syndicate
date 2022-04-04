//
//  Comment.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 21.09.2021.
//

import Foundation
class Comment {
    //var createdBy: User
    var identifier: String = ""
    var userEmail: String = ""
    var dateTime: String = ""
    var text: String = ""
    var parentComment: Comment?
    var replies: [Comment]?
}
