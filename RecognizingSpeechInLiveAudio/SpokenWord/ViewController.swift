/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The root view controller that provides a button to start and stop recording, and which displays the speech recognition results.
*/

import UIKit
import Speech

public class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
//    private var audioArray: [String] = []
    
    private var choice: String = ""
    
    @IBOutlet var textView: UITextView!
    
    

    
    // MARK: View Controller Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.startAudioEngine()
        // Disable the record buttons until authorization has been granted.

        
    }
    //Checks to see if keywords are used in given String.
    //Two pointers main and submain handle the position the keywords: Main must be before submain
    func keyWordChecker(_ liveAudio: String) -> Bool {
//        let hey = indexOfGivenWord(liveAudio, word: "hey")
//        let victoria = indexOfGivenWord(liveAudio, word: "victoria")
//        var share = indexOfGivenWord(liveAudio, word: "share")
//        var comment = indexOfGivenWord(liveAudio, word: "comment")
        //[hey, victoria, share]
        if liveAudio.contains("hey victoria") {
            return true
        }
        return false
    }
    
    func indexOfGivenWord (_ array: [String], word: String) -> Int {
        var index = 0
        var farthestIndex = 0
        if !array.contains(word) {return -1}
        for i in array {
            if i == word {
                farthestIndex = index
            } else {
                index = index + 1
            }
        }
        return farthestIndex

    }
    
    func stringToArrayOfWords(_ sentences: String) -> [String] {
        var words: [String] = []
        var currWord: String = ""
        for letter in sentences {
            if letter == " " {
                words.append(currWord.lowercased())
                currWord = ""
            } else {
                currWord += String(letter.lowercased())
            }
        }
        return words
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
    @objc func nextKeyWord () {
        
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
        
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                var audioArray: [String] = []
                // Update the text view with the results.
                self.textView.text = result.bestTranscription.formattedString
                let audio = result.bestTranscription.formattedString.lowercased()
                audioArray = self.stringToArrayOfWords(audio)
                if self.keyWordChecker(audio){isFinal = true}
            }
            // Stop recognizing speech if there is a problem.
            if error != nil || isFinal {
                //Set a timer for the voice assistant to pick a command.
                Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.nextKeyWord), userInfo: nil, repeats: false)
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
                switch self.choice {
                case "share":
                    self.performSegue(withIdentifier: "ShareViewController", sender: self)
                default:
                    self.performSegue(withIdentifier: "ViewController", sender: self)
                }

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

