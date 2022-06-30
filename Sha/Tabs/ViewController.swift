//
//  ViewController.swift
//  Sha
//
//  Created by Akora on 28.06.22.
//

import AVFoundation
import Photos
import UIKit

class ViewController: UIViewController {
    var useFrontCamera: Bool = false
    var photoCount: Int = 3
    var timeCount: Int = 3
    
    var session: AVCaptureSession?
    var output = AVCapturePhotoOutput()
    var timer: Timer!
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.red.cgColor
        return button
    }()
    var settingsButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = 20
        button.setBackgroundImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var countLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        return label
    }()
    
    func updateData(){
        self.photoCount = UserDefaults.standard.integer(forKey: "PhotoCount")
        self.timeCount = UserDefaults.standard.integer(forKey: "Timercount")
        countLabel.text = String(photoCount)
        timeLabel.text = String(self.timeCount) + "s"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(shutterButton)
        view.addSubview(settingsButton)
        view.addSubview(countLabel)
        view.addSubview(timeLabel)
        
        checkCameraPerms()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)
        updateData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 70)
        settingsButton.center = CGPoint(x: view.frame.size.width/2 - 70, y: view.frame.size.height - 70)
        countLabel.center = CGPoint(x: view.frame.size.width/2 - 110, y: view.frame.size.height - 70)
        timeLabel.center = CGPoint(x: view.frame.size.width/2 + 110, y: view.frame.size.height - 70)
    }
    
    
    private func checkCameraPerms() {
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            })
            
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func checkPhotoPerms(){
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly){
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: {_ in })
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            return
        case .limited:
            break
        @unknown default:
            break
        }
    }
    
    
    private func setUpCamera(){
        let session = AVCaptureSession()
        //dualwideangel for portrait //builtInDualWideCamera
        if let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: (useFrontCamera ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back)){
            
         /*   guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                for: .video, position: .unspecified)
                else { fatalError("No dual camera.") }*/
     
            self.session?.beginConfiguration()
            self.session?.sessionPreset = .photo
            self.session?.commitConfiguration()
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                
                self.output.isPortraitEffectsMatteDeliveryEnabled = self.output.isPortraitEffectsMatteDeliverySupported
                self.output.isDepthDataDeliveryEnabled = self.output.isDepthDataDeliverySupported
                
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            }
            catch {
                print(error)
            }
        }
    }
    
    private func changeCameraInput(){
        self.useFrontCamera = !self.useFrontCamera
        setUpCamera()
    }
    
    @objc private func navigateToSettings(){
        var newView = storyboard?.instantiateViewController(withIdentifier: "SettingsView") as! SettingsView
        newView.modalTransitionStyle = .crossDissolve
        newView.view.layer.speed = 0.1
        newView.callback = {
            self.updateData()
        }
        self.present(newView, animated: true)
        //session?.stopRunning()
    }
    
    private func getSettings() -> AVCapturePhotoSettings{
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        photoSettings.isDepthDataDeliveryEnabled = output.isDepthDataDeliverySupported
        photoSettings.isPortraitEffectsMatteDeliveryEnabled = output.isPortraitEffectsMatteDeliverySupported
        
        self.output.isPortraitEffectsMatteDeliveryEnabled = self.output.isPortraitEffectsMatteDeliverySupported
        self.output.isDepthDataDeliveryEnabled = self.output.isDepthDataDeliverySupported

        return photoSettings
    }
    
    @objc private func didTapTakePhoto(){
        AudioServicesPlaySystemSound(1113)
        
        DispatchQueue.main.async {
            self.shutterButton.isUserInteractionEnabled = false
            self.shutterButton.layer.borderColor = UIColor.white.cgColor
        }
        
        for i in 1...photoCount {
            let time = timeCount * i
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(time), execute: {
            
                print(self.output.isPortraitEffectsMatteDeliveryEnabled, self.output.isDepthDataDeliveryEnabled)
                //let captureProcessor = PhotoCaptureProcessor()
            //    photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
                self.output.capturePhoto(with: self.getSettings(), delegate: self)
                AudioServicesPlaySystemSound(1108)
                
                if(i == self.photoCount){
                    self.shutterButton.isUserInteractionEnabled = true
                    self.shutterButton.layer.borderColor = UIColor.red.cgColor
                    AudioServicesPlaySystemSound(1114)
                    
                }
            })
        }
        
        //remove imagepreviews
        for view in view.subviews{
            if(view.layer.name == "photoPreview"){
                view.removeFromSuperview()
            }
        }
        
    }
    
    
}



extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return}
   
       // print(photo.portraitEffectsMatte) //Optional(L008 2080x1170 v.1.1) or nil
       // photo.portraitEffectsMatte?.mattingImage
        
        if(photo.portraitEffectsMatte != nil) { print("------")}
    
        let image = UIImage(data:       photo.fileDataRepresentation()!)
        let imageView = UIImageView(image: image)
        
        //  session?.stopRunning()
        
        imageView.contentMode = .scaleAspectFill
        imageView.frame =   CGRect(x: 0, y: 0, width: view.frame.width/4, height: view.frame.height/4)
        imageView.layer.name = "photoPreview"
        view.addSubview(imageView)
    
        UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
        //    let genertor = UIImpactFeedbackGenerator(style: .soft)
        //  genertor.impactOccurred()
        
    }
    
    
}
