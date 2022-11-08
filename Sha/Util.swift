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

extension CameraView {
    private func drawLine(_ point1: CGPoint, _ point2: CGPoint, _ color: CGColor = UIColor.white.withAlphaComponent(0.5).cgColor){
        let stroke = UIBezierPath()
        stroke.move(to: CGPoint(x: point1.x, y: point1.y))
        stroke.addLine(to: CGPoint(x: point2.x, y: point2.y))
        stroke.close()
        
        let layer =  CAShapeLayer()
        layer.path = stroke.cgPath
        layer.strokeColor = color
        
        layer.lineWidth = 1
        layer.name = "GridLayer"
        self.view.layer.addSublayer(layer)
    }
    
    func drawGrid(){
        let thirdX = self.view.frame.maxX  / 3
        let thirdY = self.view.frame.maxY / 3
        
        // vertical lines
        drawLine(CGPoint(x: thirdX, y: 0), CGPoint(x: thirdX, y: self.view.frame.maxY))
        drawLine(CGPoint(x: 2 * thirdX, y: 0), CGPoint(x: 2 * thirdX, y: self.view.frame.maxY))
        
        //horizontal lines
        drawLine(CGPoint(x: 0, y: thirdY), CGPoint(x: self.view.frame.maxX, y: thirdY))
        drawLine(CGPoint(x: 0, y: 2 * thirdY), CGPoint(x: self.view.frame.maxX, y: 2 * thirdY))
        
        //draw scaledversion
        /*   let scaledX = self.view.frame.maxX  * 0.05
         let scaledY = self.view.frame.maxY * 0.05
         let color = UIColor.red.withAlphaComponent(0.5).cgColor
         
         drawLine(CGPoint(x: 0, y: scaledY), CGPoint(x: self.view.frame.maxX, y: scaledY),color)
         drawLine(CGPoint(x: 0, y: self.view.frame.maxY - scaledY), CGPoint(x: self.view.frame.maxX, y: self.view.frame.maxY - scaledY),color)
         
         drawLine(CGPoint(x: scaledX, y: 0), CGPoint(x: scaledX, y: self.view.frame.maxY),color)
         drawLine(CGPoint(x: self.view.frame.maxX - scaledX, y: 0), CGPoint(x: self.view.frame.maxX  - scaledX, y: self.view.frame.maxY),color)*/
    }
    
    func removePreviewLayer(){
        for view in view.subviews {
            if(view.layer.name == "photoPreview"){
                view.removeFromSuperview()
            }
        }
    }
    
    @objc func navigateToSettings(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "SettingsView") as! SettingsView
        newView.modalTransitionStyle = .crossDissolve
        newView.view.layer.speed = 0.1
        
        newView.callback = {
            self.updateData()
            self.setUpCamera()
        }
        self.navigationController?.pushViewController(newView, animated: true)
    }
}
