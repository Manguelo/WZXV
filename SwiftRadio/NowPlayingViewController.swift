//
//  NowPlayingViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/22/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit
import MediaPlayer

//*****************************************************************
// Protocol
// Updates the StationsViewController when the track changes
//*****************************************************************

protocol NowPlayingViewControllerDelegate: class {
    func songMetaDataDidUpdate(track: Track)
    func artworkDidUpdate(track: Track)
    func trackPlayingToggled(track: Track)
}

//*****************************************************************
// NowPlayingViewController
//*****************************************************************
var playingRadio = false
class NowPlayingViewController: UIViewController {

    @IBOutlet weak var albumHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumImageView: SpringImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songLabel: SpringLabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!
    @IBOutlet weak var slider = UISlider()
    @IBOutlet weak var IPadButtonView: UIView!
    
    var currentStation: RadioStation!
    var downloadTask: URLSessionDownloadTask?
    var iPhone4 = false
    var justBecameActive = false
    var newStation = true
    var nowPlayingImageView: UIImageView!
    let radioPlayer = Player.radio
    var track: Track!
    var mpVolumeSlider = UISlider()
    var radioIsLoading = true
    
    weak var delegate: NowPlayingViewControllerDelegate?
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        if UIDevice.current.userInterfaceIdiom == .pad{
            IPadButtonView.isHidden = false
            IPadButtonView.layer.zPosition = 1
        }
        
        /* schedule START */
       
        //in case the array isn't filled to 97 (error with schedule on Google Drive)
        if(scheduleArray.count < 97){
            for _ in 1...(97-scheduleArray.count){
                scheduleArray.append("WZXV")
                scheduleArray.append("The Word")
            }
        }
        //print(webString)
        print("\n\n")
        print(scheduleArray)
        print("\n\n")

/* schedule END */
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        //AVAudioSession.sharedInstance().setCategory(AVAudioSessionCa‌​tegoryPlayback)
        super.viewDidLoad()
        var timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setUpArtistAndTitle), userInfo: nil, repeats: true)
      
        // Setup handoff functionality - GH
        setupUserActivity()
        
        // Set AlbumArtwork Constraints
        optimizeForDeviceSize()

        // Set View Title
        self.title = "The Word - WZXV"
        
        // Create Now Playing BarItem
        createNowPlayingAnimation()
      
        setupPlayer()
        
        // Notification for when app becomes active
        NotificationCenter.default.addObserver(self,
            selector: #selector(NowPlayingViewController.didBecomeActiveNotificationReceived),
            name: Notification.Name("UIApplicationDidBecomeActiveNotification"),
            object: nil)
      
        NotificationCenter.default.addObserver(self,
            selector: #selector(NowPlayingViewController.sessionInterrupted),
            name: Notification.Name.AVAudioSessionInterruption,
            object: AVAudioSession.sharedInstance())
        
        // Check for station change
        if newStation {
            track = Track()
            stationDidChange()
        } else {
            updateLabels()
            albumImageView.image = track.artworkImage

            if !track.isPlaying {
                pausePressed()
            } else {
                nowPlayingImageView.startAnimating()
            }
        }
        nowPlayingImageView.startAnimating()
        // Setup slider
        setupVolumeSlider()
        playingRadio = true
    }
    
    @objc func didBecomeActiveNotificationReceived() {
        // View became active
        updateLabels()
        justBecameActive = true
        updateAlbumArtwork()
    }
    
    deinit {
        // Be a good citizen
        NotificationCenter.default.removeObserver(self,
            name: Notification.Name("UIApplicationDidBecomeActiveNotification"),
            object: nil)
        NotificationCenter.default.removeObserver(self,
            name: Notification.Name.MPMoviePlayerTimedMetadataUpdated,
            object: nil)
        NotificationCenter.default.removeObserver(self,
            name: Notification.Name.AVAudioSessionInterruption,
            object: AVAudioSession.sharedInstance())
    }
    
    //*****************************************************************
    // MARK: - Setup
    //*****************************************************************
    @IBAction func facebookButton(_ sender: Any) {
//        menuShowing = true
//        updateMenuIfNeeded()
        if let url = URL(string: "https://www.facebook.com/WZXVTheWord") {
            UIApplication.shared.openURL(url)
            
        }
        
    }
    @IBAction func twitterButton(_ sender: Any) {
//        menuShowing = true
//        updateMenuIfNeeded()
        if let url = URL(string: "https://twitter.com/wzxvtheword") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func websiteButton(_ sender: Any) {
        if let url = URL(string: "https://wzxv.org") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func instagramButton(_ sender: Any) {
        if let url = URL(string: "https://www.instagram.com/wzxvtheword") {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @objc func setUpArtistAndTitle(){
        let date = Date()
        let calendar = Calendar.current
        let locale = NSTimeZone.init(abbreviation: "EST")
        NSTimeZone.default = locale! as TimeZone
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ccc"
        let dayOfWeekString = dateFormatter.string(from: date)
        if dayOfWeekString == "Sat" || dayOfWeekString == "Sun"{
                artistLabel.text = "The Word"
                songLabel.text = "WZXV"
        }else if dayOfWeekString == "Mon" || dayOfWeekString == "Tue" || dayOfWeekString == "Wed" || dayOfWeekString == "Thu" || dayOfWeekString == "Fri"{
        if hour == 1 && minutes < 30{
            artistLabel.text = scheduleArray[0]
            songLabel.text = scheduleArray[1]
        }else if hour == 1 && minutes >= 30{
            artistLabel.text = scheduleArray[2]
            songLabel.text = scheduleArray[3]
        }else if hour == 2 && minutes < 30{
            artistLabel.text = scheduleArray[4]
            songLabel.text = scheduleArray[5]
        }else if hour == 2 && minutes >= 30{
            artistLabel.text = scheduleArray[6]
            songLabel.text = scheduleArray[7]
        }else if hour == 3 && minutes < 30{
            artistLabel.text = scheduleArray[8]
            songLabel.text = scheduleArray[9]
        }else if hour == 3 && minutes >= 30{
            artistLabel.text = scheduleArray[10]
            songLabel.text = scheduleArray[11]
        }else if hour == 4 && minutes < 30{
            artistLabel.text = scheduleArray[12]
            songLabel.text = scheduleArray[13]
        }else if hour == 4 && minutes >= 30{
            artistLabel.text = scheduleArray[14]
            songLabel.text = scheduleArray[15]
        }else if hour == 5 && minutes < 30{
            artistLabel.text = scheduleArray[16]
            songLabel.text = scheduleArray[17]
        }else if hour == 5 && minutes >= 30{
            artistLabel.text = scheduleArray[18]
            songLabel.text = scheduleArray[19]
        }else if hour == 6 && minutes < 30{
            artistLabel.text = scheduleArray[20]
            songLabel.text = scheduleArray[21]
        }else if hour == 6 && minutes >= 30{
            artistLabel.text = scheduleArray[22]
            songLabel.text = scheduleArray[23]
        }else if hour == 7 && minutes < 15{
            artistLabel.text = scheduleArray[24]
            songLabel.text = scheduleArray[25]
        }else if hour == 7 && minutes >= 15 && minutes < 30{
            artistLabel.text = scheduleArray[26]
            songLabel.text = scheduleArray[27]
        }else if hour == 7 && minutes >= 30{
            artistLabel.text = scheduleArray[28]
            songLabel.text = scheduleArray[29]
        }else if hour == 8 && minutes < 30{
            artistLabel.text = scheduleArray[30]
            songLabel.text = scheduleArray[31]
        }else if hour == 8 && minutes >= 30{
            artistLabel.text = scheduleArray[32]
            songLabel.text = scheduleArray[33]
        }else if hour == 9 && minutes < 30{
            artistLabel.text = scheduleArray[34]
            songLabel.text = scheduleArray[35]
        }else if hour == 9 && minutes >= 30{
            artistLabel.text = scheduleArray[36]
            songLabel.text = scheduleArray[37]
        }else if hour == 10 && minutes < 30{
            artistLabel.text = scheduleArray[38]
            songLabel.text = scheduleArray[39]
        }else if hour == 10 && minutes >= 30{
            artistLabel.text = scheduleArray[40]
            songLabel.text = scheduleArray[41]
        }else if hour == 11 && minutes < 30{
            artistLabel.text = scheduleArray[42]
            songLabel.text = scheduleArray[43]
        }else if hour == 11 && minutes >= 30{
            artistLabel.text = scheduleArray[44]
            songLabel.text = scheduleArray[45]
        }else if hour == 12 && minutes < 30{
            artistLabel.text = scheduleArray[46]
            songLabel.text = scheduleArray[47]
        }else if hour == 12 && minutes >= 30{
            artistLabel.text = scheduleArray[48]
            songLabel.text = scheduleArray[49]
        }else if hour == 13 && minutes < 30{
            artistLabel.text = scheduleArray[50]
            songLabel.text = scheduleArray[51]
        }else if hour == 13 && minutes >= 30{
            artistLabel.text = scheduleArray[52]
            songLabel.text = scheduleArray[53]
        }else if hour == 14 && minutes < 30{
            artistLabel.text = scheduleArray[54]
            songLabel.text = scheduleArray[55]
        }else if hour == 14 && minutes >= 30{
            artistLabel.text = scheduleArray[56]
            songLabel.text = scheduleArray[57]
        }else if hour == 15 && minutes < 30{
            artistLabel.text = scheduleArray[58]
            songLabel.text = scheduleArray[59]
        }else if hour == 15 && minutes >= 30{
            artistLabel.text = scheduleArray[60]
            songLabel.text = scheduleArray[61]
        }else if hour == 16 && minutes < 30{
            artistLabel.text = scheduleArray[62]
            songLabel.text = scheduleArray[63]
        }else if hour == 16 && minutes >= 30{
            artistLabel.text = scheduleArray[64]
            songLabel.text = scheduleArray[65]
        }else if hour == 17 && minutes < 30{
            artistLabel.text = scheduleArray[66]
            songLabel.text = scheduleArray[67]
        }else if hour == 17 && minutes >= 30{
            artistLabel.text = scheduleArray[68]
            songLabel.text = scheduleArray[69]
        }else if hour == 18 && minutes < 30{
            artistLabel.text = scheduleArray[70]
            songLabel.text = scheduleArray[71]
        }else if hour == 18 && minutes >= 30{
            artistLabel.text = scheduleArray[72]
            songLabel.text = scheduleArray[73]
        }else if hour == 19 && minutes < 30{
            artistLabel.text = scheduleArray[74]
            songLabel.text = scheduleArray[75]
        }else if hour == 19 && minutes >= 30{
            artistLabel.text = scheduleArray[76]
            songLabel.text = scheduleArray[77]
        }else if hour == 20 && minutes < 30{
            artistLabel.text = scheduleArray[78]
            songLabel.text = scheduleArray[79]
        }else if hour == 20 && minutes >= 30{
            artistLabel.text = scheduleArray[80]
            songLabel.text = scheduleArray[81]
        }else if hour == 21 && minutes < 30{
            artistLabel.text = scheduleArray[82]
            songLabel.text = scheduleArray[83]
        }else if hour == 21 && minutes >= 30{
            artistLabel.text = scheduleArray[84]
            songLabel.text = scheduleArray[85]
        }else if hour == 22 && minutes < 30{
            artistLabel.text = scheduleArray[86]
            songLabel.text = scheduleArray[87]
        }else if hour == 22 && minutes >= 30{
            artistLabel.text = scheduleArray[88]
            songLabel.text = scheduleArray[89]
        }else if hour == 23 && minutes < 30{
            artistLabel.text = scheduleArray[90]
            songLabel.text = scheduleArray[91]
        }else if hour == 23 && minutes >= 30{
            artistLabel.text = scheduleArray[92]
            songLabel.text = scheduleArray[93]
        }else if hour == 24 && minutes < 30{
            artistLabel.text = scheduleArray[94]
            songLabel.text = scheduleArray[95]
        }else if hour == 24 && minutes >= 30{
            artistLabel.text = scheduleArray[96]
            songLabel.text = scheduleArray[97]
        }
        }
        self.updateLockScreen()
        if radioPlayer.currentItem?.status != AVPlayerItemStatus.readyToPlay{
            artistLabel.text = "The Word"
            songLabel.text = "Loading..."
            radioIsLoading = true
            
        }else{
            songLabel.layer.removeAnimation(forKey: "flash")
            radioIsLoading = false
        }
        
       
        
    }
    
    func setupPlayer() {
//        radioPlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//        radioPlayer.view.sizeToFit()
//        radioPlayer.movieSourceType = MPMovieSourceType.streaming
//        radioPlayer.isFullscreen = false
//        radioPlayer.shouldAutoplay = true
//        radioPlayer.reaadyToPlay()
//        radioPlayer.controlStyle = MPMovieControlStyle.none
    }
  
    func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        volumeParentView.backgroundColor = UIColor.clear
    
        let volumeView = MPVolumeView(frame: volumeParentView.bounds)
        for view in volumeView.subviews {
            let uiview: UIView = view as UIView
            if (uiview.description as NSString).range(of: "MPVolumeSlider").location != NSNotFound {
                mpVolumeSlider = (uiview as! UISlider)
            }
        }
        
        let thumbImageNormal = UIImage(named: "slider-ball")
        slider?.setThumbImage(thumbImageNormal, for: .normal)
        
    }
    
    func stationDidChange() {
        radioPlayer.pause()
        
        let item = AVPlayerItem(url: URL(string: "http://ic2.christiannetcast.com/wzxv-fm")!)
        radioPlayer.replaceCurrentItem(with: item)
      /*DEPRICATED*/
//        radioPlayer.contentURL = URL(string: "http://50.22.253.46/wzxv-fm")
//        radioPlayer.prepareToPlay()
        playPressed()
        
        if radioIsLoading == true{
            songLabel.animation = "flash"
            songLabel.repeatCount = Float.infinity
            songLabel.animate()
        }
        //updateLabels(statusMessage: "Loading Station...")
        
        // songLabel animate
        updateLabels(statusMessage: "WZXV - The Word")
        resetAlbumArtwork()
        
        track.isPlaying = true
    }
    
    //*****************************************************************
    // MARK: - Player Controls (Play/Pause/Volume)
    //*****************************************************************
    
    @IBAction func playPressed() {
        track.isPlaying = true
        playingRadio = true
        playButtonEnable(enabled: false)
        radioPlayer.play()
        //updateLabels(statusMessage: "Playing")
        
        if radioIsLoading == true{
            songLabel.animation = "flash"
            songLabel.repeatCount = Float.infinity
            songLabel.animate()
        }
        // Start NowPlaying Animation
        nowPlayingImageView.startAnimating()
        
        // Update StationsVC
        self.delegate?.trackPlayingToggled(track: self.track)
    }
    
    @IBAction func pausePressed() {
        track.isPlaying = false
        playingRadio = false
        playButtonEnable()
        
        radioPlayer.pause()
        //updateLabels(statusMessage: "Station Paused...")
        nowPlayingImageView.stopAnimating()
        
        // Update StationsVC
        self.delegate?.trackPlayingToggled(track: self.track)
    }
    
    @IBAction func volumeChanged(_ sender:UISlider) {
        mpVolumeSlider.value = sender.value
    }
    
    //*****************************************************************
    // MARK: - UI Helper Methods
    //*****************************************************************
    
    func optimizeForDeviceSize() {
        
        // Adjust album size to fit iPhone 4s, 6s & 6s+
        let deviceHeight = self.view.bounds.height
        
        if deviceHeight == 480 {
            iPhone4 = true
            albumHeightConstraint.constant = 106
            view.updateConstraints()
        } else if deviceHeight == 667 {
            albumHeightConstraint.constant = 230
            view.updateConstraints()
        } else if deviceHeight > 667 {
            albumHeightConstraint.constant = 260
            view.updateConstraints()
        }
    }
    
    func updateLabels(statusMessage: String = "") {
        
        if statusMessage != "" {
            // There's a an interruption or pause in the audio queue
            songLabel.text = statusMessage
            artistLabel.text = "The Word"
            
        } else {
            // Radio is (hopefully) streaming properly
            if track != nil {
                songLabel.text = track.title
                artistLabel.text = track.artist
            }
        }
        
        // Hide station description when album art is displayed or on iPhone 4
        if track.artworkLoaded || iPhone4 {
            stationDescLabel.isHidden = false
        } else {
            stationDescLabel.isHidden = false
            stationDescLabel.text = "Calvary Chapel Finger Lakes"
        }
    }
    
    func playButtonEnable(enabled: Bool = true) {
        if enabled {
            playButton.isEnabled = true
            pauseButton.isEnabled = false
            track.isPlaying = false
        } else {
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            track.isPlaying = true
        }
    }
    
    func createNowPlayingAnimation() {
        
        // Setup ImageView
        nowPlayingImageView = UIImageView(image: UIImage(named: "NowPlayingBars-3")?.imageWithColor(tintColor: UIColor.orange))
        nowPlayingImageView.autoresizingMask = []
        nowPlayingImageView.contentMode = UIViewContentMode.center
        
        // Create Animation
        nowPlayingImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingImageView.animationDuration = 0.7
        
        // Create Top BarButton
        let barButton = UIButton(type: UIButtonType.custom)
        barButton.frame = CGRect(x: 0,y: 0,width: 40,height: 40);
        barButton.addSubview(nowPlayingImageView)
        nowPlayingImageView.center = barButton.center
        
        let barItem = UIBarButtonItem(customView: barButton)
        self.navigationItem.rightBarButtonItem = barItem
        
    }
    
    func startNowPlayingAnimation() {
        nowPlayingImageView.startAnimating()
    }
    
    //*****************************************************************
    // MARK: - Album Art
    //*****************************************************************
    
    func resetAlbumArtwork() {
        track.artworkLoaded = false
        track.artworkURL = "wzxvLogo.png"
        updateAlbumArtwork()
        stationDescLabel.isHidden = false
    }
    
    func updateAlbumArtwork() {
        track.artworkLoaded = false
        if track.artworkURL.range(of: "http") != nil {
            
            // Hide station description
            DispatchQueue.main.async(execute: {
                //self.albumImageView.image = nil
                self.stationDescLabel.isHidden = false
            })
            
            // Attempt to download album art from an API
            if let url = URL(string: track.artworkURL) {
                
                self.downloadTask = self.albumImageView.loadImageWithURL(url: url) { (image) in
                    
                    // Update track struct
                    self.track.artworkImage = image
                    self.track.artworkLoaded = true
                    
                    // Turn off network activity indicator
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                    // Animate artwork
                    self.albumImageView.animation = "wobble"
                    self.albumImageView.duration = 2
                    self.albumImageView.animate()
                    self.stationDescLabel.isHidden = false

                    // Update lockscreen
                    self.updateLockScreen()
                    
                    // Call delegate function that artwork updated
                    self.delegate?.artworkDidUpdate(track: self.track)
                }
            }
            
            // Hide the station description to make room for album art
            if track.artworkLoaded && !self.justBecameActive {
                self.stationDescLabel.isHidden = false
                self.justBecameActive = false
            }
            
        } else if track.artworkURL != "" {
            // Local artwork
            self.albumImageView.image = UIImage(named: track.artworkURL)
            track.artworkImage = albumImageView.image
            track.artworkLoaded = true
            
            // Call delegate function that artwork updated
            self.delegate?.artworkDidUpdate(track: self.track)
            
        } else {
            // No Station or API art found, use default art
            self.albumImageView.image = UIImage(named: "albumArt")
            track.artworkImage = albumImageView.image
        }
        
        // Force app to update display
        self.view.setNeedsDisplay()
    }

    // Call LastFM or iTunes API to get album art url
    
    func queryAlbumArt() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Construct either LastFM or iTunes API call URL
        let queryURL: String
        if useLastFM {
            queryURL = String(format: "http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=%@&artist=%@&track=%@&format=json", apiKey, track.artist, track.title)
        } else {
            queryURL = String(format: "https://itunes.apple.com/search?term=%@+%@&entity=song", track.artist, track.title)
        }
        
        let escapedURL = queryURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // Query API
        DataManager.getTrackDataWithSuccess(queryURL: escapedURL!) { (data) in
            
            if kDebugLog {
                print("API SUCCESSFUL RETURN")
                print("url: \(escapedURL!)")
            }
            
            let json = JSON(data: data! as Data)
            
            if useLastFM {
                // Get Largest Sized LastFM Image
                if let imageArray = json["track"]["album"]["image"].array {
                    
                    let arrayCount = imageArray.count
                    let lastImage = imageArray[arrayCount - 1]
                    
                    if let artURL = lastImage["#text"].string {
                        
                        // Check for Default Last FM Image
                        if artURL.range(of: "/noimage/") != nil {
                            self.resetAlbumArtwork()
                            
                        } else {
                            // LastFM image found!
                            self.track.artworkURL = artURL
                            self.track.artworkLoaded = true
                            self.updateAlbumArtwork()
                        }
                        
                    } else {
                        self.resetAlbumArtwork()
                    }
                } else {
                    self.resetAlbumArtwork()
                }
            
            } else {
                // Use iTunes API. Images are 100px by 100px
                if let artURL = json["results"][0]["artworkUrl100"].string {
                    
                    if kDebugLog { print("iTunes artURL: \(artURL)") }
                    
                    self.track.artworkURL = artURL
                    self.track.artworkLoaded = true
                    self.updateAlbumArtwork()
                } else {
                    self.resetAlbumArtwork()
                }
            }
            
        }
    }
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "InfoDetail" {
            let infoController = segue.destination as! InfoDetailViewController
            infoController.currentStation = currentStation
        }
    }
    
//    @IBAction func infoButtonPressed(_ sender: UIButton) {
//        performSegue(withIdentifier: "InfoDetail", sender: self)
//    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let textToShare = ["I'm listening to The Word via the WZXV Radio app! https://itunes.apple.com/us/app/the-word-wzxv/id1365679005?ls=1&mt=8"]
        let activityVC = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        if UIDevice.current.userInterfaceIdiom == .pad {
            if  activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController))  {
                activityVC.popoverPresentationController?.sourceView = super.view
                /* to adjust pop-up position */
                //activityVC.popoverPresentationController?.sourceRect = CGRect(x: shareCircle.position.x,y: shareCircle.position.y, width: 0, height: 0)
            }
        }
        let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
        
        currentViewController.present(activityVC, animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - MPNowPlayingInfoCenter (Lock screen)
    //*****************************************************************
    
    func updateLockScreen() {
        
        // Update notification/lock screen
        let albumArtwork = MPMediaItemArtwork(image: UIImage(named: "radio-logo.png")!)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyArtist: artistLabel.text ?? "The Word",
            MPMediaItemPropertyTitle: songLabel.text ?? "WZXV",
            MPMediaItemPropertyArtwork: albumArtwork
        ]
    }
    
    override func remoteControlReceived(with receivedEvent: UIEvent?) {
        super.remoteControlReceived(with: receivedEvent)
        
        if receivedEvent!.type == UIEventType.remoteControl {
            
            switch receivedEvent!.subtype {
            case .remoteControlPlay:
                playPressed()
            case .remoteControlPause:
                pausePressed()
            default:
                break
            }
        }
    }
  
    //*****************************************************************
    // MARK: - AVAudio Sesssion Interrupted
    //*****************************************************************
    
    // Example code on handling AVAudio interruptions (e.g. Phone calls)
    @objc func sessionInterrupted(notification: NSNotification) {
        if let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber{
            if let type = AVAudioSessionInterruptionType(rawValue: typeValue.uintValue){
                if type == .began {
                    print("interruption: began")
                    // Add your code here
                } else{
                    print("interruption: ended")
                    // Add your code here
                }
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Handoff Functionality - GH
    //*****************************************************************
    
    func setupUserActivity() {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb ) //"com.graemeharrison.handoff.googlesearch" //NSUserActivityTypeBrowsingWeb
        userActivity = activity
        let url = "https://www.google.com/search?q=\(self.artistLabel.text!)+\(self.songLabel.text!)"
        let urlStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let searchURL : URL = URL(string: urlStr!)!
        activity.webpageURL = searchURL
        userActivity?.becomeCurrent()
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        let url = "https://www.google.com/search?q=\(self.artistLabel.text!)+\(self.songLabel.text!)"
        let urlStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let searchURL : URL = URL(string: urlStr!)!
        activity.webpageURL = searchURL
        super.updateUserActivityState(activity)
    }
}
