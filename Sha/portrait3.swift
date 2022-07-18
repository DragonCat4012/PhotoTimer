//
//  portrait3.swift
//  Sha
//
//  Created by Kiara on 18.07.22.
//

/*
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
        
        //building grid qwq
        let thirdX = self.view.frame.maxX / 3
        let thirdY = self.view.frame.maxY / 3
        drawLine(CGPoint(x: thirdX, y: 0), CGPoint(x: thirdX, y: self.view.frame.maxY))
        drawLine(CGPoint(x: 2 * thirdX, y: 0), CGPoint(x: 2 * thirdX, y: self.view.frame.maxY))
        
        drawLine(CGPoint(x: 0, y: thirdY), CGPoint(x: self.view.frame.maxX, y: thirdY))
        drawLine(CGPoint(x: 0, y: 2 * thirdY), CGPoint(x: self.view.frame.maxX, y: 2 * thirdY))
        
        
        //setting up screen
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
    }
    
    
    private func drawLine(_ point1: CGPoint, _ point2: CGPoint){
        let stroke = UIBezierPath()
        stroke.move(to: CGPoint(x: point1.x, y: point1.y))
        stroke.addLine(to: CGPoint(x: point2.x, y: point2.y))
        stroke.close()
  
        let layer =  CAShapeLayer()
        layer.path = stroke.cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1
        self.view.layer.addSublayer(layer)
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

        
        // Check PhotoLibrary Permission
      /*  switch PHPhotoLibrary.authorizationStatus(for: .addOnly){
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly, handler:  {
            })
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
        }*/
    }
    

    

    
    private func setUpCamera() {
        let camera = "builtInDualWideCamera"//UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        let newSession = AVCaptureSession()
        //AVCaptureDevice.DeviceType.
        
        //dualwideangel for portrait //builtInDualWideCamera
        if let device = AVCaptureDevice.default(Util.getCameraType(camera), for: .video, position: (useFrontCamera ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back)){
            
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
                
                newSession.startRunning()
                self.session = newSession
                
                self.shutterButton.isUserInteractionEnabled = true
                self.shutterButton.layer.borderColor = UIColor.red.cgColor
            }
            catch {
                print(error)
                /*let infoAlert = UIAlertController(title: "Oh ein Fehler ist aufgetreten", message: "Dein handy scheint die von dir gewählte Kamera nicht zu haben :/", preferredStyle: .actionSheet)
                      infoAlert.addAction(UIAlertAction(title: "ok", style: .cancel))
                      self.present(infoAlert, animated: true)*/
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
        newView.callback = {
            self.updateData()
            self.setUpCamera()
        }
        self.present(newView, animated: true)
    }
    
  
    
    @objc private func didTapTakePhoto(){
        AudioServicesPlaySystemSound(1113)
        
        DispatchQueue.main.async {
            self.shutterButton.isUserInteractionEnabled = false
            self.shutterButton.layer.borderColor = UIColor.white.cgColor
            
            self.switchButton.isUserInteractionEnabled = false
            self.switchButton.tintColor = .gray
            
            self.settingsButton.isUserInteractionEnabled = false
            self.settingsButton.tintColor = .gray
        }
        
        for i in 1...photoCount {
            let time = timeCount * i
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(time), execute: {
        
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
                
                if(i == self.photoCount){
                    self.shutterButton.isUserInteractionEnabled = true
                    self.shutterButton.layer.borderColor = UIColor.red.cgColor
                    
                    self.switchButton.isUserInteractionEnabled = true
                    self.switchButton.tintColor = .white
                    
                    self.settingsButton.isUserInteractionEnabled = true
                    self.settingsButton.tintColor = .white
                }
            })
        }
        
        AudioServicesPlaySystemSound(1114)
        removePreiewPhoto()
    }
    
    
    //remove imagepreviews
    func removePreiewPhoto(){
        for view in view.subviews{
            for sub in view.subviews {
              //  print(sub.layer.name)
            }
            if(view.layer.name == "photoPreview"){
                view.removeFromSuperview()
            }
         
            
        }
    }
    
    
}
//CIOpTile


extension ViewController: AVCapturePhotoCaptureDelegate {
  
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return}
        let image = UIImage(data:data)
        let imageView = UIImageView(image: image)
    
        
    
        // A portrait effects matte gets generated only if AVFoundation detects a face.
        if var portraitEffectsMatte = photo.portraitEffectsMatte {
       
            if let orientation = photo.metadata[ String(kCGImagePropertyOrientation) ] as? UInt32 {
                portraitEffectsMatte = portraitEffectsMatte.applyingExifOrientation(CGImagePropertyOrientation(rawValue: orientation)!)
              
                let portraitEffectsMattePixelBuffer = portraitEffectsMatte.mattingImage
               
                let portraitEffectsMatteImage = CIImage( cvImageBuffer: portraitEffectsMattePixelBuffer, options: [ .auxiliaryPortraitEffectsMatte: true ] )
              
                //matte
                let filteredImage = UIImage(ciImage: portraitEffectsMatteImage)
    
                
                let filterImg = createFocalBlur(image!, portraitEffectsMatteImage)
                
                 //   .imageOrientation = image?.imageOrientation
                print(image!.size)
            
                print(portraitEffectsMatteImage.extent.size)
          
                print(filterImg)
                                    
                
                UIImageWriteToSavedPhotosAlbum(filterImg!, self, nil, nil)
                //show image on screen
                let imageView = UIImageView(image: filterImg)
                imageView.contentMode = .scaleAspectFill
                imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width/4, height: view.frame.height/4)
                imageView.layer.name = "photoPreview"
             //   view.addSubview(border)
                view.addSubview(imageView)
                
        

                
            }
       

        }
            
            
    
        
        //  session?.stopRunning()
       
  
        
        
        let effects = ["CIComicEffect", "CIOpTile", "CIHighlightShadowAdjust", "CIConvolution9Vertical", "CIDepthOfField", "CIGloom"]
        // save photo with filter
       /* let comicEffect = CIFilter(name: "CIComicEffect")
        comicEffect?.setValue(CIImage(data: data), forKey: kCIInputImageKey)
        let cgImage = self.context.createCGImage(comicEffect!.outputImage!, from: CIImage(data: data)!.extent)!
        let filteredImage = UIImage(cgImage: cgImage)
        UIImageWriteToSavedPhotosAlbum(filteredImage, self, nil, nil)
        
        let imageView2 = UIImageView(image: filteredImage)
        imageView2.contentMode = .scaleAspectFill
        imageView2.frame = CGRect(x: 0, y: 0, width: view.frame.width/4, height: view.frame.height/4)
        imageView2.layer.name = "photoPreview"
        view.addSubview(imageView2)*/
        
        
        //picture white border
    /*    let border = UIView()
        border.backgroundColor = .white
        border.contentMode = .scaleAspectFill
        border.frame = CGRect(x: 0, y: 0, width: view.frame.width/3.8, height: view.frame.height/3.8)
        border.layer.name = "borderFrame"*/
        
        //show image on screen
   /*     imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width/4, height: view.frame.height/4)
        imageView.layer.name = "photoPreview"
     //   view.addSubview(border)
        view.addSubview(imageView)*/
        
        // save normal photo
    //  UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
        
}

    
    
    func createFocalBlur (_ image: UIImage,_ mask: CIImage) -> UIImage? {
        let image2 = CIImage(image: image)!.transformed(by:  CGAffineTransform(rotationAngle: .pi/2))
       
      let invertedMask = mask.applyingFilter("CIColorInvert")
        
        let grayscale =  image2.applyingFilter("CIComicEffect")
        let output =  image2.applyingFilter("CIBlendWithMask", parameters: [
          "inputBackgroundImage" : grayscale,
          "inputMaskImage": mask
        ])

     /*   let output = CIImage(image: image)!.applyingFilter(
        "CIMaskedVariableBlur",
        parameters: [
          "inputMask" : invertedMask,
          "inputRadius": 15.0
        ])*/
        print(output.extent)
        guard let cgImage = context.createCGImage(output, from: output.extent) else {
        return nil
      }
      return UIImage(cgImage: cgImage)
    }
    
    
    
}

*/
