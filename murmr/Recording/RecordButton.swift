//
//  recordButton.swift
//  murmr
//
//  Created by Sam on 02/01/2024.
//

import Foundation
import SwiftUI

struct recordButton: View {
    @State private var isSaving = false
    @State private var recordingNameInput = ""
    @State private var usernameDestination = ""
    @ObservedObject var recorderModel: RecorderViewModel = RecorderViewModel()
    @ObservedObject var storage: SupaStorageViewModel = SupaStorageViewModel.shared
    
    var body: some View {
        HStack {
            Button(action: {
                if (!recorderModel.isRecording) {
                    recorderModel.startRecording()
                } else {
                    recorderModel.pauseRecording()
                    isSaving = true
                }
            }) {
                ZStack {
                    Circle().strokeBorder(.white, lineWidth: 3).frame(width: 45)
                    RoundedRectangle(cornerRadius: recorderModel.isRecording ? 3 : 25).fill(.red).frame(width: recorderModel.isRecording ? 20 : 30, height: recorderModel.isRecording ? 20 : 30)
                }
            }
            .controlSize(.large)
            .frame(width: 100, height: 100)
            .scaleEffect(2.0)
            .alert("New Murmr", isPresented: $isSaving) {
                TextField("Recording name", text: $recordingNameInput).textInputAutocapitalization(.never).foregroundColor(.black)
                TextField("Send to", text: $usernameDestination).textInputAutocapitalization(.never).foregroundColor(.black)
                
                // Cancel button
                Button(action: {
                    recorderModel.cancelRecording()
                    
                    isSaving = false
                    
                }, label: {
                    Text("Cancel").foregroundColor(Color.red)
                })
                
                // Save button
                Button("Save") {
                    Task {
                        do {
                            let filePath = try recorderModel.stopRecording(name: recordingNameInput)
                            let fileData = try Utils.getFile(filePath: filePath)
                            
                            /* For testing purposes */
                            try Utils.writeDataToTmpFile(data: fileData, fileName: "unencrypted-data.m4a")
                            
                            try await storage.uploadFile(fileName: recordingNameInput,
                                                   fileData: fileData,
                                                   fileRecipient: usernameDestination)
                            
                            print("Deleting file...")
//                            try? Utils.deleteFile(filePath: filePath)
                            
                        } catch let error {
                            print(error)
                            
                            let _ = Alert(
                                title: Text("Sorry, something broke!"),
                                message: Text(error.localizedDescription),
                                dismissButton: .default(Text("Dismiss"))
                            )                            
//                            Utils.deleteFile(filePath: filePath)
                        }
                        
                        isSaving = false
                        recordingNameInput = ""
                        usernameDestination = ""
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 135)
        .background(Color.init(hex: "1C1C1E"))
    }
}
