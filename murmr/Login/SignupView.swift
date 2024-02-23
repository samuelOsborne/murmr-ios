//
//  SignupView.swift
//  SupabaseAuth
//
//  Created by Sam on 25/11/2023.
//

import Foundation

import SwiftUI

struct SignupView: View {
    @ObservedObject var authViewModel: AuthViewModel = AuthViewModel.shared
    @ObservedObject var navigationVM : NavigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        VStack(spacing:28) {
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 8)
                .fill(.pink)
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 100)
            
            TextField("Enter username", text: $authViewModel.username).autocapitalization(.none)
            TextField("Enter email", text: $authViewModel.email).autocapitalization(.none)
            SecureField("Enter password", text: $authViewModel.password)
            
            Button(action: {
                Task {
                    await authViewModel.signup(email: authViewModel.email,
                                               password: authViewModel.password,
                                               username: authViewModel.username)
                }
            }, label: {
                if(authViewModel.isLoading){
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                else{
                    Text("SignUp")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            })
            .padding(.horizontal,8)
            .buttonStyle(.borderedProminent)
            .disabled(!authViewModel.validPassword())
            
            //            .disabled(!authViewModel.validEmail())
            //            .disabled(!authViewModel.validPassword())
            
            Text(authViewModel.errorMessage)
                .foregroundStyle(.red)
            
            Spacer()
            NavigationLink("Already have a account", destination: LoginView())
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack{
        SignupView()
    }
}
