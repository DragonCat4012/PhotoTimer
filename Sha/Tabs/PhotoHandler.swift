//
//  PhotoHandler.swift
//  Sha
//
//  Created by Kiara on 29.12.22.
//

import AVFoundation
import Photos
import UIKit


extension CameraView: AVCapturePhotoCaptureDelegate {
    
    func setZoom(_ device: AVCaptureDevice){
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration()}
            
            let maxZoom = device.maxAvailableVideoZoomFactor
            device.videoZoomFactor = maxZoom/1.6
        } catch {
            NSLog("⚠️ zoom for dualwidecamera not set")
            print(error)
        }
    }
    
    func setUpCamera() {
        let camera = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        let newSession = AVCaptureSession()
        self.session = newSession
        
        if let device = AVCaptureDevice.default(Util.getCameraType(camera), for: .video, position: AVCaptureDevice.Position.back){
            if(camera == "builtInDualWideCamera") {setZoom(device)}
            
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
    
    
    @objc func takePhoto(){
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
    
    func checkCameraPerms() {
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
    
    //MARK: Photo saving ect
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
        maskFilter?.setValue(12, forKey: "inputRadius")
        
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
