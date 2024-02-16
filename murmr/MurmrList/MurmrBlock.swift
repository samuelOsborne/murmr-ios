//
//  contactMurmrList.swift
//  murmr
//
//  Created by Sam on 26/12/2023.
//

import SwiftUI
import Foundation

struct murmrBlock: View, Identifiable {
    @State private var items = ["Item 1"]
    let id = UUID()
    
    var body: some View {

        VStack {
            // Name of user
//            Text("Person 1 💃").font(.system(size: 35)).bold().frame(maxWidth: .infinity, alignment: .leading).padding(.bottom)
            
//            List {
                ForEach(items, id: \.self) { item in
                    murmrItem()
                }.onDelete(perform: deleteItem)
//            }
            
        }
        .listRowSeparator(.hidden)
    }
    private func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
}
