//
//  StationsViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/19/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

var scheduleArray = [String]()
class StationsViewController: UIViewController {
    var menuShowing = false
  
    @IBOutlet weak var TwitterButton: SpringButton!
    @IBOutlet weak var FacebookButton: SpringButton!
    @IBOutlet weak var InstaButton: SpringButton!
    @IBOutlet weak var WebButton: SpringButton!
    @IBOutlet weak var stationNowPlayingButton: UIButton!
    @IBOutlet weak var nowPlayingAnimationImageView: UIImageView!
    @IBOutlet weak var liveButton: GradientButton!
    @IBOutlet weak var IPadButtonView: UIView!
    @IBOutlet weak var facebookTestButton: UIButton!
    var stations = [RadioStation]()
    var currentStation: RadioStation?
    var currentTrack: Track?
    var refreshControl: UIRefreshControl!
    var firstTime = true
    
    var searchedStations = [RadioStation]()
    var searchController : UISearchController!
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad{
           InstaButton.isHidden = true
           FacebookButton.isHidden = true
           WebButton.isHidden = true
           TwitterButton.isHidden = true
           IPadButtonView.isHidden = false
           IPadButtonView.layer.zPosition = 1
        }
    
        
        // Create NowPlaying Animation
        createNowPlayingAnimation()
        
        // Set AVFoundation category, required for background audio
        var error: NSError?
        var success: Bool
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if !success {
            if kDebugLog { print("Failed to set audio session category.  Error") }
        }
        
        // Set audioSession as active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error2 as NSError {
            if kDebugLog { print("audioSession setActive error \(error2)") }
        }
        
        // Setup Search Bar
        //setupSearchController()
    }
    
    override func viewDidLayoutSubviews() {
        liveButton.layer.shadowOpacity = 0.7
        liveButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        liveButton.gradientLayer.frame = liveButton.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "WZXV - The Word"
       
        
        // If a station has been selected, create "Now Playing" button to get back to current station
        if !firstTime {
            createNowPlayingBarButton()
        }else{
            //load schedule
            loadSchedule()
        }
        
        // If a track is playing, display title & artist information and animation
        var title = "WZXV - The Word"
        if playingRadio {
            title = "WZXV - The Word" + " - Now Playing..."
            nowPlayingAnimationImageView.startAnimating()
        } else {
            title = "WZXV - The Word" + " - Paused..."
            nowPlayingAnimationImageView.stopAnimating()
            nowPlayingAnimationImageView.image = UIImage(named: "NowPlayingBars")?.imageWithColor(tintColor: UIColor.orange)
        }
        stationNowPlayingButton.setTitle(title, for: .normal)

        
    }

    //*****************************************************************
    // MARK: - Setup UI Elements
    //*****************************************************************
    
    func loadSchedule(){
        let urlString = "https://drive.google.com/uc?export=download&id=1VHOK768OrBKro49AmfgLzwkSEdm_tWX5"
       //https:
        //drive.google.com/open?id=1VHOK768OrBKro49AmfgLzwkSEdm_tWX5
        let url = URL(string: urlString)
        
        var webString : String = ""
        
        do {
            webString = try String(contentsOf: url!)
            webString = webString.replacingOccurrences(of: "\n", with: "")
            scheduleArray = webString.components(separatedBy: ";")
            scheduleArray = scheduleArray.filter {!$0.isEmpty}
            scheduleArray = scheduleArray.filter {!$0.contains("@")}
            
        } catch {
            for _ in 1...100{
                scheduleArray.append("WZXV")
                scheduleArray.append("The Word")
            }
        }
    }
    
    func createNowPlayingAnimation() {
        nowPlayingAnimationImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingAnimationImageView.animationDuration = 0.7
    }
    
    func createNowPlayingBarButton() {
        if self.navigationItem.rightBarButtonItem == nil {
            let btn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.nowPlayingBarButtonPressed))
            btn.image = UIImage(named: "btn-nowPlaying")
            self.navigationItem.rightBarButtonItem = btn
            //self.navigationItem.rightBarButtonItem?.tintColor = UIColor.orange
        }
    }
    

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @objc func nowPlayingBarButtonPressed() {
        menuShowing = true
        //updateMenuIfNeeded()
        performSegue(withIdentifier: "NowPlaying", sender: self)
    }
    @IBAction func facebookButton(_ sender: Any) {
        menuShowing = true
        updateMenuIfNeeded()
            if let url = URL(string: "https://www.facebook.com/WZXVTheWord") {
                UIApplication.shared.openURL(url)
            
        }
        
    }
    @IBAction func twitterButton(_ sender: Any) {
        menuShowing = true
        updateMenuIfNeeded()
        if let url = URL(string: "https://twitter.com/wzxvtheword") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func websiteButton(_ sender: Any) {
        menuShowing = true
        updateMenuIfNeeded()
        if let url = URL(string: "https://wzxv.org") {
            UIApplication.shared.openURL(url)
        }
    }
   
    @IBAction func instagramButton(_ sender: Any) {
        menuShowing = true
        updateMenuIfNeeded()
        if let url = URL(string: "https://www.instagram.com/wzxvtheword") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func barButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "NowPlaying", sender: self)
        //updateMenuIfNeeded()
    }
    
    @IBAction func nowPlayingPressed(_ sender: UIButton) {
        menuShowing = true
        //updateMenuIfNeeded()
        performSegue(withIdentifier: "NowPlaying", sender: self)
        
    }
    
    func refresh(sender: AnyObject) {
        // Pull to Refresh
        stations.removeAll(keepingCapacity: false)
       // loadStationsFromJSON()
        
        // Wait 2 seconds then refresh screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
            self.view.setNeedsDisplay()
        }
    }
    
    func updateMenuIfNeeded(){
        if menuShowing{
           // slideViewConstraint.constant = -240
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }else{
            print()
            //slideViewConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        menuShowing = !menuShowing
    }

    

    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    @IBAction func liveButton(_ sender: Any) {
        menuShowing = true
        updateMenuIfNeeded()
        performSegue(withIdentifier: "NowPlaying", sender: 0)
        
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NowPlaying" {
            
            self.title = ""
            firstTime = false
            
            let nowPlayingVC = segue.destination as! NowPlayingViewController
            nowPlayingVC.delegate = self
            
            if let indexPath = (sender as? NSIndexPath) {
                // User clicked on row, load/reset station
                if searchController.isActive {
                    currentStation = searchedStations[indexPath.row]
                } else {
                    currentStation = stations[indexPath.row]
                }
                nowPlayingVC.currentStation = currentStation
                nowPlayingVC.newStation = true
            
            } else {
                // User clicked on a now playing button
                if let currentTrack = currentTrack {
                    // Return to NowPlaying controller without reloading station
                    nowPlayingVC.track = currentTrack
                    nowPlayingVC.currentStation = currentStation
                    nowPlayingVC.newStation = false
                } else {
                    // Issue with track, reload station
                    nowPlayingVC.currentStation = currentStation
                    nowPlayingVC.newStation = true
                }
            }
        }
    }
}




//*****************************************************************
// MARK: - NowPlayingViewControllerDelegate
//*****************************************************************

extension StationsViewController: NowPlayingViewControllerDelegate {
    
    func artworkDidUpdate(track: Track) {
        currentTrack?.artworkURL = track.artworkURL
        currentTrack?.artworkImage = track.artworkImage
    }
    
    func songMetaDataDidUpdate(track: Track) {
        currentTrack = track
        let title = currentStation!.stationName + ": " + currentTrack!.title + " - " + currentTrack!.artist + "..."
        stationNowPlayingButton.setTitle(title, for: .normal)
    }
    
    func trackPlayingToggled(track: Track) {
        currentTrack?.isPlaying = track.isPlaying
    }

}

//*****************************************************************
// MARK: - UISearchControllerDelegate
//*****************************************************************

extension StationsViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
    
        // Empty the searchedStations array
        searchedStations.removeAll(keepingCapacity: false)
    
        // Create a Predicate
        let searchPredicate = NSPredicate(format: "SELF.stationName CONTAINS[c] %@", searchController.searchBar.text!)
    
        // Create an NSArray with a Predicate
        let array = (self.stations as NSArray).filtered(using: searchPredicate)
    
        // Set the searchedStations with search result array
        searchedStations = array as! [RadioStation]
    }
    
}
