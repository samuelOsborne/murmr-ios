//
//  murmrList.swift
//  murmr
//
//  Created by Sam on 26/12/2023.
//

import SwiftUI
import Foundation

struct Murmr : Identifiable {
    let id = UUID()
    let file: Files
}

struct userExample: Identifiable, Equatable {
    var username: String
    let id = UUID()
    var murmrs: [murmrItem]
    
    init(username: String) {
        self.username = username
        self.murmrs = [murmrItem()]
    }
    static func == (lhs: userExample, rhs: userExample) -> Bool {
        lhs.id == rhs.id
    }
}

struct murmrList: View {
    @State private var items: [userExample] = [
        userExample(username: "🤠 Sam"),
        userExample(username: "🎃 Liz"),
        userExample(username: "🦓 Zebra")
    ]
    @State private var sampleItems: [userExample] = [
        userExample(username: "🤠 Sam"),
        userExample(username: "🎃 Liz"),
        userExample(username: "🦓 Zebra")
    ]
    
    @State var toggleActivated = false
    @State var murmrs: [Murmr] = []
    @State private var searchText = ""
    
    private let database = DatabaseViewModel.shared
    private let storage = SupaStorageViewModel.shared

    var body: some View {
        NavigationView {
            VStack {
                List(murmrs) { murmr in
                    Text(murmr.file.title!)
                }
                List {
                    ForEach(murmrs, id: \.id) { item in
                        Section(header:
                                    HStack {
                            Button(action: {
                                withAnimation {
                                    toggleActivated.toggle()
                                }
                            }, label: {
                                if !toggleActivated {
                                    Image(systemName: "arrowtriangle.down.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 17))
                                } else {
                                    Image(systemName: "arrowtriangle.right.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 17))
                                }
                            })
                            .font(Font.caption)
                            .foregroundColor(.white)
                            .frame(alignment: .topLeading)
                            
//                            Text(item.username).font(.system(size: 35))
//                                .bold().frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.bottom)
//                                .foregroundStyle(.white)
//                                .deleteDisabled(true)
                        }
                                
                                
                        ) {
                            //                        if item.toggled {
//                            ForEach(item.murmrs) { murmr in
//                                murmr
//                            }.onDelete { indices in
//                                deleteItem(from: item, at: indices)
//                            }
                            //                        }
                        }
                        
                    }
                    
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                
                //                List {
                //                    ForEach(items, id: \.id) { item in
                //                        if (!item.murmrs.isEmpty) {
                //                            Section(header:
                //                                        HStack {
                //                                Button(action: {
                //                                    withAnimation {
                //                                        toggleActivated.toggle()
                //                                    }
                //                                }, label: {
                //                                    if !toggleActivated {
                //                                        Image(systemName: "arrowtriangle.down.fill")
                //                                            .foregroundStyle(.white)
                //                                            .font(.system(size: 17))
                //                                    } else {
                //                                        Image(systemName: "arrowtriangle.right.fill")
                //                                            .foregroundStyle(.white)
                //                                            .font(.system(size: 17))
                //                                    }
                //                                })
                //                                .font(Font.caption)
                //                                .foregroundColor(.white)
                //                                .frame(alignment: .topLeading)
                //
                //                                Text(item.username).font(.system(size: 35))
                //                                    .bold().frame(maxWidth: .infinity, alignment: .leading)
                //                                    .padding(.bottom)
                //                                    .foregroundStyle(.white)
                //                                    .deleteDisabled(true)
                //                            }
                //
                //
                //                            ) {
                //                                //                        if item.toggled {
                //                                ForEach(item.murmrs) { murmr in
                //                                    murmr
                //                                }.onDelete { indices in
                //                                    deleteItem(from: item, at: indices)
                //                                }
                //                                //                        }
                //                            }
                //                        }
                //                    }
                //
                //                }
                //                .listStyle(.plain)
                //                .listRowSeparator(.hidden)
                
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Text("Murmur")
                        .font(.system(size: 25))
                        .bold()
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { searchText in
            if !searchText.isEmpty {
                items = sampleItems.filter { $0.username.contains(searchText) }
            } else {
                items = sampleItems
            }
        }
        .onAppear {
            Task {
                let data = await database.listSharedMurmrs()
                
                for d in data {
                    murmrs.append(Murmr(file: d))
                    
                    guard let fileId = d.id else {
                        return ;
                    }
                                        
                    do {
                        try await storage.downloadFile(filesTableId: fileId)
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func deleteItem(from user: userExample, at offsets: IndexSet) {
        if let index = items.firstIndex(where: { $0.id == user.id }) {
            items[index].murmrs.remove(atOffsets: offsets)
            
            // Check if murmurs array is empty, remove the userExample
            if items[index].murmrs.isEmpty {
                //                items.remove(at: index)
            }
        }
    }
}
