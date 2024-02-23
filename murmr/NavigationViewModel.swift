//
//  NavigationViewModel.swift
//  SupabaseAuth
//
//  Created by Sam on 25/11/2023.
//

import Foundation
import SwiftUI
import Combine

enum AuthRoute: String, Hashable{
    case Login
    case Signup
    case Home
}

class NavigationViewModel : ObservableObject {
    @Published var authPath = NavigationPath()
    public static let shared = NavigationViewModel()
    
    
    func navigate(authRoute:AuthRoute)  {
        authPath.append(authRoute)
    }
    
    func popToRoot(){
        authPath.removeLast(authPath.count)
    }
    
    func pop()  {
        authPath.removeLast()
    }
}
