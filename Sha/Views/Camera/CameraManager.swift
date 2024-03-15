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
    
    @Published var status = Status.unconfigured
    @Published var position: AVCaptureDevice.Position = .back
    
    
    let session = AVCaptureSession()
    
    let photoOutput = AVCapturePhotoOutput()
    
    var videoDeviceInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.demo.sessionQueue")
    
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
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
            
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
    
    
    func switchCamera() {
       guard let videoDeviceInput else { return }
      
       session.removeInput(videoDeviceInput)
      
       setupVideoInput()
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
}
