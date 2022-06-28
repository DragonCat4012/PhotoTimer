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
    var portraitEffekt: Bool = false
    var photoCount: Int = 3
    var timeCount: Int = 3
    
    var session: AVCaptureSession?
    var output = AVCapturePhotoOutput()

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
        return label
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(shutterButton)
        view.addSubview(settingsButton)
        view.addSubview(countLabel)
        
        checkCameraPerms()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        
        if(output.isPortraitEffectsMatteDeliverySupported) {
            portraitEffekt = true
            output.isPortraitEffectsMatteDeliveryEnabled = true}
        countLabel.text = String(photoCount)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
     
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 70)
        settingsButton.center = CGPoint(x: view.frame.size.width/2 - 70, y: view.frame.size.height - 70)
        countLabel.center = CGPoint(x: view.frame.size.width/2 - 110, y: view.frame.size.height - 70)
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
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: (useFrontCamera ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back)){
      
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                
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
    
    private func getSettings() -> AVCapturePhotoSettings{
        var photoSettings = AVCapturePhotoSettings()
        if(self.portraitEffekt){
            photoSettings.isPortraitEffectsMatteDeliveryEnabled = true}
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
                self.output.capturePhoto(with: self.getSettings(), delegate: self)
                AudioServicesPlaySystemSound(1108)
                
                if(i == self.photoCount){
                    self.shutterButton.isUserInteractionEnabled = true
                    self.shutterButton.layer.borderColor = UIColor.red.cgColor
                    AudioServicesPlaySystemSound(1114)
                }
            })
        }


    }
    
}


extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return}
        
        let image = UIImage(data: data)
        let imageView = UIImageView(image: image)
        
        
      //  session?.stopRunning()
        
       // imageView.contentMode = .scaleAspectFill
        //imageView.frame = view.bounds
        //view.addSubview(imageView)
        
        UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
        
        
    //    let genertor = UIImpactFeedbackGenerator(style: .soft)
      //  genertor.impactOccurred()
        
        AudioServicesPlaySystemSound(1108)
    
    }
    

}

