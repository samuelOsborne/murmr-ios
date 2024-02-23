//
//  StorageViewModel.swift
//  SupabaseAuth
//
//  Created by Sam on 16/12/2023.
//

import Foundation

class DatabaseViewModel: ObservableObject {
    private let supaDatabase = SupaDatabase()
    
    public static let shared = DatabaseViewModel()
    
    @Published var errorMessage: String = ""
    
    @MainActor
    func listSharedMurmrs() async -> [Files] {
        var murmrs: [Files] = []
        
        do {
            murmrs = try await supaDatabase.fetchMurmrsForCurrentUser()
            
            return murmrs
        } catch let error {
            print("Error listing murmrs: \(error)")
            errorMessage = error.localizedDescription
        }
        
        return murmrs
    }
    
    @MainActor
    func getPublicKey(username: String) async -> SecKey? {
        do {
            let publicKeyString = try await supaDatabase.getPublicKeyOfUser(username: username)
            
            print("Getting public key of : \(username) : \(publicKeyString)")
            
            // Convert the public key string to Data
            guard let data = Data(base64Encoded: publicKeyString) else {
                return nil
            }
            
            // Create a dictionary containing key attributes
            let keyDict: [CFString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits: 2048 // Change the key size if needed
            ]
            
            // Create a key format
            var error: Unmanaged<CFError>?
            guard let keyFormat = SecKeyCreateWithData(data as CFData, keyDict as CFDictionary, &error) else {
                if let error = error {
                    throw error.takeRetainedValue() as Error
                }
                return nil
            }
            
            return keyFormat
        } catch let error {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
        
        return nil
    }
    
    @MainActor
    func getUUID(username: String) async -> UUID? {
        do {
            return try await supaDatabase.getUUID(username: username)
        } catch let error {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
        
        return nil
    }
    
    @MainActor
    func getCurrentUsername() async -> String? {
        do {
            return try await supaDatabase.getCurrentUsername()
        } catch let error {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
        
        return nil
    }
    
    @MainActor
    func createSharesLink(fromUUID: UUID, toUUID: UUID, filesTableId: Int) async {
        do {
            try await supaDatabase.createSharesLink(fromUUID: fromUUID, toUUID: toUUID, filesTableId: filesTableId)
        } catch let error {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
    
    @MainActor
    func createFilesEntry(userId: UUID, fileId: UUID, title: String, key: String) async {
        do {
            try await supaDatabase.createFilesEntry(userID: userId, fileId: fileId, title: title, key: key)
        } catch let error {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
}
