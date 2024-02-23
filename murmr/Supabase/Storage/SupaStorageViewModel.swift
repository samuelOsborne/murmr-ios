//
//  SupaStorageViewModel.swift
//  SupabaseAuth
//
//  Created by Sam on 17/12/2023.
//

import Foundation

class SupaStorageViewModel: ObservableObject {
    private let supaStorage = SupaStorage()
    public static let shared = SupaStorageViewModel()
    
    @MainActor
    /// Downloads a file from Supabase Storage and returns it.
    /// - Returns: Data content of the file.
    func downloadFile(filesTableId: Int) async throws -> Data? {
        if let data = try await supaStorage.downloadFile(filesId: filesTableId) {
            return data
        }
        
        return nil
    }
    
    @MainActor
    /// Uploads a file to Supabase Storage.
    /// - Parameter fileName: Name of the murmur, fileData: The voice file data, fileRecipient: Username of the recipient
    func uploadFile(fileName: String, fileData: Data, fileRecipient: String) async throws {
        try await supaStorage.uploadFile(fileName: fileName, fileData: fileData, fileRecipient: fileRecipient)
    }
}
