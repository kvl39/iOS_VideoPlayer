//
//  ViewController.swift
//  VideoPlayer_Kevin
//
//  Created by Liao Kevin on 2018/4/27.
//  Copyright © 2018年 Kevin Liao. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var durationLabel: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isVideoPlaying = false
    var isMute = false
    var isFullScreen = false
    
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = URL(string: "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4")!
        player = AVPlayer(url: url)
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        addTimeObserver()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(myviewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        durationLabel.minimumTrackTintColor = UIColor.purple
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        let isLandscape = UIDevice.current.orientation.isLandscape
        
        if isLandscape {
            
            self.navigationController?.navigationBar.isHidden = true
            //videoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
            
            var bounds = UIScreen.main.bounds
            var width = bounds.size.width
            var height = bounds.size.height
            
            videoView.frame = CGRect(x: 0 , y: 0, width: width, height: height)
            
            renderButtonImage(image: #imageLiteral(resourceName: "play_button"), button: playButton, color: UIColor.white)
            renderButtonImage(image: #imageLiteral(resourceName: "rewind"), button: backwardButton, color: UIColor.white)
            renderButtonImage(image: #imageLiteral(resourceName: "fast_forward"), button: forwardButton, color: UIColor.white)
            renderButtonImage(image: #imageLiteral(resourceName: "full_screen_exit"), button: fullScreenButton, color: UIColor.white)
            
            if isMute {
                renderButtonImage(image: #imageLiteral(resourceName: "volume_off"), button: muteButton, color: UIColor.white)
            } else {
                renderButtonImage(image: #imageLiteral(resourceName: "volume_up"), button: muteButton, color: UIColor.white)
            }
            
            videoView.addGestureRecognizer(tapGesture)
            
            isFullScreen = true
            
        } else {
            let margins = view.layoutMarginsGuide
            self.navigationController?.navigationBar.isHidden = false
            
            var bounds = UIScreen.main.bounds
            var width = bounds.size.width
            var height = bounds.size.height
            
            videoView.frame = CGRect(x: 0 , y: 200, width: width, height: width*9/16)
            
            
            renderButtonImage(image: #imageLiteral(resourceName: "play_button"), button: playButton, color: UIColor.black)
            renderButtonImage(image: #imageLiteral(resourceName: "rewind"), button: backwardButton, color: UIColor.black)
            renderButtonImage(image: #imageLiteral(resourceName: "fast_forward"), button: forwardButton, color: UIColor.black)
            renderButtonImage(image: #imageLiteral(resourceName: "full_screen_button"), button: fullScreenButton, color: UIColor.black)
            
            if isMute {
                renderButtonImage(image: #imageLiteral(resourceName: "volume_off"), button: muteButton, color: UIColor.black)
            } else {
                renderButtonImage(image: #imageLiteral(resourceName: "volume_up"), button: muteButton, color: UIColor.black)
            }
            
            videoView.removeGestureRecognizer(tapGesture)
            
            isFullScreen = false
            
            
        }
        
        playerLayer.frame = videoView.bounds
 
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        
        if playButton.isHidden {
            playButton.isHidden = false
            muteButton.isHidden = false
            backwardButton.isHidden = false
            forwardButton.isHidden = false
            fullScreenButton.isHidden = false
            durationLabel.isHidden = false
            currentTimeLabel.isHidden = false
            restTimeLabel.isHidden = false
        } else {
            playButton.isHidden = true
            muteButton.isHidden = true
            backwardButton.isHidden = true
            forwardButton.isHidden = true
            fullScreenButton.isHidden = true
            durationLabel.isHidden = true
            currentTimeLabel.isHidden = true
            restTimeLabel.isHidden = true
        }
        
    }
    
    func renderButtonImage(image: UIImage, button: UIButton, color: UIColor) {
        
        let renderImage = image.withRenderingMode(.alwaysTemplate)
        button.setImage(renderImage, for: .normal)
        button.tintColor = color
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            
            guard let currentItem = self?.player.currentItem else {return}
            self?.durationLabel.maximumValue = Float(currentItem.duration.seconds)
            self?.durationLabel.minimumValue = 0
            self?.durationLabel.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
            
        })
    }
    
    
    @IBAction func playPressed(_ sender: Any) {
        
        isVideoPlaying = !isVideoPlaying
        
        if isVideoPlaying{
            player.pause()
        } else {
            player.play()
        }
        
    }
    
    @IBAction func fastForwardPressed(_ sender: Any) {
        
        guard let duration = player.currentItem?.duration else {return}
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10.0
        
        if newTime < (CMTimeGetSeconds(duration) - 10.0) {
            let time: CMTime = CMTimeMake(Int64(newTime*1000), 1000)
            player.seek(to: time)
        }
    }
    
    @IBAction func backwardPressed(_ sender: Any) {
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 10.0
        
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(Int64(newTime*1000), 1000)
        player.seek(to: time)
    }
    
    @IBAction func sliderBalueChanged(_ sender: UISlider) {
        
        player.seek(to: CMTimeMake(Int64(sender.value*1000), 1000))
        
    }
    
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        
        player.seek(to: CMTimeMake(Int64(sender.value*1000), 1000))
        
    }
    
    
    @IBAction func mute(_ sender: UIButton) {
        
        if isMute {
            player.isMuted = false
            sender.setImage(#imageLiteral(resourceName: "volume_up"), for: .normal)
        } else {
            player.isMuted = true
            sender.setImage(#imageLiteral(resourceName: "volume_off"), for: .normal)
        }
        
        self.isMute = !self.isMute
        
    }
    
    
    
    @IBAction func fullScreen(_ sender: UIButton) {
        
        isFullScreen = !isFullScreen
        
        if isFullScreen{
            sender.setImage(#imageLiteral(resourceName: "full_screen_exit"), for: .normal)
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            
        } else {
            sender.setImage(#imageLiteral(resourceName: "full_screen_button"), for: .normal)
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.restTimeLabel.text = getTimeString(from: player.currentItem!.duration)
        }
        
    }
    
    func getTimeString(from time: CMTime) -> String {
        
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600) 
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds])
        }
        
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        
        
    }
    

}

