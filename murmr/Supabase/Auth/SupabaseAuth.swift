//
//  SupabaseAuth.swift
//  SupabaseAuth
//
//  Created by Sam on 25/11/2023.
//

import Foundation
import Supabase

class SupabaseAuth {
    let client = SupaClient.client
    
    // MARK: loginUser
    func loginUser() async throws {
        _ = try await client.auth.session
    }
    
    // MARK: signIn
    func signIn(email:String,password:String) async throws {
        try await client.auth.signIn(email: email.lowercased(), password: password)
    }
    
    // MARK: signUp
    func signUp(email: String, password: String, username: String) async throws {
        print("Signing up!")
        
        try await client.auth.signUp(email: email.lowercased(), password: password)
        
        let userId = try await client.auth.user().id
        
        try await KeyManager.generatePrivateKey(uuid: userId.uuidString)
        
        let pubKey = try await KeyManager.getPublicKeyForTransfer(uuid: userId.uuidString)
        
        let profile = Profile(id: userId, username: username, public_key: pubKey)
        
        print("Creating profile...")
        
        try await client.database.from("profiles").insert(profile).execute()
        
    }
    
    // MARK: signOut
    func signOut() async throws{
        try await client.auth.signOut()
    }
}
