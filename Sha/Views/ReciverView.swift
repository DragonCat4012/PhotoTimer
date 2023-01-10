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
    
    var previewView = UIImageView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.frame = view.bounds
        hostLabel.center = CGPoint(x: view.frame.size.width/2, y: 60)
        connectButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 70)
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
                self.previewView.image = self.currentImage
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(connectButton)
        view.addSubview(hostLabel)
        
        connectButton.addTarget(self, action: #selector(joinSession), for: .touchUpInside)
        hostLabel.text = "--"
        hostLabel.layer.cornerRadius = 8
        callUpdate()
    
        view.backgroundColor = .black
        if ((currentImage) != nil) {
            view.addSubview(UIImageView(image: currentImage))
        }
        
        //multiper MultipeerConnectivity
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
       
    }
}
