//
//  EncryptManager.swift
//  murmr
//
//  Created by Sam on 17/02/2024.
//

import SwiftUI
import CryptoSwift
import Security

enum EncryptManagerErrors: Error {
    case keyIsNotRSA
    case keyRetrievalError
    case publicKeyFailure
    case secKeyBlockSizeFailure
    case uuidFailure
    case passwordGenerationFailure
}

class EncryptManager {
    // These two need to be random and sent across
//    private var salt: [UInt8] = Array("saltythesealionneverhurtanyone".utf8)
//    private var iv: [UInt8] = Array("nacllcannacllcan".utf8)
    private var saltSize = AES.blockSize
    private var ivSize = AES.blockSize
    
    private var salt: [UInt8] {
        return AES.randomIV(saltSize)
    }
    
    private var iv: [UInt8] {
        return AES.randomIV(ivSize)
    }
    
    public func encryptData(data: Data, publicKey: SecKey) async throws -> (Data, String) {
        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
        
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw EncryptManagerErrors.keyIsNotRSA
        }
        
        guard let password = SecCreateSharedWebCredentialPassword() as? String else {
            throw EncryptManagerErrors.passwordGenerationFailure
        }
        
        // Generate a key from a `password`.
        let key = try PKCS5.PBKDF2(
            password: password.bytes,
            salt: salt,
            iterations: 4096,
            keyLength: 32, /* AES-256 */
            variant: .sha2(.sha256)
        ).calculate()
        
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        
        /* Encrypt Data */
        let encryptedBytes = try aes.encrypt(data.bytes)
        let encryptedVoiceMessage = Data(encryptedBytes)
        
        /* Prepend salt and iv to the encrypted file */
        
        
        /* Encrypt the key using the public RSA key */
        guard (key.count < (SecKeyGetBlockSize(publicKey)-130)) else {
            throw EncryptManagerErrors.secKeyBlockSizeFailure
        }
        
        print("Encrypted voice file with key: \(key)")
        
        var error: Unmanaged<CFError>?
        guard let encryptedAESKey = SecKeyCreateEncryptedData(publicKey,
                                                              algorithm,
                                                              Data(key) as CFData,
                                                              &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return (encryptedVoiceMessage, encryptedAESKey.base64EncodedString())
    }
    
    public func decryptData(data: Data, key: String, uuid: UUID) async throws -> Data {
        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
        
        guard let base64Key = key.data(using: .utf8) else {
            throw EncryptManagerErrors.keyRetrievalError
        }
        
        guard let keyData = Data(base64Encoded: base64Key) else {
            throw EncryptManagerErrors.keyRetrievalError
        }
        
        let privateKey = try await KeyManager.getPrivateKey(uuid: uuid.uuidString)
        
        /* Decrypt EAS key from private key */
        var privError: Unmanaged<CFError>?
        guard let decryptedKey = SecKeyCreateDecryptedData(privateKey,
                                                           algorithm,
                                                           keyData as CFData,
                                                           &privError) as Data? else {
            throw privError!.takeRetainedValue() as Error
        }
        
        /* AES cryptor instance */
        print("Decrypting using iv \(iv)")
        print("Decrypting with key \(decryptedKey.bytes)")
        
        let aes = try AES(key: decryptedKey.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
        
        print("Calling AES decrypt")
        /* Decrypt Data */
        let decryptedBytes = try aes.decrypt(data.bytes)
        let decryptedData = Data(decryptedBytes)
        
        return decryptedData
    }
}
