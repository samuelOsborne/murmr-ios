//
//  ContentView.swift
//  murmr
//
//  Created by Sam on 17/12/2023.

import SwiftUI

struct ContentView: View {
    @ObservedObject private var authViewModel : AuthViewModel = AuthViewModel.shared
    @ObservedObject private var navigationViewModel : NavigationViewModel = NavigationViewModel.shared
    
    var body: some View {
        Group {
            switch (authViewModel.authState) {
            case .Initial:
                Text("Loading")
            case .SignIn:
                //                HomeView()
//                Header()
                ZStack {
                    VStack {
                        murmrList()
                        recordButton()
                    }
                }
                .ignoresSafeArea(.keyboard)
                .preferredColorScheme(.dark)

            case .SignOut:
                Text("Sign out")
                LoginView()
            }
        }
        .task {
            await authViewModel.isUserSignIn()
        }
    }
}
