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
    
    @Published var isRunning = false
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // app settings
    @Published var count = 0
    @Published var maxCount = 5
    @Published var timeInterval = 3
    
    // view settings
    @Published var showGridEnabled = true
    
    @Published var isScaled = false
    @Published var isFocused = false
    @Published var focusLocation: CGPoint = .zero
    
    // camera settings
    @Published var isQuadratEnabled = false
    @Published var isLiveOn = false
    @Published var isPortraitOn = false
    @Published var isFlashOn = false
    @Published var isFrontCameraOn = false
    @Published var showAlertError = false
    @Published var showSettingAlert = false
    @Published var isPermissionGranted: Bool = false
    @Published var capturedImage: UIImage?
    @Published var capturedImages = [UIImage]()
    
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
    
    func configureCamera() {
        cameraManager.configureCaptureSession()
    }
    
    func captureImage() {
        requestGalleryPermission()
        let permission = checkGalleryPermissionStatus()
        if permission.rawValue != 2 {
            cameraManager.captureImage { image in
                self.addCapturedImage(image)
                AudioServicesPlaySystemSound(1114)
            }
        }
    }
    
    func addCapturedImage(_ image: UIImage?) {
        guard let image = image else { return }
        
        if capturedImages.count >= 3 {
            capturedImages.popLast()
        }
        capturedImages.insert(image, at: 0)
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
    
    // MARK: View functions
    func onAppear(_ coordinator: Coordiantor) {
        maxCount = coordinator.photoCount
        timeInterval = coordinator.timeIntervall
        stop()
        checkForDevicePermission()
    }
    
    func toggleLive() {
        isLiveOn.toggle()
        if isPortraitOn && isLiveOn {
            isPortraitOn = false
        }
        updateManagerSettings()
    }
    
    func togglePortrait() {
        isPortraitOn.toggle()
        if isPortraitOn && isLiveOn {
            isLiveOn = false
        }
        updateManagerSettings()
    }
    
    func toggleCrop() {
        isQuadratEnabled.toggle()
        updateManagerSettings()
    }
    
    func updateManagerSettings() {
        cameraManager.isLiveEnabled = isLiveOn
        cameraManager.isPortraitEnabled = isPortraitOn
        cameraManager.isPhotCropEnabled = isQuadratEnabled
        
        cameraManager.configureCaptureSession()
    }
    
    func captureButtonAction() {
        if isRunning {
            stop()
        } else {
            start()
        }
        isRunning.toggle()
    }
    
    func stop() {
        timer.upstream.connect().cancel()
    }
    
    func start() {
        count = 0
        let seconds = Double(timeInterval)
        timer = Timer.publish(every: seconds, on: .main, in: .common).autoconnect()
    }
    
    func captureImageFromView() {
        count += 1
        if count == maxCount {
            stop()
        }
        captureImage()
    }
    
    // MARK: Camera Settings
    func switchCamera() {
        cameraManager.position = cameraManager.position == .front ? .back : .front
        cameraManager.switchCamera()
        isFrontCameraOn.toggle()
    }
    
    func switchFlash() {
        isFlashOn.toggle()
        cameraManager.toggleTorch(tourchIsOn: isFlashOn)
    }
    
    func setFocus(point: CGPoint) {
        cameraManager.setFocusOnTap(devicePoint: point)
    }
}
