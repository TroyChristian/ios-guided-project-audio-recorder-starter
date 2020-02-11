//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Paul Solt on 10/1/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderController: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
	
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use a font that won't jump around as values change
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
         loadAudio()
        updateViews()
        
    }
    
    deinit {
        stopTimer()
    }
    
    private func updateViews() {
        playButton.isSelected = isPlaying
        
        //update time (currentTime)
        let elapsedTime = audioPlayer?.currentTime ?? 0
        timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        
        timeSlider.value = Float(elapsedTime)
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
        
        let timeRemaining = (audioPlayer?.duration ?? 0) - elapsedTime
        timeRemainingLabel.text = timeIntervalFormatter.string(from: timeRemaining)
    }
    
    
    // MARK: - Playback
    
    func loadAudio() {
        // app bundle is readonly folder
     let soungURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!//programmer error if this fails to load
        
        
        audioPlayer = try? AVAudioPlayer(contentsOf: soungURL) //FIXME: use better error handling
        audioPlayer?.delegate = self
    }
    
  func startTimer() {
      // timers are automatically registered on run loop, so we need to cancel before adding a new one
    // call evrey 30 ms (10-30)
      stopTimer()
    timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { [weak self] (timer) in
          self?.updateViews()
      })
  }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    //what do i want to do?
     //pause it
     // valume
     // restart the audio
     // update the time/labels
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func play() {
        audioPlayer?.play()
        startTimer()
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        stopTimer()
        updateViews()
         
    }
    
    func playPause() {
        if isPlaying {
             pause()
        } else {
            play()
        }
    }
    
    
    
    // MARK: - Recording
    
    
    
    // MARK: - Actions
    
    @IBAction func togglePlayback(_ sender: Any) {
        playPause()
        
	}
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        
    }
}


extension AudioRecorderController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        stopTimer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
    
}

