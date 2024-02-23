//
//  DatabaseModels.swift
//  SupabaseAuth
//
//  Created by Sam on 17/12/2023.
//

import Foundation

struct Shares: Encodable, Decodable {
    let from_id: String?
    let recipient_id: String?
    let files_id: Int?
}

struct Files: Encodable, Decodable{
    let id: Int?
    let user_id: UUID?
    let file_id: UUID?
    let title: String?
    let key: String?
}

struct Storage: Encodable, Decodable {
    var name: String?
    var id: UUID?
}

struct Profile: Encodable, Decodable {
    let id: UUID?
    let username: String?
    let public_key: String?
}
