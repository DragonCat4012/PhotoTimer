//
//  CameraView.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var coordinator: Coordiantor
    @ObservedObject var viewModel = CameraViewModel()
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: {
                            }, label: {
                                Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            })
                            .accentColor(viewModel.isFlashOn ? .yellow : .white)
                            
                            Button(action: {
                                viewModel.switchCamera()
                            }, label: {
                                Image(systemName: viewModel.isFrontCameraOn ? "camera.fill" : "camera")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            })
                        }
                        
                        CameraPreview(session: viewModel.session)
                        
                        /* HStack {
                         PhotoThumbnail()
                         Spacer()
                         CaptureButton { // Call the capture method }
                         Spacer()
                         CameraSwitchButton { // Call the camera switch method }
                         }*/
                           // .padding(20)
                    }
                }
            }
        } .onAppear {
            // viewModel.setupBindings()
            viewModel.checkForDevicePermission()
        }
    }
}
