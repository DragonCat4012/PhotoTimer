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
    var gridEnabled: Bool = true
    private var portraitEnabled: Bool = false
    
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
        settingsButton.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)
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
    private func changeButtonInteraction(_ enabled: Bool){
        DispatchQueue.main.async {
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
    
    func setUpCamera() {
        let camera = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        let newSession = AVCaptureSession()
        self.session = newSession
        
        if let device = AVCaptureDevice.default(Util.getCameraType(camera), for: .video, position: AVCaptureDevice.Position.back){
            
            self.session?.beginConfiguration()
            self.session?.sessionPreset = .photo
            self.session?.commitConfiguration()
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if newSession.canAddInput(input){
                    newSession.addInput(input)
                }
                
                if newSession.canAddOutput(self.output){
                    newSession.addOutput(self.output)
                }
                
                self.previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer.session = newSession
                self.previewLayer.connection?.videoOrientation = .portrait
                
                DispatchQueue.global(qos: .background).async {
                    newSession.startRunning()
                    self.session = newSession
                }
            }
            catch {
                print(error)
            }
        } else {
            self.previewLayer.session = nil
            return self.previewLayer.backgroundColor = UIColor.red.cgColor
        }
        
    }
    
    
    @objc private func takePhoto(){
        //stop current session if one is running
        if let timmy = self.photoTimer {
            timmy.invalidate()
            removePreviewLayer()
            self.changeButtonInteraction(true)
            shutterButton.stopPulse()
            self.shutterButton.layer.borderColor = UIColor.white.cgColor
            self.photoTimer = nil
            return
        }
        
        self.shutterButton.layer.borderColor = UIColor.red.cgColor
        shutterButton.pulse()
        var runCount = 0
        AudioServicesPlaySystemSound(1113)
        self.changeButtonInteraction(false)
        
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
    
    func savePhoto(data: Data?){
        guard let data else {
            return
        }
      
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: data, options: nil)
                
                
            }, completionHandler: { (result : Bool, error : Error?) -> Void in
                if (error != nil){
                    NSLog("couldnt save image")
                    print(error!)
                }
            })
        }
    }
    
    func appyBlur(background: CIImage?, mask: CIImage?) -> CIImage?{
        guard let background else { return nil}
        guard let mask else { return nil}
        
        let maskFilter = CIFilter(name: "CIMaskedVariableBlur")
        maskFilter?.setValue(background, forKey: "inputImage")
        maskFilter?.setValue(mask, forKey: "inputMask")
        maskFilter?.setValue(20, forKey: "inputRadius")
        
        guard let image = maskFilter?.outputImage else {
            NSLog("⚠️ failed blurring image")
            return nil
        }
        return image
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { NSLog("⚠️ No image data qwq"); return}
        guard error == nil else { NSLog("Error capturing photo: \(error!)"); return }
     
        guard let image = UIImage(data:data) else {
            NSLog("⚠️ no image taken"); return
        }
        
        let isPortrait = (photo.portraitEffectsMatte != nil)
        var saveImageData = photo.fileDataRepresentation()!
        var imageView =  UIImageView(image: image)
      
        if(isPortrait){
        //resize portraiteffect to image
        let portraitEffectsMatte = CIImage(cvPixelBuffer: photo.portraitEffectsMatte!.mattingImage)
        let matteResized = portraitEffectsMatte.transformed (by: CGAffineTransform(scaleX: 2.0, y: 2.0) )
        
        //invert depth mask
        let invertFilter = CIFilter(name: "CIColorInvert")
        invertFilter?.setValue(matteResized, forKey: kCIInputImageKey)
        
        //create blur effect
        let inputCIImage = CIImage(image: image)
        let maskImage = invertFilter?.outputImage!
        var blurredImage =  appyBlur(background: inputCIImage, mask: maskImage)
        
        //rotate and crop result
        blurredImage = blurredImage!.cropped(to: inputCIImage!.extent)
        blurredImage = blurredImage!.oriented(.right)
        
      
        guard let cgIm = ciContext.createCGImage(blurredImage!, from: (blurredImage?.extent)!) else {  NSLog("⚠️ ciContext failed"); return}

        let FinalUIImage = UIImage(cgImage: cgIm)
        
        imageView = UIImageView(image: FinalUIImage)
        saveImageData =  FinalUIImage.pngData()!
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
        
        // save photo
        savePhoto(data: saveImageData)
    }
    
    
    
}

