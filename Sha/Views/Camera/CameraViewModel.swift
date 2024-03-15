//
//  CameraViewModel.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI
import AVFoundation
import Photos

class CameraViewModel: ObservableObject {
    @ObservedObject var cameraManager = CameraManager()
    
    @Published var isFlashOn = false
    @Published var isFrontCameraOn = false
    @Published var showAlertError = false
    @Published var showSettingAlert = false
    @Published var isPermissionGranted: Bool = false
    @Published var capturedImage: UIImage?
    
    var session: AVCaptureSession = .init()
    
    init() {
        session = cameraManager.session
    }
    
    deinit {
        cameraManager.stopCapturing()
    }
    
    func checkForDevicePermission() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if videoStatus == .authorized {
            isPermissionGranted = true
            configureCamera()
        } else if videoStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { _ in })
        } else if videoStatus == .denied {
            isPermissionGranted = false
            showSettingAlert = true
        }
    }
    
    func switchCamera() {
        cameraManager.position = cameraManager.position == .front ? .back : .front
        cameraManager.switchCamera()
        isFrontCameraOn.toggle()
    }
    
    func configureCamera() {
        cameraManager.configureCaptureSession()
    }
    
    func captureImage() {
       requestGalleryPermission()
       let permission = checkGalleryPermissionStatus()
       if permission.rawValue != 2 {
           cameraManager.captureImage { image in
               print("eeee")
               self.capturedImage = image
           }
       }
    }

    // Ask for the permission for photo library access
    func requestGalleryPermission() {
       PHPhotoLibrary.requestAuthorization { status in
         switch status {
         case .authorized:
            break
         case .denied:
            self.showSettingAlert = true
         default:
            break
         }
       }
    }
     
    func checkGalleryPermissionStatus() -> PHAuthorizationStatus {
       return PHPhotoLibrary.authorizationStatus()
    }
}
