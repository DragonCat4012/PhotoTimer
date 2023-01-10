//
//  CameraView.swift
//  Sha
//
//  Created by Kiara on 28.06.22.
//

import AVFoundation
import Photos
import UIKit
import MultipeerConnectivity

class CameraView: MultipeerViewController {
    var gridEnabled: Bool = true
    var portraitEnabled: Bool = false
    
    var photoCount: Int = 3
    var timeCount: Int = 3
    var photoTimer: Timer?;
    
    var session: AVCaptureSession?
    var output = AVCapturePhotoOutput()
    var timer: Timer!
    
    let context = CIContext()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    let ciContext = CIContext()
    
    var shutterButton: PulsatingButton = {
        let button = PulsatingButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    var settingsButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = 20
        button.setBackgroundImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var portraitIcon: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.layer.cornerRadius = 20
        button.setBackgroundImage(UIImage(systemName: "person.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var countLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    //Multipeer Variables
   /* var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?*/
    
    //MARK: Ovveride Stuff
    func updateData(){
        self.photoCount = UserDefaults.standard.integer(forKey: "PhotoCount")
        self.timeCount = UserDefaults.standard.integer(forKey: "Timercount")
        
        self.gridEnabled = UserDefaults.standard.bool(forKey: "GridEnabled")
        self.portraitEnabled = UserDefaults.standard.bool(forKey: "PortraitEnabled")
        
        countLabel.text = String(photoCount)
        timeLabel.text = String(self.timeCount) + "s"
        
        let camera = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        portraitIcon.isHidden = portraitEnabled && camera == "builtInDualWideCamera" ? false : true
        
        if(portraitEnabled && camera == "builtInDualWideCamera"){
            drawPortraitGuide()
        }
        
        //building grid
        if(self.gridEnabled){
            drawGrid()
        } else {
            self.view.layer.sublayers?.removeAll(where: {$0.name == "GridLayer"})
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!(session?.isRunning ?? true)){ setUpCamera()}
        self.updateData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
        removePreviewLayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(shutterButton)
        view.addSubview(settingsButton)
        
        view.addSubview(countLabel)
        view.addSubview(timeLabel)
        view.addSubview(portraitIcon)
        
        checkCameraPerms()
        
        shutterButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        //settingsButton.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(showConnectionPrompt), for: .touchUpInside)
        updateData()
        
        self.navigationItem.hidesBackButton = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        //multiper MultipeerConnectivity
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 70)
        settingsButton.center = CGPoint(x: view.frame.size.width/2 - 70, y: view.frame.size.height - 70)
        portraitIcon.center = CGPoint(x: view.frame.size.width/2 + 70, y: view.frame.size.height - 70)
        portraitIcon.isUserInteractionEnabled = false
        
        countLabel.center = CGPoint(x: view.frame.size.width/2 - 140, y: view.frame.size.height - 70)
        timeLabel.center = CGPoint(x: view.frame.size.width/2 + 140, y: view.frame.size.height - 70)
    }
    
    @objc func appMovedToBackground() {
        if let timmy = self.photoTimer {
            timmy.invalidate()
            removePreviewLayer()
            self.changeButtonInteraction(true)
            shutterButton.stopPulse()
            self.shutterButton.layer.borderColor = UIColor.white.cgColor
            self.photoTimer = nil
        }
    }
    
    //MARK: Functions
    func changeButtonInteraction(_ enabled: Bool){
        DispatchQueue.main.async {
            self.settingsButton.isUserInteractionEnabled = enabled
            self.settingsButton.tintColor = enabled ? .white : .gray
        }
    }

    
}
