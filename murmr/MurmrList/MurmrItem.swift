//
//  murmrItem.swift
//  murmr
//
//  Created by Sam on 26/12/2023.
//

import SwiftUI
import Foundation

struct murmrItem: View, Identifiable {
    let id = UUID()
    
    var body: some View {
        Section {
            HStack {
                AudioBarView(audio: "https://huggingface.co/datasets/Osbro/Audio/resolve/main/Amber%20-%20VYEN%201.mp3")
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 50, style: .continuous).fill(Color.init(hex: "D9D9D9")).frame(height: 50, alignment: .leading)
            )
        } header: {
            HStack {
                Text("Heyyy 👋").font(.system(size: 20))
            }.frame(maxWidth: .infinity, alignment: .leading).deleteDisabled(true)
        }
        .headerProminence(.increased)
        .listRowSeparator(.hidden)
    }
}
