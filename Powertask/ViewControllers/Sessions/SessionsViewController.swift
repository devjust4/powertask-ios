//
//  SessionsViewController.swift
//  Powertask
//
//  Created by Daniel Torres on 14/1/22.
//

import UIKit
import SwiftUI
import MediaPlayer
class SessionsViewController: UIViewController{
    
    @IBOutlet var actualSongTitleLabel: UILabel!
    @IBOutlet var actualSongArtistLabel: UILabel!
    @IBOutlet var actualSongArtworkImageView: UIImageView!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var playerUI: UIView!
    @IBOutlet var progressBar: CircularProgressBar!
    @IBOutlet var selectTaskButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var initTimerButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    
    private let playerController = MPMusicPlayerController.systemMusicPlayer
    var secondsRemining: Double = 0
    var timer: Timer!
    var stepValue: Double = 0
    var previousStep: Double = 0
    var nextStep: Double = 0
    var session = [(String, Double)]()
    var currentSession = 0
    var isPlaying: Bool = false
    var sessionConfig: [String: Double] = ["number" : 4, "time": 25, "short": 5, "long": 10]
    var selectedTask: PTTask? {
        didSet {
            controlUITask()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.isHidden = true
        loadCondig()
        controlUITask()
        navigationController?.navigationBar.prefersLargeTitles = true
        selectTaskButton?.layer.cornerRadius = 20
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(goToSettings))
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemSongDidChange(_:)),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: playerController
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playPauseSwitch(_:)),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: playerController
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
        
        actualSongArtworkImageView.layer.cornerRadius = 10
        selectTaskButton.titleLabel?.textAlignment = .center
        selectTaskButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30)
        
        let bodyFontDescriptor = timerLabel.font.fontDescriptor
        let bodyMonospacedNumbersFontDescriptor = bodyFontDescriptor.addingAttributes(
            [
                UIFontDescriptor.AttributeName.featureSettings: [
                    [
                        UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                        UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
                    ]
                ]
            ])
        
        let bodyMonospacedNumbersFont = UIFont(descriptor: bodyMonospacedNumbersFontDescriptor, size: 63.0)
        
        timerLabel.font = bodyMonospacedNumbersFont
    }
    
    override func viewWillAppear(_ animated: Bool) {
        controlUIPlayer(song: playerController.nowPlayingItem)
    }
    
    
    // MARK: - Selectors
    
    @objc func goToSettings() {
        guard let sessionsSettingsController = storyboard?.instantiateViewController(withIdentifier: "sessionsConfiguration") as? SessionsConfiguration else { return }
        sessionsSettingsController.sessionConfig = sessionConfig
        sessionsSettingsController.delegate = self
        navigationController?.pushViewController(sessionsSettingsController, animated: true)
    }
    
    @objc func systemSongDidChange(_ notification: Notification) {
        guard let playerController = notification.object as? MPMusicPlayerController else { return }
        controlUIPlayer(song: playerController.nowPlayingItem)
    }
    
    @objc func playPauseSwitch(_ notification: Notification) {
        guard let playerController = notification.object as? MPMusicPlayerController else { return }
        if playerController.playbackState == .playing {
            isPlaying(is: true)
        } else {
            isPlaying(is: false)
        }
    }
    
    @objc func appMovedToBackground() {
        if let timer = timer, timer.isValid {
            timer.invalidate()
            progressBar.stopAnimation()
            sessionDidFinish()
            timerLabel.text = "🥹"
            let alert = UIAlertController(title: "Sesión abortada", message: "No puedes abandonar la aplicación mientras estás en una sesión", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc func orientationChanged() {
        if UIDevice.current.orientation == .faceDown {
            UIDevice.current.isProximityMonitoringEnabled = true
        } else {
            UIDevice.current.isProximityMonitoringEnabled = false
        }
    }
    
    @objc func step() {
        if secondsRemining > 0 {
            if session[0].0 == "session" {
                progressBar.setProgressWithAnimation(duration: stepValue, fromValue: Float(previousStep), tovalue: Float(nextStep))
                previousStep = previousStep + stepValue
                nextStep = previousStep + stepValue
                secondsRemining -= 1
                timerLabel.text = getTimeLabelText(seconds: secondsRemining)
            } else {
                progressBar.setProgressWithAnimation(duration: stepValue, fromValue: Float(previousStep), tovalue: Float(nextStep))
                previousStep = previousStep - stepValue
                nextStep = nextStep - stepValue
                secondsRemining -= 1
                timerLabel.text = getTimeLabelText(seconds: secondsRemining)
            }
            
        } else {
            timer.invalidate()
            progressBar.stopAnimation()
            session.removeFirst()
            if !session.isEmpty {
                playTimer()
            } else {
                sessionDidFinish()
            }
        }
    }
    
    // MARK: - Interface changer functions
    
    func animateProgressView(sessionTime: Double) {
        progressBar.setProgressWithAnimation(duration: sessionTime*60, fromValue: 0, tovalue: 1)
    }
    
    func controlUIPlayer(song: MPMediaItem?) {
        if let item = song {
            actualSongArtistLabel.text = item.artist
            actualSongTitleLabel.text = item.title
            actualSongArtworkImageView.image = item.artwork?.image(at: CGSize(width: 150, height: 150))
            if playerController.playbackState == .playing {
                isPlaying(is: true)
            } else {
                isPlaying(is: false)
            }
        } else {
            isPlaying(is: false)
        }
    }
    
    func isPlaying(is playing: Bool) {
        if playing {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlaying = true
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlaying = false
        }
    }
    
    // MARK: - Persistence Functions
    func loadCondig() {
        guard let config = PTUser.shared.sessionConfig else { return }
        sessionConfig = config
    }
    
    func saveConfig() {
        PTUser.shared.sessionConfig = sessionConfig
        PTUser.shared.savePTUser()
    }
    
    // MARK: - Supporting functions
    
    func getTimeLabelText(seconds: Double) -> String {
        let minutes = (Int(seconds) % 3600) / 60
        let seconds = ((Int(seconds) % 3600) % 60)
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    func controlUITask() {
        if let selectedTask = selectedTask {
            if let color = selectedTask.subject?.color {
                selectTaskButton.layer.borderColor = UIColor(hexString: color).cgColor
                selectTaskButton.layer.borderWidth = 3
                selectTaskButton.backgroundColor = .clear
            }
            selectTaskButton.setTitle(selectedTask.name, for: .normal)
            initTimerButton.isEnabled = true
            if let sessionTime = sessionConfig["time"]{
                timerLabel.isHidden = false
                timerLabel.text = getTimeLabelText(seconds: sessionTime * 60)
            }
        } else {
            initTimerButton.isEnabled = false
            timerLabel.isHidden = true
        }
    }
    
    
    // MARK: - Navigation
    
    @IBAction func selectTaskTapped(_ sender: Any) {
        guard let taskPicker = storyboard?.instantiateViewController(withIdentifier: "taskPicker") as? TaskPicker else { return }
        taskPicker.delegate = self
        navigationController?.pushViewController(taskPicker, animated: true)
    }
    
    
    @IBAction func playPauseTapped(_ sender: Any) {
        if isPlaying {
            playerController.pause()
            isPlaying(is: false)
        } else {
            playerController.play()
            isPlaying(is: true)
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        playerController.skipToNextItem()
        controlUIPlayer(song: playerController.nowPlayingItem)
    }
    
    
    
    @IBAction func initTimerTapped(_ sender: UIButton) {
        if let _ = sessionConfig["time"] {
            if let timer = timer, timer.isValid{
                timer.invalidate()
                sessionDidFinish()
            } else {
                UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                prepareSessionTimes()
                selectTaskButton.isEnabled = false
                navigationItem.rightBarButtonItem?.isEnabled = false
                initTimerButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                initTimerButton.setTitle("Detener", for: .normal)
                navigationItem.rightBarButtonItem?.isEnabled = false
                playTimer()
            }
        }
    }
    
    
    
    // MARK: - Time Functions!!
    
    func prepareSessionTimes() {
        guard let sessionsNumber = sessionConfig["number"] else { return }
        var array = [(String, Double)]()
        for session in 1...Int(sessionsNumber) {
            array.append(("session", sessionConfig["time"]!))
            if Double(session) != sessionsNumber {
                array.append(("short", sessionConfig["short"]!))
            }
        }
        array.append(("long", sessionConfig["long"]!))
        session = array
    }
    
    func playTimer() {
        statusLabel.isHidden = false
        if session[0].0 == "session" {
            currentSession += 1
            statusLabel.text = "Sesión \(currentSession)"
            statusLabel.textColor = UIColor(named: "AccentColor")
            progressBar.setSessionColor()
            secondsRemining = session[0].1 * 60
            stepValue = 1/secondsRemining
            previousStep = 0
            nextStep = stepValue
        } else {
            progressBar.setBreakColor()
            statusLabel.text = "Descanso"
            statusLabel.textColor = UIColor(named: "PTRed")
            secondsRemining = session[0].1 * 60
            stepValue = 1/secondsRemining
            previousStep = 1
            nextStep = 1 - stepValue
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(step), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func resetTimer(seconds: Double) {
        timer.invalidate()
        secondsRemining = seconds
        timerLabel.text = getTimeLabelText(seconds: seconds)
    }
    
    func sessionDidFinish() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        currentSession = 0
        prepareSessionTimes()
        timerLabel.text = "Listo"
        statusLabel.isHidden = true
        selectTaskButton.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        initTimerButton.isEnabled = true
        initTimerButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        initTimerButton.setTitle("Iniciar", for: .normal)
        progressBar.setProgressWithAnimation(duration: 1, fromValue: Float(previousStep), tovalue: 0)
    }
}

extension SessionsViewController: SaveSessionConfiguration, TaskPickerProtocol {
    func taskDidSelected(task: PTTask) {
        selectedTask = task
    }
    
    func sessionConfigDidChanged(sessionConfig: [String : Double]) {
        self.sessionConfig = sessionConfig
        saveConfig()
        controlUITask()
    }
}
