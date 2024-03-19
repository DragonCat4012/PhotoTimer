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
                    
                    VStack(spacing: 5) {
                        HStack {
                            Button(action: {
                                coordinator.presentedView = .start
                                viewModel.stop()
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
                                viewModel.showGridEnabled.toggle()
                            }, label: {
                                Image(systemName: "grid")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            }).foregroundColor(viewModel.showGridEnabled ? .accentColor : .gray)
                            
                            Button(action: {
                                viewModel.toggleLive()
                            }, label: {
                                Image(systemName: viewModel.isLiveOn ? "livephoto" : "livephoto.slash")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            })
                            
                            if coordinator.canDoPortrait {
                                Button(action: {
                                    viewModel.togglePortrait()
                                }, label: {
                                    Image(systemName: "camera.macro")
                                        .font(.system(size: 20, weight: .medium, design: .default))
                                }).foregroundColor(viewModel.isPortraitOn ? .accentColor : .gray)
                            }
                            /*  Button(action: {
                                viewModel.toggleCrop()
                            }, label: {
                                Image(systemName:"rectangle")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            }).foregroundColor(viewModel.isQuadratEnabled ? .accentColor : .gray)*/
                            
                            Spacer()
                            
                            Button(action: {
                                // TODO: naviagte to conenctions
                            }, label: {
                                Image(systemName: "app.connected.to.app.below.fill")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                            })
                        }
                        
                        ZStack {
                            CameraPreview(session: viewModel.session) { tapPoint in
                                viewModel.isFocused = true
                                viewModel.focusLocation = tapPoint
                                viewModel.setFocus(point: tapPoint)
                                
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }.onReceive(viewModel.timer) { _ in
                                viewModel.captureImageFromView()
                            }
                            
                            if viewModel.isFocused {
                                FocusView(position: $viewModel.focusLocation)
                                    .scaleEffect(viewModel.isScaled ? 0.8 : 1)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                            self.viewModel.isScaled = true
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                self.viewModel.isFocused = false
                                                self.viewModel.isScaled = false
                                            }
                                        }
                                    }
                            }
                            
                            if viewModel.showGridEnabled {
                                grid()
                            }
                        }
                        
                        HStack(alignment: .center) {
                            PhotoThumbnail(images: $viewModel.capturedImages)
                            Spacer()
                            CaptureButton(isRunning: $viewModel.isRunning) { viewModel.captureButtonAction() }
                            Spacer()
                            Text("\(viewModel.timeInterval)s").frame(width: 50)
                            Text("\(viewModel.count)/\(viewModel.maxCount)").frame(width: 50)
                        }.padding(.horizontal)
                    }
                }
            }
        } .onAppear {
            viewModel.onAppear(coordinator)
        }
    }
    
    // MARK: Supporting Views
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
}
