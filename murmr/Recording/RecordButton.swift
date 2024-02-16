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

                Button(action: {
                    recorderModel.cancelRecording()
                    
                    isSaving = false
                    
                }, label: {
                    Text("Cancel").foregroundColor(Color.red)
                })
                
                Button("Save") {
                    recorderModel.stopRecording(name: recordingNameInput)
                    
                    isSaving = false
                    recordingNameInput = ""
                    usernameDestination = ""
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 135)
        .background(Color.init(hex: "1C1C1E"))
    }
}
