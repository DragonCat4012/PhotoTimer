//
//  Sha.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI

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
}

@main
struct PhotoTimer: App {
    @ObservedObject var coordinator = Coordiantor.shared
    
    var body: some Scene {
        WindowGroup {
            switch Coordiantor.shared.presentedView {
            case .start:
                StartView().environmentObject(coordinator)
            case .camera:
                CameraView().environmentObject(coordinator)
            case .settings:
                StartView().environmentObject(coordinator)
            }
        }
    }
}
