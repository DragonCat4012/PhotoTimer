//
//  CameraViewModel.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI
import AVFoundation

class CameraViewModel: ObservableObject {
    @ObservedObject var cameraManager = CameraManager()
    
    @Published var isFlashOn = false
    @Published var isFrontCameraOn = false
    @Published var showAlertError = false
    @Published var showSettingAlert = false
    @Published var isPermissionGranted: Bool = false
    
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
}
