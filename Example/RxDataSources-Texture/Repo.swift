//
//  Repo.swift
//  RxDataSources-Texture_Example
//
//  Created by Kanghoon on 19/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct Repo: Codable {
    
    let id: Int
    let name: String
    let fullName: String
    let owner: User
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case fullName = "full_name"
        case owner = "owner"
    }
}

struct User: Codable {
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
    }
}
