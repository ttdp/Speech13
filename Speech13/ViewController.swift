//
//  ViewController.swift
//  Speech13
//
//  Created by Tian Tong on 12/31/20.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    let audioEngine = AVAudioEngine()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?

    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-Hans-CN"))
    
    var micIsOn: Bool = false {
        didSet {
            if micIsOn {
                micImage.image = UIImage(systemName: "mic.fill")
                do {
                    self.transText.text = ""
                    try startRecording()
                } catch {
                    print("Error occurs: \(error.localizedDescription)")
                }
            } else {
                if audioEngine.isRunning {
                    recognitionRequest?.endAudio()
                    audioEngine.stop()
                }
                micImage.image = UIImage(systemName: "mic.slash.fill")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        getPermission()
        
        setupViews()
        
        print(Locale.preferredLanguages[0])
    }

    // MARK: - Views
    
    let transText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        textView.textColor = .darkGray
        return textView
    }()
    
    lazy var micImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mic.slash.fill")
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    func setupViews() {
        transText.text = "Hello SFSpeechRecognition, this is iOS 13."
        view.addSubview(transText)
        view.addConstraints(format: "H:|-20-[v0]-20-|", views: transText)
        view.addConstraints(format: "V:[v0(200)]", views: transText)
        transText.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(micImage)
        view.addConstraints(format: "H:[v0(80)]", views: micImage)
        view.addConstraints(format: "V:[v0(80)]", views: micImage)
        micImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        micImage.topAnchor.constraint(equalTo: transText.bottomAnchor, constant: 50).isActive = true
    }
    
    // MARK: - Methods
    
    @objc func handleTap() {
        micIsOn.toggle()
    }
    
    func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            if speechRecognizer?.supportsOnDeviceRecognition ?? false {
                recognitionRequest.requiresOnDeviceRecognition = true
            }
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    let transcribedString = result.bestTranscription.formattedString
                    self.transText.text = transcribedString
                }
            }
            
            if error != nil {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }
    
    func getPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    print("authorized")
                case .restricted:
                    print("restricted")
                case .notDetermined:
                    print("notDetermined")
                case .denied:
                    print("denied")
                @unknown default:
                    print("unknown")
                }
            }
        }
    }

}

