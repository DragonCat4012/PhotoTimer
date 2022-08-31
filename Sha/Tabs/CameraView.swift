//
//  CameraView.swift
//  Sha
//
//  Created by Kiara on 28.06.22.
//

import AVFoundation
import Photos
import UIKit

class CameraView: UIViewController {
    var useFrontCamera: Bool = false
    var gridEnabled: Bool = true
    
    var photoCount: Int = 3
    var timeCount: Int = 3
    var photoTimer: Timer?;
    var blurAmount: Int = 10
    
    var session: AVCaptureSession?
    var output = AVCapturePhotoOutput()
    var timer: Timer!
    
    let context = CIContext()
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
    
    var switchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = 20
        button.setBackgroundImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
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
    
    //MARK: Ovveride Stuff
    func updateData(){
        self.photoCount = UserDefaults.standard.integer(forKey: "PhotoCount")
        self.timeCount = UserDefaults.standard.integer(forKey: "Timercount")
        self.gridEnabled = UserDefaults.standard.bool(forKey: "GridEnabled")
        self.blurAmount = UserDefaults.standard.integer(forKey: "BlurAmount")
        
        countLabel.text = String(photoCount)
        timeLabel.text = String(self.timeCount) + "s"
        
        //building grid
        if(self.gridEnabled){
            let thirdX = self.view.frame.maxX / 3
            let thirdY = self.view.frame.maxY / 3
            drawLine(CGPoint(x: thirdX, y: 0), CGPoint(x: thirdX, y: self.view.frame.maxY))
            drawLine(CGPoint(x: 2 * thirdX, y: 0), CGPoint(x: 2 * thirdX, y: self.view.frame.maxY))
            
            drawLine(CGPoint(x: 0, y: thirdY), CGPoint(x: self.view.frame.maxX, y: thirdY))
            drawLine(CGPoint(x: 0, y: 2 * thirdY), CGPoint(x: self.view.frame.maxX, y: 2 * thirdY))
        } else {
            self.view.layer.sublayers?.removeAll(where: {$0.name == "GridLayer"})
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(shutterButton)
        view.addSubview(settingsButton)
        view.addSubview(switchButton)
        
        view.addSubview(countLabel)
        view.addSubview(timeLabel)
        
        checkCameraPerms()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)
        switchButton.addTarget(self, action: #selector(changeCameraInput), for: .touchUpInside)
        updateData()
        
        self.navigationItem.hidesBackButton = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 70)
        settingsButton.center = CGPoint(x: view.frame.size.width/2 - 70, y: view.frame.size.height - 70)
        switchButton.center = CGPoint(x: view.frame.size.width/2 + 70, y: view.frame.size.height - 70)
        
        countLabel.center = CGPoint(x: view.frame.size.width/2 - 140, y: view.frame.size.height - 70)
        timeLabel.center = CGPoint(x: view.frame.size.width/2 + 140, y: view.frame.size.height - 70)
    }
    
    @objc func appMovedToBackground() {
        if let timmy = self.photoTimer {
            timmy.invalidate()
            changeButtonInteraction(true)
        }
    //    self.session?.stopRunning()
    }
    
    //MARK: Functions
    private func changeButtonInteraction(_ enabled: Bool){
        DispatchQueue.main.async {
            self.shutterButton.isUserInteractionEnabled = enabled
            self.shutterButton.layer.borderColor = enabled ?  UIColor.red.cgColor : UIColor.white.cgColor
           
            self.switchButton.isUserInteractionEnabled = enabled
            self.switchButton.tintColor = enabled ? .white : .gray
        
            self.settingsButton.isUserInteractionEnabled = enabled
            self.settingsButton.tintColor = enabled ? .white : .gray
        }
    }
    
    private func checkCameraPerms() {
        // Check Camera Permission
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
    
    private func setUpCamera() {
        let camera = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        let newSession = AVCaptureSession()
   
        if let device = AVCaptureDevice.default(Util.getCameraType(camera), for: .video, position: (useFrontCamera ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.back)){

            self.session?.beginConfiguration()
            self.session?.sessionPreset = .photo
            self.session?.commitConfiguration()
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if newSession.canAddInput(input){
                    newSession.addInput(input)
                }
                
                if newSession.canAddOutput(output){
                    newSession.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = newSession
                previewLayer.connection?.videoOrientation = .portrait
                
                newSession.startRunning()
                self.session = newSession
                
                self.shutterButton.isUserInteractionEnabled = true
                self.shutterButton.layer.borderColor = UIColor.red.cgColor
            }
            catch {
                print(error)
            }
        } else {
            self.shutterButton.isUserInteractionEnabled = false
            self.shutterButton.layer.borderColor = UIColor.gray.cgColor
            previewLayer.session = nil
            return previewLayer.backgroundColor = UIColor.red.cgColor
        }
    }
    
    @objc private func changeCameraInput(){
        self.useFrontCamera = !self.useFrontCamera
        DispatchQueue.main.async {
            self.setUpCamera()
        }
        
    }
    
    @objc private func navigateToSettings(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "SettingsView") as! SettingsView
        newView.modalTransitionStyle = .crossDissolve
        newView.view.layer.speed = 0.1
        
        // session?.stopRunning()
        newView.callback = {
        // self.session?.startRunning()
        self.updateData()
         self.setUpCamera()
        }
        self.navigationController?.pushViewController(newView, animated: true)
    }
    
    @objc private func didTapTakePhoto(){
        AudioServicesPlaySystemSound(1113)
        
        self.changeButtonInteraction(false)
        
        var runCount = 0

        self.photoTimer = Timer.scheduledTimer(withTimeInterval: Double(timeCount), repeats: true) { timer in
            runCount += 1

            DispatchQueue.main.async {
                let photoSettings = Util.getSettings()
                
                //enable portraitEffect
                if self.output.isDepthDataDeliverySupported && self.output.isPortraitEffectsMatteDeliverySupported {
                    self.output.isHighResolutionCaptureEnabled = true
                    self.output.isDepthDataDeliveryEnabled = self.output.isDepthDataDeliverySupported
                    self.output.isPortraitEffectsMatteDeliveryEnabled = self.output.isPortraitEffectsMatteDeliverySupported
    
                    photoSettings.isDepthDataDeliveryEnabled = self.output.isDepthDataDeliverySupported
                    photoSettings.isPortraitEffectsMatteDeliveryEnabled = self.output.isPortraitEffectsMatteDeliverySupported
                    photoSettings.embedsDepthDataInPhoto = true
                    photoSettings.isDepthDataFiltered = true
                }
                
                self.output.capturePhoto(with: photoSettings, delegate: self)
                AudioServicesPlaySystemSound(1108)
            }
            
            if runCount == self.photoCount {
                self.changeButtonInteraction(true)
                timer.invalidate()
            }
        }
        
        AudioServicesPlaySystemSound(1114)
    }
    
    
}


extension CameraView: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { print("No data qwq"); return}
        guard error == nil else { print("Error capturing photo: \(error!)"); return }
        
        let image = UIImage(data:data)
        let imageView = UIImageView(image: image)
        
        
        // Portrait Effect
        if var portraitEffectsMatte = photo.portraitEffectsMatte {
            print("portrait found")
            if let orientation = photo.metadata[ String(kCGImagePropertyOrientation) ] as? UInt32 {
                portraitEffectsMatte = portraitEffectsMatte.applyingExifOrientation(CGImagePropertyOrientation(rawValue: orientation)!)
              
                let portraitEffectsMattePixelBuffer = portraitEffectsMatte.mattingImage
                let portraitEffectsMatteImage = CIImage( cvImageBuffer: portraitEffectsMattePixelBuffer, options: [ .auxiliaryPortraitEffectsMatte: true ] )
              
                //save with effect
                let filterImg = createFocalBlur(image!, portraitEffectsMatteImage)
                UIImageWriteToSavedPhotosAlbum(filterImg!, self, nil, nil)
                
                //previewImage
                //show mask
                //let imageView = UIImageView(image: UIImage(ciImage: portraitEffectsMatteImage.applyingFilter("CIColorInvert")))
            }
        }
        
        //preview border
        imageView.layer.borderColor = UIColor.accentColor.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        //previewImage
        imageView.layer.cornerRadius = 5
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width/4, height: view.frame.height/4)
        imageView.layer.name = "photoPreview"
        view.addSubview(imageView)
        
        // save normal photo
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
            }, completionHandler: nil)
    }
    }
    
    func createFocalBlur (_ image: UIImage,_ mask: CIImage) -> UIImage? {
        let ciImage = CIImage(image: image)!.oriented(.right)
        let invertedMask = mask.applyingFilter("CIColorInvert")
        let imageExtent = CGRect(x: 0, y: 0, width: 1472.0, height: 2304.0)
        
        //scale mask and image size to the same
        var scaleX = imageExtent.width / mask.extent.width
        var scaleY = imageExtent.height / mask.extent.height
        var scale = scaleX < scaleY ? scaleX : scaleX
        
        let scaledMask = invertedMask.transformed(by: .init(scaleX: scale, y: scale))
        
        scaleX = imageExtent.width / ciImage.extent.width
        scaleY = imageExtent.height / ciImage.extent.height
        scale = scaleX < scaleY ? scaleX : scaleX
        
        let scaledImage = ciImage.transformed(by: .init(scaleX: scale, y: scale))
        

        let output = scaledImage.clampedToExtent().applyingFilter(
            "CIMaskedVariableBlur",
            parameters: [
                "inputMask" : scaledMask,
                "inputRadius": self.blurAmount
            ]).cropped(to: scaledImage.extent)
        let croppedOutput = output.cropped(to: imageExtent)
        
  
        //Convert to CGImage
        guard let cgImage = context.createCGImage(croppedOutput, from: croppedOutput.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }


}
        
      
