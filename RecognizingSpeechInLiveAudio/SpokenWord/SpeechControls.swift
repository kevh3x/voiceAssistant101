//
//  SpeechControls.swift
//  SpokenWord
//
//  Created by Kevin Esparza on 7/22/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Foundation
import Speech

class SpeechControls {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var textView: UITextView!
    
    
    init(_ txtView: UITextView/*,_ imagView:UIImageView*/) {
        textView = txtView
        //imageView = imagView
    }
    
    // Starts Audio Engine in the app.
    func startAudioEngine() {
        do {
            try startRecording()
        } catch {
        }
    }
    
    
    // Stops Audion Engine in the app.
    func stopAudioEngine() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
    }
    
    //Takes a String sentence and outputs an array of the words in that sentence.
    func stringToArrayOfWords(_ sentences: String) -> [String] {
        var words: [String] = []
        var currWord: String = ""
        for letter in sentences {
            if letter == " " {
                words.append(currWord.lowercased())
                currWord = ""
            } else {
                currWord += String(letter)
            }
        }
        words.append(currWord)
        return words
    }
    
    private func startRecording() throws {
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            let isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.textView.text = result.bestTranscription.formattedString
                let audio = result.bestTranscription.formattedString.lowercased()
                var audioArray = self.stringToArrayOfWords(audio)
                if audio.contains("hey victoria") {
                    var choice = audioArray[audioArray.count - 1]
                    switch choice {
                    //TODO: Connect the SEGUES here:
                    // Replace the print statements with the SEGUES
                    case "share":
                        print("You shared")
                        self.stopAudioEngine()
                    case "comment":
                        print("You commented")
                        self.stopAudioEngine()
                    case "next":
                        print("Next pictura")
                        self.stopAudioEngine()
                    case "previous":
                        print("previous picture")
                        self.stopAudioEngine()
                    default:
                        choice = ""
                    }
                }
            }
            if error != nil || isFinal {
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        textView.text = "(Go ahead, I'm listening)"
    }

}
