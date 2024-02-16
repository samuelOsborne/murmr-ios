//
//  ContentView.swift
//  murmr
//
//  Created by Sam on 17/12/2023.

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var isExpanded = true
    
    var body: some View {
        ZStack {
            VStack {
//                Header()
                murmrList()
                recordButton()
            }
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
        
    }
}

#Preview {
    ContentView()
}
