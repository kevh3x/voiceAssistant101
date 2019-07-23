/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The root view controller that provides a button to start and stop recording, and which displays the speech recognition results.
*/

import UIKit
import Speech

public class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet var textView: UITextView!

    // MARK: View Controller Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        let x: SpeechControls = SpeechControls(textView)
        x.startAudioEngine()
        // Disable the record buttons until authorization has been granted.

    }


    
    

    
}

