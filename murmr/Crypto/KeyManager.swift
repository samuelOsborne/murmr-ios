//
//  KeyManager.swift
//  SupabaseAuth
//
//  Created by Sam on 28/11/2023.
//

import Foundation
import SwiftUI

enum KeyManagerErrors: Error {
    case generateKeyTagError
    case generatePublicKeyError
    case privateKeyExistsError
    case privateKeyMissingError
}


/// RSA key managing class
class KeyManager {
    @ObservedObject var authViewModel: AuthViewModel = AuthViewModel.shared
    
    var privateKeyTag: Data?
    
    init(privateKeyTag: Data?) {
        if privateKeyTag != nil {
            self.privateKeyTag = privateKeyTag
        } else {
            let uuid = authViewModel.uuid?.uuidString.isEmpty ?? nil
            
            if uuid != nil {
                self.privateKeyTag = "com.murmr.keys.\(uuid!)".data(using: .utf8)!
            }
        }
    }
    
    static public func generatePrivateKey(uuid: String) throws {
        let privateKeyTag = try generateKeyTag(uuid: uuid)
        
        // This first block is to check if the private key has already been generated
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: privateKeyTag,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                    
                                    kSecReturnRef as String: true]
        var item: CFTypeRef?
        
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // We've retrieved a private key, which means this method has been called before
        if status == errSecSuccess {
            throw KeyManagerErrors.privateKeyExistsError
        }
        
        // kSecAttrIsPermanent stores the key inside the keychain
        let attributes: [String: Any] =
        [kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String:      2048,
         kSecAttrCanEncrypt as String: false,
         kSecPrivateKeyAttrs as String:
            [kSecAttrIsPermanent as String: true,
             kSecAttrApplicationTag as String: privateKeyTag]
        ]
        
        var error: Unmanaged<CFError>?
        guard SecKeyCreateRandomKey(attributes as CFDictionary, &error) != nil else {
            throw error!.takeRetainedValue() as Error
        }
        
    }
    
    static public func getPrivateKey(uuid: String) throws -> SecKey {
        do {
            let privateKeyTag = try generateKeyTag(uuid: uuid)
            
            let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: privateKeyTag,
                                           kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                           kSecReturnRef as String: true]
            
            var item: CFTypeRef?
            
            let status = SecItemCopyMatching(getquery as CFDictionary, &item)
            
            guard status == errSecSuccess else { throw KeyManagerErrors.privateKeyMissingError }
            
            let privateKey = item as! SecKey
            
            return privateKey
        } catch let error {
            throw error
        }
    }
    
    static public func getPublicKey(uuid: String) throws -> SecKey {
        do {
            let privateKeyTag = try generateKeyTag(uuid: uuid)
            
            let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: privateKeyTag,
                                           kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                           kSecReturnRef as String: true]
            
            var item: CFTypeRef?
            
            let status = SecItemCopyMatching(getquery as CFDictionary, &item)
            
            guard status == errSecSuccess else { throw KeyManagerErrors.privateKeyMissingError }
            
            let privateKey = item as! SecKey
            
            // Generate public key from private
            let publicKey = SecKeyCopyPublicKey(privateKey)
            
            guard let checkedPublicKey = publicKey else {
                throw KeyManagerErrors.generatePublicKeyError
            }
            
            return checkedPublicKey
        } catch let error {
            throw error
        }
    }
    
    static public func getPublicKeyForTransfer(uuid: String) throws -> String {
        do {
            let privateKeyTag = try generateKeyTag(uuid: uuid)
            
            let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: privateKeyTag,
                                           kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                           kSecReturnRef as String: true]
            
            var item: CFTypeRef?
            
            let status = SecItemCopyMatching(getquery as CFDictionary, &item)
            
            guard status == errSecSuccess else { throw KeyManagerErrors.privateKeyMissingError }
            
            let privateKey = item as! SecKey
            
            // Generate public key from private
            let publicKey = SecKeyCopyPublicKey(privateKey)
            
            guard let checkedPublicKey = publicKey else {
                throw KeyManagerErrors.generatePublicKeyError
            }
            
            // Convert the public key to transferable data
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCopyExternalRepresentation(checkedPublicKey, &error) as? Data else {
                throw error!.takeRetainedValue() as Error
            }
            
            return data.base64EncodedString()
        } catch let error {
            throw error
        }
    }
    
    static private func generateKeyTag(uuid: String) throws -> Data {
        if let data = "com.murmr.keys.\(uuid)".data(using: .utf8) {
            return data
        }
        
        throw KeyManagerErrors.generateKeyTagError
    }
}
