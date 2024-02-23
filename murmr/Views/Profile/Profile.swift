//
//  Profile.swift
//  murmr
//
//  Created by Sam on 16/02/2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authVM : AuthViewModel = AuthViewModel.shared
    @ObservedObject var dbVM : DatabaseViewModel = DatabaseViewModel.shared
    @State private var username: String = "Loading..."
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Text(username)
            
            Button {
                print("Logging out ...")
                
                Task {
                    await authVM.signoutUser()
                }
            } label: {
                Text("Log out")
            }
            
            Button {
                print("Delete account")
            } label: {
                Text("Delete account")
            }
        }
        .onAppear {
            Task {
                if let un = await dbVM.getCurrentUsername() {
                    self.username = un
                }
            }
        }
    }
}
