//
//  Post.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 27.08.2021.
//

import Foundation
import UIKit

struct Post {
    //var createdBy: User
    let identifier: String
    var userEmail: String
    var dateTime: String
    var title: String
    var caption: String
    var image: URL?
    var investmentAmount: Int?
    var numberOfComments: Int?
    var numberOfLikes: Int?
    var numberOfInvestors: Int?
    var investedAmount: Int?
}
