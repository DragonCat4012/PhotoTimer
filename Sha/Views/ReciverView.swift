//
//  ReciverView.swift
//  Sha
//
//  Created by Kiara on 10.01.23.
//

import UIKit
import MultipeerConnectivity

class ReciverView: MultipeerViewController {
    
    var connectButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = 20
        button.setBackgroundImage(UIImage(systemName: "app.connected.to.app.below.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var hostLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 220, height: 40))
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    var previewView = UIView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.frame = view.bounds
        hostLabel.center = CGPoint(x: view.frame.size.width/2, y: 60)
        connectButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 70)
        previewView.frame = CGRect(x: 0, y: view.frame.size.height/3, width: view.frame.width, height: view.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (mcSession == nil || mcSession?.connectedPeers.count == 0){
            mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            mcSession?.delegate = self
            joinSession()
        }
    }
    
    override func callUpdate() {
        DispatchQueue.main.async {
            self.hostLabel.backgroundColor = self.connected ? .green : .red
            if(self.mcSession == nil){return}
            if(self.mcSession?.connectedPeers.count != 0){
                self.hostLabel.text = self.mcSession!.connectedPeers[0].displayName
        }
            
            if((self.currentImage) != nil){
                if(self.previewView.subviews.count > 20){
                    for view in self.previewView.subviews{
                        view.removeFromSuperview()
                    }
                }
              
                var img = self.currentImage!.rotate(radians: .pi/2)!// Rotate 90 degrees
                img = self.resizeImage(image: img, targetSize: CGSizeMake(self.previewView.frame.width, self.previewView.frame.height))
                self.previewView.addSubview(UIImageView(image: img))
                print("➤➤➤ image set for preview \(self.previewView.subviews.count)")
            }else {
                print("❌ no image received")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectButton.addTarget(self, action: #selector(joinSession), for: .touchUpInside)
        hostLabel.text = "--"
        hostLabel.layer.cornerRadius = 8
        hostLabel.layer.masksToBounds = true
        previewView.contentMode = .center
        
        callUpdate()
    
        view.addSubview(previewView)
        view.addSubview(connectButton)
        view.addSubview(hostLabel)
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
}

//rotate received image https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift
extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension ReciverView{ //https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size
       
       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height
       
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }
       
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return newImage!
    }
}
