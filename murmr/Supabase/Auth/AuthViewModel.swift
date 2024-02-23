//
//  SupabaseAuthViewModel.swift
//  SupabaseAuth
//
//  Created by Sam on 25/11/2023.
//

import Foundation
import Combine
import Supabase

enum AuthViewModelErrors: Error {
    case UUIDFailure
}

// Define authentication states
enum AuthState: Hashable {
    case Initial
    case SignIn
    case SignOut
}

class AuthViewModel: ObservableObject {
    public static let shared = AuthViewModel()
    
    // Published properties for SwiftUI views
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var errorMessage: String = ""
    @Published var authState: AuthState = AuthState.Initial
    @Published var isLoading = false
    @Published var uuid: UUID?
    
    // Initialize Supabase authentication
    private var supabaseAuth: SupabaseAuth = SupabaseAuth()
    
    private var supabaseStorage: SupaStorageViewModel = SupaStorageViewModel()
    
    private var keyManager: KeyManager?
    
    private var authStateListenerTask: Task<Void, Never>?
    
    init() {
        authStateListenerTask = Task {
            for await state in await self.authStateListener() {
                print("auth state changed: \(String(describing: state))")
                
                if Task.isCancelled {
                    print("auth state task cancelled, returning.")
                    return
                }
                
                DispatchQueue.main.sync {
                    switch state {
                    case .SignIn: self.authState = .SignIn
                    case .SignOut: self.authState = .SignOut
                    case .Initial:
                        self.authState = .Initial
                    }
                    
                }
            }
        }
    }
    
    deinit {
        authStateListenerTask?.cancel()
    }
    
    // MARK: authStateListener
    func authStateListener() async -> AsyncStream<AuthState> {
        await supabaseAuth.client.auth.authStateChanges.compactMap { event, session in
            switch event {
            case .initialSession: session != nil ? AuthState.SignIn : AuthState.SignOut
            case .signedIn: AuthState.SignIn
            case .signedOut: AuthState.SignOut
            case .passwordRecovery, .tokenRefreshed, .userUpdated, .userDeleted, .mfaChallengeVerified:
                nil
            }
        }
        .eraseToStream()
    }
    
    // MARK: isUserSignIn
    @MainActor
    func isUserSignIn() async {
        do {
            try await supabaseAuth.loginUser()
            
            self.uuid = try await self.getCurrentUUID()
            
            authState = AuthState.SignIn
        } catch _ {
            authState = AuthState.SignOut
        }
    }
    
    // MARK: getUUID
    @MainActor
    private func getCurrentUUID() async throws -> UUID? {
        do {
            let uuid = try await supabaseAuth.client.auth.user().id
            
            return uuid
        } catch let error {
            throw error
        }
    }
    
    // MARK: signup
    @MainActor
    func signup(email: String, password: String, username: String) async {
        do {
            isLoading = true
            try await supabaseAuth.signUp(email: email, password: password, username: username)
           
            authState = AuthState.SignIn
            isLoading = false
        } catch let error {
            print(error)
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: uploadFile
//    @MainActor
//    func uploadfile(fileName: String, content: Data, recipientUsername: String) async {
//        do {
//            isLoading = true
//            try await supabaseStorage.uploadFile(fileName: fileName, fileData: content, fileRecipient: recipientUsername);
//            isLoading = false
//        } catch let error {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
//    }
    
//    // MARK: downloadFile
//    @MainActor
//    func downloadFile(fileName: String) async {
//        do {
//            isLoading = true
//            guard let currUUID = self.uuid else {
//                throw AuthViewModelErrors.UUIDFailure
//            }
//            
//            let _ = try await supabaseStorage.downloadFile(filesTableId: 10, uuid: currUUID)
//            isLoading = false
//        } catch let error {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
//    }
    
    // MARK: signIn
    @MainActor
    func signIn(email: String, password: String) async {
        do {
            isLoading = true
            try await supabaseAuth.signIn(email: email, password: password)
            
            self.uuid = try await self.getCurrentUUID()
            
            authState = AuthState.SignIn
            isLoading = false
        } catch let error {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: signoutUser
    @MainActor
    func signoutUser() async {
        do {
            try await supabaseAuth.signOut()
            
            self.uuid = nil
            
            print("Signed out !")
            authState = AuthState.SignOut
        } catch let error {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: validEmail
    func validEmail() -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let isEmailValid = self.email.range(of: emailRegex, options: .regularExpression) != nil
        return isEmailValid
    }
    
    // MARK: validPassword
    func validPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let isPasswordValid = self.password.range(of: passwordRegex, options: .regularExpression) != nil
        return isPasswordValid
    }
}
