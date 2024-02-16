//
//  BarView.swift
//  murmr
//
//  Created by Sam on 24/12/2023.
//

import SwiftUI
import AVFoundation
import AVKit

struct AudioBarView: View {
    @StateObject private var audioVM: AudioPlayViewModel
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 70) / 2 // between 0.1 and 35
        
        return CGFloat(level * (40/35))
    }
    
    init(audio: String) {
        _audioVM = StateObject(wrappedValue: AudioPlayViewModel(url: URL(string: audio)!, sampels_count: Int(UIScreen.main.bounds.width * 0.6 / 4)))
    }
    
    var body: some View {
        VStack( alignment: .leading ) {
            
            HStack(alignment: .center, spacing: 10) {
                
                Button {
                    if audioVM.isPlaying {
                        audioVM.pauseAudio()
                    } else {
                        audioVM.playAudio()
                    }
                } label: {
                    Image(systemName: !(audioVM.isPlaying) ? "play.fill" : "pause.fill" )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)

                }
                
                HStack(alignment: .center, spacing: 2) {
                    if audioVM.soundSamples.isEmpty {
                        ProgressView()
                    } else {
                        ForEach(audioVM.soundSamples, id: \.self) { model in
                            BarView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                        }
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.6)
            }
            
            
        }.padding(.vertical, 8)
            .padding(.horizontal)
            .frame(minHeight: 0, maxHeight: 50)
    }
}

struct BarView: View {
    let value: CGFloat
    var color: Color = Color.init(hex: "D9D9D9")
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(10)
                .frame(width: 2, height: value)
        }
    }
}
