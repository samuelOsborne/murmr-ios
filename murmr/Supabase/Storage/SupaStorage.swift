//
//  SupaStorage.swift
//  SupabaseAuth
//
//  Created by Sam on 16/12/2023.
//

import Foundation
import Supabase

enum StorageErrors: Error {
    case downloadFileError(error: String)
    case fileUploadError(reason: String)
    case encryptionError(reason: String)
    case fileEntryCreationError(reason: String)
    case fileSharesLinkCreationError(reason: String)
    case keyRetrievalError(reason: String)
}

class SupaStorage {
    private let client = SupaClient.client
    private let database = DatabaseViewModel.shared
    private let encryptManager = EncryptManager()
    
    // MARK: uploadFile
    func uploadFile(fileName: String, fileData: Data, fileRecipient: String) async throws {
        do {
            print("Attempting upload...")
            let currUUID = try await client.auth.user().id
            
            // File path on Supabase storage
            let filePath = "\(currUUID.uuidString)/\(fileName)"
            
            // Get the recipients UUID
            guard let recipientUUID = await database.getUUID(username: fileRecipient) else { throw  StorageErrors.fileUploadError(reason: "Recipient UUID is null.")}
            
            // Get the recipient's public key for enrcyption
            guard let recipientPublicKey = await database.getPublicKey(username: fileRecipient) else { throw
                StorageErrors.fileUploadError(reason: "Failed to fetch recipient public key.")}
            
            let (encryptedData, encryptedKey) = try await encryptManager.encryptData(data: fileData, publicKey: recipientPublicKey)
            
            let uploadedFile = try await client.storage
                .from("bucket_0")
                .upload(
                    path: filePath,
                    file: encryptedData,
                    options: FileOptions(
                        cacheControl: "3600",
                        upsert: false
                    )
                )
            
            print("Uploaded file result \(uploadedFile)")
            
            let fileId: [Storage] = try await SupaClient.storageClient.database
                .from("objects")
                .select("id")
                .eq("name", value: filePath)
                .execute().value
            
            print("Creating files entry...")
            
            if let id = fileId.first?.id {
                // TODO: Add encrypted AES key here
                await database.createFilesEntry(userId: currUUID, fileId: id, title: fileName, key: encryptedKey)
            } else {
                print("File id is null")
                throw StorageErrors.fileEntryCreationError(reason: "File id is null")
            }
            
            print("Creating shares entry")
            
            let filesTableId: [Files] = try await client.database
                .from("files")
                .select("id")
                .eq("title", value: fileName)
                .execute().value
            
            if let id = filesTableId.first?.id {
                await database.createSharesLink(fromUUID: currUUID, toUUID: recipientUUID, filesTableId: id)
            } else {
                print("File id is null.")
                throw StorageErrors.fileSharesLinkCreationError(reason: "filesTableId is null")
            }
            
            print("Shares entry done!")
            
        } catch let error {
            print("Error in uploading file \(error)")
            throw error
        }
    }
    
//    func encryptData(data: Data, publicKey: SecKey) async throws -> Data {
//        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
//        
//        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
//            throw EncryptManagerErrors.keyIsNotRSA
//        }
//        
//        print("Data count \(data.count)")
//        print("SecKeyGetBlockSize \(SecKeyGetBlockSize(publicKey)-130)")
//
//        guard (data.count < (SecKeyGetBlockSize(publicKey)-130)) else {
//            throw EncryptManagerErrors.secKeyBlockSizeFailure
//        }
//        
//        var error: Unmanaged<CFError>?
//        guard let encryptedVoiceMessage = SecKeyCreateEncryptedData(publicKey,
//                                                                    algorithm,
//                                                                    data as CFData,
//                                                                    &error) as Data? else {
//            throw error!.takeRetainedValue() as Error
//        }
//        
//        return encryptedVoiceMessage
//    }
    
//    func decryptFile(file: Data) async throws -> Data {
//        let uuid = try await client.auth.user().id
//        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
//        
//        
//        let privateKey = try await KeyManager.getPrivateKey(uuid: uuid.uuidString)
//        
//        
//        var error: Unmanaged<CFError>?
//        var privError: Unmanaged<CFError>?
//        guard let decryptedData = SecKeyCreateDecryptedData(privateKey,
//                                                            algorithm,
//                                                            file as CFData,
//                                                            &privError) as Data? else {
//            throw error!.takeRetainedValue() as Error
//        }
//        
//        return decryptedData
//    }
    
    /// Downloads a file from Supabase Storage.
    /// - Parameter filesId: Primary key of the "Files" table.
    func downloadFile(filesId: Int) async throws -> Data? {
        let files: [Files] = try await client.database
            .from("files")
            .select("file_id, key")
            .eq("id", value: filesId)
            .execute()
            .value
        
        let currUUID = try await client.auth.user().id
        
        for file in files {
            print(file)
            if let fileIdToGet = file.file_id {
                // Get the name (= file path) from the storage/objects table
                let storageFile: [Storage] = try await SupaClient.storageClient.database
                    .from("objects")
                    .select("name")
                    .eq("id", value: fileIdToGet)
                    .execute().value
                
                if let name = storageFile.first?.name {
                    print("Getting \(name)")
                    
                    let data = try await client.storage
                        .from("bucket_0")
                        .download(path: name)
                    
//                    print("File contents of download file: \(String(decoding: data, as: UTF8.self))")
                    
                    print("Commencing decrypting..")

                    guard let key = file.key else {
                        throw StorageErrors.keyRetrievalError(reason: "File key is null")
                    }
                    
                    print("Got key decrypting data")
                    let decryptedData = try await encryptManager.decryptData(data: data, key: key, uuid: currUUID)
                    
                    /* For testing purposes */
                    try Utils.writeDataToTmpFile(data: decryptedData, fileName: "decrypted-data.m4a")
                    
                    return decryptedData
                }
            }
        }
        
        throw StorageErrors.downloadFileError(error: "Possible error retrieving file from storage table.")
    }
}
