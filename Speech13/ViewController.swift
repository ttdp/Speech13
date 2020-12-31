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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        getPermission()
        
        setupViews()
    }

    // MARK: - Views
    
    let transText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        textView.textColor = .darkGray
        return textView
    }()
    
    let micImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mic.slash.fill")
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

