//
//  PopUpMenuViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/9/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit

class PopUpMenuViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var youTubeButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
    }
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round corners
       // popupView.layer.cornerRadius = 10
        facebookButton.layer.cornerRadius = 10
        twitterButton.layer.cornerRadius = 10
        instagramButton.layer.cornerRadius = 10
        youTubeButton.layer.cornerRadius = 10
        webButton.layer.cornerRadius = 10
        contactButton.layer.cornerRadius = 10

        // Set background color to clear
        view.backgroundColor = UIColor.clear
        
        // Add gesture recognizer to dismiss view when touched
        //let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopUpMenuViewController.closeButtonPressed))
        //backgroundView.isUserInteractionEnabled = true
        //backgroundView.addGestureRecognizer(gestureRecognizer)
    }
    
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************

    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://github.com/swiftcodex/") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func twitterButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://github.com/swiftcodex/") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func instagramButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://github.com/swiftcodex/") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func youtubeButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://github.com/swiftcodex/") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func webButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://github.com/swiftcodex/") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func contactButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://github.com/swiftcodex/") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
   
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        // Use your own website URL here
        if let url = URL(string: "https://github.com/swiftcodex/") {
            UIApplication.shared.openURL(url)
        }
    }
    
}
