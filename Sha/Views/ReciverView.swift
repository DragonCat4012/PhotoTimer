//
//  ReciverView.swift
//  Sha
//
//  Created by Kiara on 10.01.23.
//

import UIKit
import MultipeerConnectivity

class ReciverView: MultipeerViewController {
    
  //  var image: UIImage?
    var connectButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = 20
        button.setBackgroundImage(UIImage(systemName: "app.connected.to.app.below.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     //   previewLayer.frame = view.bounds
        
        connectButton.center = CGPoint(x: view.frame.size.width/2 - 70, y: view.frame.size.height - 70)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (mcSession == nil || mcSession?.connectedPeers.count == 0){
            mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            mcSession?.delegate = self
            joinSession()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectButton.addTarget(self, action: #selector(joinSession), for: .touchUpInside)
        view.addSubview(connectButton)
        view.backgroundColor = .black
        if ((currentImage) != nil) {
            view.addSubview(UIImageView(image: currentImage))
        }
        
        //multiper MultipeerConnectivity
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
       
    }
}
