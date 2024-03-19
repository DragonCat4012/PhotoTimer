//
//  StartView.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var coordinator: Coordiantor
    
    @State var timeStepperValue = 3
    @State var photoCountStepperValue = 5
    
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().backgroundColor = .red
        UITabBar.appearance().backgroundColor = .green
        
        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.red]
    }
    
    var body: some View {
            VStack {
                Text("Aloha, welcome back")
                HStack {
                    Text("Time")
                    Stepper("", value: $timeStepperValue, in: 3...20, step: 1)
                    Text("\(timeStepperValue)")
                }
                HStack {
                    Text("Photos")
                    Stepper("", value: $photoCountStepperValue, in: 1...100, step: 1)
                    Text("\(photoCountStepperValue)")
                }.padding(.bottom, 20)
                Text("Portrait effect only works with a 'DualWideCamera'")
                Picker("Cameras?", selection: $coordinator.cameras) {
                    ForEach(coordinator.cameras, id: \.self) { camera in
                        Text("\(camera.rawValue.replacingOccurrences(of: "AVCaptureDeviceTypeBuiltIn", with: ""))")
                    }
                }
                Spacer()
                Button("Lets go c:") {
                    coordinator.photoCount = photoCountStepperValue
                    coordinator.timeIntervall = timeStepperValue
                    coordinator.presentedView = .camera
                }.buttonStyle(PrimaryStyle())
                
                Button("Join session") {
                    // TODO: + add info texts, portrait and live option
                }.buttonStyle(SecondaryStyle())
                Text("Join a session to preview your results on another device (Needs local network access)")
        }.padding()
        
    }
}
struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
