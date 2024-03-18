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
    @State var showGridEnabled = true
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 5) {
                        HStack {
                            Button(action: {
                                coordinator.presentedView = .start
                                stop()
                            }, label: {
                                Image(systemName: "gear" )
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            })
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.switchFlash()
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
                            
                            Button(action: {
                                showGridEnabled.toggle()
                            }, label: {
                                Image(systemName: "grid")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            }).foregroundColor(showGridEnabled ? .accentColor : .gray)
                            
                            Spacer()
                            
                            Button(action: {
                                // TODO: naviagte to conenctions
                            }, label: {
                                Image(systemName: "app.connected.to.app.below.fill")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            })
                        }
                        
                        ZStack {
                            CameraPreview(session: viewModel.session).onReceive(timer) { _ in
                                captureImage()
                            }
                            if showGridEnabled {
                                grid()
                            }
                        }
                        
                        HStack(alignment: .center) {
                            PhotoThumbnail(images: $viewModel.capturedImages)
                            Spacer()
                            CaptureButton(isRunning: $isRunning) { captureButtonAction() }
                            Spacer()
                            Text("\(coordinator.timeIntervall)s").frame(width: 50)
                            Text("\(count)/\(maxCount)").frame(width: 50)
                        }.padding(.horizontal)
                    }
                }
            }
        } .onAppear {
            maxCount = coordinator.photoCount
            stop()
            viewModel.checkForDevicePermission()
        }
    }
    
    func verticalGrid() -> some View {
        HStack {
            Spacer()
            Rectangle().frame(width: 1)
            Spacer()
            Rectangle().frame(width: 1)
            Spacer()
            Rectangle().frame(width: 1)
            Spacer()
        }.frame(maxWidth: .infinity)
    }
    
    func horizontalGrid() -> some View {
        VStack {
            Spacer()
            Rectangle().frame(height: 1)
            Spacer()
            Rectangle().frame(height: 1)
            Spacer()
            Rectangle().frame(height: 1)
            Spacer()
        }
    }
    
    func grid() -> some View {
        ZStack {
            horizontalGrid()
            verticalGrid()
        }
    }
    
    //MARK: not view stuff
    
    func captureButtonAction() {
        if isRunning {
            stop()
        } else {
            start()
        }
        isRunning.toggle()
    }
    
    func stop() {
        timer.upstream.connect().cancel()
    }
    
    func start() {
        count = 0
        let seconds = Double(coordinator.timeIntervall)
        timer = Timer.publish(every: seconds, on: .main, in: .common).autoconnect()
    }
    
    func captureImage() {
        count += 1
        if count == maxCount {
            stop()
        }
        viewModel.captureImage()
    }
}
