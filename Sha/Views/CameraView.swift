//
//  CameraView.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var coordinator: Coordiantor
    
    var body: some View {
        VStack {
            Text("Aloha, welcoem back")
       
            Button("Settings") {
                // TODO:
                coordinator.presentedView = .settings
                
            }
            
            Button("Host session") {
                // TODO: + add info texts
            }
        }
    }
}
