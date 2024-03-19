//
//  Sha.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI
import AVFoundation

enum AppView {
    case start
    case camera
    case settings
}

class Coordiantor: ObservableObject {
    static let shared = Coordiantor()
    @Published var presentedView: AppView = .start
    
    @Published var photoCount = 5
    @Published var timeIntervall = 3
    @Published var canDoPortrait = false
    @Published var cameras = [AVCaptureDevice.DeviceType]()
    @Published var selectedCamera: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
    
    init() {
        if let _ = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            canDoPortrait = true
        }
        
        let options: [AVCaptureDevice.DeviceType] = [ .builtInDualCamera, .builtInDualWideCamera, .builtInTripleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .builtInTrueDepthCamera, .builtInTrueDepthCamera, .builtInWideAngleCamera ]
        options.forEach { device in
            if let _ = AVCaptureDevice.default(device, for: .video, position: .back) {
                cameras.append(device)
            }
        }
    }
}

@main
struct PhotoTimer: App {
    @ObservedObject var coordinator = Coordiantor.shared
    
    var body: some Scene {
        WindowGroup {
            switch Coordiantor.shared.presentedView {
            case .start:
                StartView().environmentObject(coordinator)
                    .onAppear {
                        coordinator.selectedCamera = coordinator.cameras.first ?? .builtInWideAngleCamera
                    }
            case .camera:
                CameraView().environmentObject(coordinator)
            case .settings:
                StartView().environmentObject(coordinator)
            }
        }
    }
}
