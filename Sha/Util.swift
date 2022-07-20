//
//  Util.swift
//  Sha
//
//  Created by Kiara on 30.06.22.
//

import Foundation
import AVFoundation
import SwiftUI

struct Util {
    
    static func getCameraType(_ name: String) -> AVCaptureDevice.DeviceType{
        var type: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
        switch name {
        case "builtInDualCamera":
            type = .builtInDualCamera
        case "builtInDualWideCamera":
            type = .builtInDualWideCamera
        case "builtInTripleCamera":
            type = .builtInTripleCamera
        case "builtInWideAngleCamera":
            break
        case "builtInUltraWideCamera":
            type = .builtInUltraWideCamera
        case "builtInTelephotoCamera":
            type = .builtInTelephotoCamera
        case "builtInLiDARDepthCamera":
            if #available(iOS 15.4, *) {
                type = .builtInLiDARDepthCamera
            } else {
                // Fallback on earlier versions
            }
        case "builtInTrueDepthCamera":
            type = .builtInTrueDepthCamera
        case "externalUnknown":
            break
        default:
            break
        }
        return type
    }
    
    static func getSettings() -> AVCapturePhotoSettings{
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])

        return photoSettings
    }
    
}

// MARK: - UIColor Extension
extension UIColor {
    static var accentColor: UIColor {return UIColor(named: "AccentColor") ??  UIColor.blue}
}
