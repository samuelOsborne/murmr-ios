//
//  LoginView.swift
//  SupabaseAuth
//
//  Created by Sam on 25/11/2023.
//

import Foundation

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel = AuthViewModel.shared
    @ObservedObject var navigationVM : NavigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        NavigationStack(path: $navigationVM.authPath) {
            VStack(spacing:28) {
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(.pink)
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 100)

                TextField("Enter email", text: $authViewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                SecureField("Enter password", text: $authViewModel.password)
                
                Button(action: {
                    Task {
                        await AuthViewModel.shared.signIn(email: authViewModel.email, password: authViewModel.password)
                    }
                }, label: {
                    if (AuthViewModel.shared.isLoading){
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    else{
                        Text("SignIn")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                })
                .padding(.horizontal,8)
                .buttonStyle(.borderedProminent)
                .disabled(!authViewModel.validPassword())
//                .disabled(!authViewModel.validEmail())
                
                Text(AuthViewModel.shared.errorMessage)
                    .foregroundStyle(.red)
                
                Spacer()
                NavigationLink("SignUp", destination: SignupView())
            }
            .textFieldStyle(.roundedBorder)
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack{
        LoginView()
    }
}
