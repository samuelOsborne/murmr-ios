//
//  Header.swift
//  murmr
//
//  Created by Sam on 30/01/2024.
//

import Foundation
import SwiftUI

struct Header: View {
    var body: some View {
        HStack {
            //            NavigationView {
            Text("Your Murmrs").font(.system(size: 25))
                .bold().frame(alignment: .leading)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .deleteDisabled(true)
            
            Spacer()
            
            Button(action: {
                print("Going to profile view")
            }, label: {
                Image(systemName: "person.crop.circle").font(.system(size: 25)).foregroundStyle(.white)
            })
            //            }
        }
        .padding()
        .padding(.bottom, 0)
    }
}
