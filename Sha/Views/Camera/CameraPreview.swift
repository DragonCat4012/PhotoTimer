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
    var onTap: (CGPoint) -> Void
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspect
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject {
    
    var parent: CameraPreview
    
    init(_ parent: CameraPreview) {
        self.parent = parent
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        parent.onTap(location)
    }
}

struct FocusView: View {
 
 @Binding var position: CGPoint
 
 var body: some View {
    Circle()
       .frame(width: 70, height: 70)
       .foregroundColor(.clear)
       .border(Color.yellow, width: 1.5)
       .position(x: position.x, y: position.y) // To show view at the specific place
    }
}
