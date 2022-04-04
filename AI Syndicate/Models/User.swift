//
//  User.swift
//  AI Syndicate
//
//  Created by Ерасыл Кенесбек on 25.08.2021.
//

import Foundation
import UIKit

var currentUser: User?

struct User {
    let username: String
    let email: String
    let typeOfUser: String
    let profileImage: String?
    var likedStartUpPostIds: [String] = []
    var likedNewsPostIds: [String] = []
    var investedStartUps: [String] = []
}
