//
//  InfoDetailViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/9/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit

class InfoDetailViewController: UIViewController {
    
    @IBOutlet weak var stationImageView: UIImageView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var stationLongDescTextView: UITextView!
    @IBOutlet weak var okayButton: UIButton!
    
    var currentStation: RadioStation!
    var downloadTask: URLSessionDownloadTask?

    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStationText()
        setupStationLogo()
    }

    deinit {
        // Be a good citizen.
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    //*****************************************************************
    // MARK: - UI Helpers
    //*****************************************************************
    
    func setupStationText() {
        
        // Display Station Name & Short Desc
        stationNameLabel.text = "God's Way Radio"
        stationDescLabel.text = "Calvary Chapel Miami"
        
        // Display Station Long Desc
        
            stationLongDescTextView.text = "WAYG-LP, God’s Way Radio, is an answer to many years of prayer. We first applied for our broadcasting licence in late 2013 (barely making the deadline) and were granted our construction permit on October 30th 2014. So after a year of prayer, and seeking the Lord we finally had the permission to start building. But we still didn’t have a name! So we continued to pray and ask God for His will and the name He would want for this radio station. We went through several ideas and revisions, always praying over them, and on January 1st 2015 God gave us the name, call letters, and verse He wanted for the station. God’s Way Radio was granted the call letters WAYG-LP that same month and Psalm 18:30 became the foundation for God’s Way Radio."
        
    }
    
    func loadDefaultText() {
        // Add your own default ext
        stationLongDescTextView.text = "You are listening to God's Way Radio!"
    }
    
    func setupStationLogo() {
        
        // Display Station Image/Logo
        let imageURL = "radio_logo.png"
        
        if imageURL != "" {
            // Get local station image
            stationImageView.image = UIImage(named: imageURL)
            
        } else {
            // Use default image if station image not found
            stationImageView.image = UIImage(named: "stationImage")
        }
        
        // Apply shadow to Station Image
        stationImageView.applyShadow()
    }
    
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************
    
    @IBAction func okayButtonPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
