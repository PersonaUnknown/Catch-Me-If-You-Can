//
//  User.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/12/22.
//

import Foundation

struct FriendResults : Codable {
    let friends : [User]
}

struct User : Codable{
    let username : String!
    let loggedIn : Bool!
    let inGame: Bool!
}


