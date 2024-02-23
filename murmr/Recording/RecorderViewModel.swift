//
//  Recorder.swift
//  murmr_ios
//
//  Created by Sam on 04/11/2023.
//  Copyright © 2023 com.sam. All rights reserved.
//

import Foundation
import AVFoundation

class RecorderViewModel : NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    @Published var isRecording: Bool = false
    
    @Published var recordingsList = [Recording]()
    
    override init() {
        super.init()
        
        //        fetchAllRecording()
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed setting up recording session!")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        let currDate = Date().formatted(date: .abbreviated, time: .shortened)
        let filename = path.appendingPathComponent("murmr-tmp.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            print("Failed to record!")
        }
    }
    
    func pauseRecording() {
        audioRecorder.pause()
        isRecording = false
    }
    
    func cancelRecording() {
        self.stopRecording()
        audioRecorder.deleteRecording()
    }
    
    func stopRecording() {
        audioRecorder.stop()
        isRecording = false
    }
    
    func stopRecording(name: String) throws -> URL {
        audioRecorder.stop()
        
        recordingsList.append(Recording(id: UUID(), fileURL : audioRecorder.url, createdAt:getFileDate(for: audioRecorder.url), isPlaying: false, name: "\(name)"))
        
        isRecording = false
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentDirectory = URL(fileURLWithPath: path)
        //            let currDate = Date().formatted(date: .abbreviated, time: .shortened)
        
        let originPath = documentDirectory.appendingPathComponent("murmr-tmp.m4a")
        
        // Convert to base64
//        if let fileData = try? Data(contentsOf: originPath, options: .mappedIfSafe) {
//            let base64String = fileData.base64EncodedString(options: .init(rawValue: 0))
//            print(base64String)
//
//            try base64String.write(to: originPath, atomically: true, encoding: .utf8)
//        } else {
//            print("Error reading file data")
//        }
        
        let destinationPath = documentDirectory.appendingPathComponent("murmr-\(name.trimmingCharacters(in: .whitespacesAndNewlines)).m4a")
        
        try? FileManager.default.removeItem(at: destinationPath)
        try FileManager.default.moveItem(at: originPath, to: destinationPath)
        
        print("Moved file to : \(destinationPath)")
        
        return (destinationPath)
        
    }
    
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
           let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    
    //    func fetchAllRecording() {
    //        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
    //
    //        for i in directoryContents {
    //            print(i)
    //
    //            // Todo: Parse the name from the 'i'
    //            // Define a regular expression pattern to match the text between "murmr" and the next hyphen
    //            let pattern = "murmr-(.*?)-"
    //            var name = ""
    //
    //            if let range = i.absoluteString.range(of: pattern, options: .regularExpression) {
    //                let match = i.absoluteString[range]
    //                // To extract the NAME without the "murmr-" prefix and the hyphen at the end
    //                name = String(match.dropFirst(6).dropLast(1))
    //            }
    //
    //            // Todo - Don't save the input names into the file names - only save names on db
    //            name = name.replacingOccurrences(of: "%20", with: " ")
    //
    //            recordingsList.append(Recording(id: UUID(), fileURL : i, createdAt:getFileDate(for: i), isPlaying: false, name: name))
    //        }
    //
    //        recordingsList.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
    //    }
    
    func startPlayback(url: URL) {
        if (self.audioPlayer != nil && self.audioPlayer.isPlaying) {
            self.stopPlayback(url: url)
        }
        
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playback failed")
        }
        
        do {
            for i in 0 ..< recordingsList.count {
                if recordingsList[i].fileURL == url {
                    recordingsList[i].isPlaying = true
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.delegate = self
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                }
            }
        }
        catch {
            print("Playback failed")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0..<recordingsList.count {
            if recordingsList[i].isPlaying == true {
                recordingsList[i].isPlaying = false
            }
        }
    }
    
    func stopPlayback(url : URL) {
        if let ap = audioPlayer {
            ap.stop()
            
            for i in 0..<recordingsList.count {
                if recordingsList[i].fileURL == url {
                    recordingsList[i].isPlaying = false
                }
            }
        }
    }
    
    func deleteRecording(url : URL){
        do {
            try FileManager.default.removeItem(at : url)
        } catch {
            print("Can't delete")
        }
        
        for i in 0..<recordingsList.count {
            
            if recordingsList[i].fileURL == url {
                if recordingsList[i].isPlaying == true {
                    stopPlayback(url: recordingsList[i].fileURL)
                }
                
                recordingsList.remove(at : i)
                
                break
            }
        }
    }
}
