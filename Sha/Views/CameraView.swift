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
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isRunning = false
    @State var count = 0
    @State var maxCount = 5
    
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
                        
                        CameraPreview(session: viewModel.session).onReceive(timer) { _ in
                            captureImage()
                        }
                        
                        HStack {
                            PhotoThumbnail(images: $viewModel.capturedImages)
                            
                            Spacer()
                            CaptureButton { if isRunning {
                                stop()
                            } else {
                                start()
                            }
                                isRunning.toggle() }
                            Spacer()
                            Text("\(count)/\(maxCount)")
                        }.padding(.horizontal)
                    }
                }
            }
        } .onAppear {
            stop()
            viewModel.checkForDevicePermission()
        }
    }
    
    func stop() {
        timer.upstream.connect().cancel()
    }
    
    func start() {
        count = 0
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    func captureImage() {
        count += 1
        if count == maxCount {
            stop()
        }
        viewModel.captureImage()
    }
}
