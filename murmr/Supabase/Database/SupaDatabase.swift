//
//  SupaDatabase.swift
//  SupabaseAuth
//
//  Created by Sam on 16/12/2023.
//

import Foundation
import Supabase

enum SupaDatabaseErrors: Error {
    case UserNotFound
    case PublicKeyNotFound
    case UUIDNotFound
}

class SupaDatabase {
    private let client = SupaClient.client
    
    // MARK: fetchMurmrsForCurrentUser
    
    /// Finds and returns the Files associated with every Share linked to the current user.
    /// - Returns: Every Files row shared with the current user.
    func fetchMurmrsForCurrentUser() async throws -> [Files] {
        let uuid = try await client.auth.user().id.uuidString.lowercased()
        var files: [Files] = []
        
        let shares: [Shares] = try await client.database
            .from("shares")
            .select("files_id")
            .eq("recipient_id", value: uuid)
            .execute()
            .value
        
        for share in shares {
            if let filesId = share.files_id {
                let singleFile: [Files] = try await client.database
                    .from("files")
                    .select("*")
                    .eq("id", value: filesId)
                    .execute()
                    .value
                
                if singleFile.first != nil {
                    files.append(singleFile.first!)
                }
            }
        }
        
        return files
    }
    
    func getCurrentUsername() async throws -> String? {
        let uuid = try await client.auth.user().id.uuidString.lowercased()
        let user: [Profile] = try await client.database.from("profiles").select("username").eq("id", value: uuid).execute().value
        
        if user.count == 0 {
            throw SupaDatabaseErrors.UserNotFound
        }
        
        if let username = user.first?.username {
            return username
        }
        
        throw SupaDatabaseErrors.UserNotFound
    }
    
    func getPublicKeyOfUser(username: String) async throws -> String {
        let user: [Profile] = try await client.database.from("profiles").select("public_key").eq("username", value: username).execute().value
        
        if user.count == 0 {
            throw SupaDatabaseErrors.UserNotFound
        }
        
        if let pubKey = user.first?.public_key {
            return pubKey
        }
        
        throw SupaDatabaseErrors.PublicKeyNotFound
    }
    
    func getUUID(username: String) async throws -> UUID {
        let user: [Profile] = try await client.database.from("profiles").select("id").eq("username", value: username).execute().value
        
        if user.count == 0 {
            throw SupaDatabaseErrors.UserNotFound
        }
        
        if let id = user.first?.id {
            return id
        }
        
        throw SupaDatabaseErrors.UUIDNotFound
    }
    
    func createSharesLink(fromUUID: UUID, toUUID: UUID, filesTableId: Int) async throws {
        let shares = Shares(from_id: fromUUID.uuidString, recipient_id: toUUID.uuidString, files_id: filesTableId)
        
        try await client.database
            .from("shares")
            .insert(shares)
            .execute()
    }
    
    func createFilesEntry(userID: UUID, fileId: UUID, title: String, key: String) async throws {
        let file: Files = Files(id: nil, user_id: userID, file_id: fileId, title: title, key: key)
        
        try await client.database
            .from("files")
            .insert(file)
            .execute()
    }
}
