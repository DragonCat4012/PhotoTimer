//
//  MultipeerConnectionManager.swift
//  Sha
//
//  Created by Kiara on 10.01.23.
//

import UIKit
import MultipeerConnectivity


class MultipeerViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    var peerID = MCPeerID(displayName: (UIDevice.current.name + " - sha"))
    private let serviceType = "sha-phototimer"
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    var currentImage: UIImage?
    
    override func viewDidLoad() {
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession?.delegate = self
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("✅ Connected: \(peerID.displayName)")

        case .connecting:
            print("⚠️ Connecting: \(peerID.displayName)")

        case .notConnected:
            print("❌ Not Connected: \(peerID.displayName)")

        @unknown default:
            print("❓Unknown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self!.currentImage = image
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
         
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
         
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
         
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
          print(">>> \(UIDevice.current.name) connected!!!!")
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    @objc func startHosting() {
        print(">>> \(UIDevice.current.name) starting to hos a session")
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: mcSession)
       // mcAdvertiserAssistant?.delegate = self
        mcAdvertiserAssistant?.start()
    }

    @objc func joinSession() {
        print(">>> \(UIDevice.current.name) is conencting")
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: serviceType, session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    
    func shareImage(_ image: UIImage){
        guard let mcSession = mcSession else { return }

        if mcSession.connectedPeers.count > 0 {
            if let imageData = image.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                    print("send image to \(mcSession.connectedPeers.count) connections")
                } catch {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    
}
