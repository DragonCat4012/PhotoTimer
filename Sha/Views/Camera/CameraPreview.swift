//
//  CameraPreview.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
 
  let session: AVCaptureSession
 
  func makeUIView(context: Context) -> VideoPreviewView {
     let view = VideoPreviewView()
     view.backgroundColor = .black
     view.videoPreviewLayer.session = session
     view.videoPreviewLayer.videoGravity = .resizeAspect
     view.videoPreviewLayer.connection?.videoOrientation = .portrait
     return view
  }
 
  public func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
 
  class VideoPreviewView: UIView {
     override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
     }
  
     var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
     }
  }
}
