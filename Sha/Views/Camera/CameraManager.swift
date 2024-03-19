//
//  CameraManager.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI
import AVFoundation

class CameraManager: ObservableObject {
    
    enum Status {
        case configured
        case unconfigured
        case unauthorized
        case failed
    }
    
    var selectedCamera: AVCaptureDevice.DeviceType?
    
    @Published var isPortraitEnabled = false
    @Published var isLiveEnabled = false
    @Published var isPhotCropEnabled = false
    @Published var status = Status.unconfigured
    @Published var position: AVCaptureDevice.Position = .back
    @Published private var flashMode: AVCaptureDevice.FlashMode = .off
    
    let session = AVCaptureSession()
    
    let photoOutput = AVCapturePhotoOutput()
    
    var videoDeviceInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.demo.sessionQueue")
    
    private var cameraDelegate: CameraDelegate?
    
    func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.status == .unconfigured else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            self.setupVideoInput()
            
            self.setupPhotoOutput()
            self.session.commitConfiguration()
            self.startCapturing()
        }
    }
    
    private func setupVideoInput() {
        do {
            print(selectedCamera)
            var camera = AVCaptureDevice.default(for: .video)
            print(camera?.deviceType)
            if let selectedCamera = selectedCamera {
                camera = AVCaptureDevice.default(selectedCamera, for: .video, position: position)
            }
            
            guard let camera else {
                print("CameraManager: Video device is unavailable.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                videoDeviceInput = videoInput
                status = .configured
            } else {
                print("CameraManager: Couldn't add video device input to the session.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
        } catch {
            print("CameraManager: Couldn't create video device input: \(error)")
            status = .failed
            session.commitConfiguration()
            return
        }
    }
    
    private func setupPhotoOutput() {
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality // work for ios 15.6 and the older versions
            //photoOutput.maxPhotoDimensions = .init(width: 4032, height: 3024) // for ios 16.0*
            
            status = .configured
        } else {
            print("CameraManager: Could not add photo output to the session")
            // Set an error status and return
            status = .failed
            session.commitConfiguration()
            return
        }
    }
    
    private func startCapturing() {
        if status == .configured {
            self.session.startRunning()
        } else if status == .unconfigured || status == .unauthorized {
            DispatchQueue.main.async {
                // Handle errors related to unconfigured or unauthorized states
                /* self.alertError = AlertError(title: "Camera Error", message: "Camera configuration failed. Either your device camera is not available or its missing permissions", primaryButtonTitle: "ok", secondaryButtonTitle: nil, primaryAction: nil, secondaryAction: nil)*/
                //  self.shouldShowAlertView = true
            }
        }
    }
    
    func stopCapturing() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func captureImage(_ onSucess: @escaping (UIImage?) -> ()) {
       sessionQueue.async { [weak self] in
          guard let self else { return }
      
          var photoSettings = AVCapturePhotoSettings()
      
          // Capture HEIC photos when supported
          if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
             photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
          }
      
          if self.videoDeviceInput!.device.isFlashAvailable {
            photoSettings.flashMode = self.flashMode
          }
      
          photoSettings.isHighResolutionPhotoEnabled = true
      

          if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
             photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
          }

          photoSettings.photoQualityPrioritization = .quality
      
          if let videoConnection = photoOutput.connection(with: .video), videoConnection.isVideoOrientationSupported {
             videoConnection.videoOrientation = .portrait
          }
      
          cameraDelegate = CameraDelegate { [weak self] image in
              onSucess(image)
          }
      
          if let cameraDelegate {
             self.photoOutput.capturePhoto(with: photoSettings, delegate: cameraDelegate)
          }
       }
    }
    
    // MARK: Camera Settings
    func switchCamera() {
       guard let videoDeviceInput else { return }
      
       session.removeInput(videoDeviceInput)
      
       setupVideoInput()
    }
    
    func toggleTorch(tourchIsOn: Bool) {
        var device = AVCaptureDevice.default(for: .video)
        if let selectedCamera = selectedCamera {
            device = AVCaptureDevice.default(selectedCamera, for: .video, position: position)
        }
        
        if let device = device  {
          if device.hasTorch {
            do {
                try device.lockForConfiguration()

                flashMode = tourchIsOn ? .on : .off
                /*if flashMode == .on  && position == .front {
                    switchCamera() // fron and flash doesnt work
                }*/ // TODO: why not working

                if tourchIsOn {
                   try device.setTorchModeOn(level: 1.0)
                } else {
                   device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
            print("Failed to set torch mode: \(error).")
          }
       } else {
          print("Torch not available for this device.")
       }
    }
}
    
    func setFocusOnTap(devicePoint: CGPoint) {
       guard let cameraDevice = self.videoDeviceInput?.device else { return }
       do {
          try cameraDevice.lockForConfiguration()

          if cameraDevice.isFocusModeSupported(.autoFocus) {
             cameraDevice.focusMode = .autoFocus
             cameraDevice.focusPointOfInterest = devicePoint
          }

          cameraDevice.exposurePointOfInterest = devicePoint
          cameraDevice.exposureMode = .autoExpose

          cameraDevice.isSubjectAreaChangeMonitoringEnabled = true

          cameraDevice.unlockForConfiguration()
       } catch {
          print("Failed to configure focus: \(error)")
       }
    }
}
