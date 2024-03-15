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
    @State var photoCountStepperValue = 1
    
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
            }
            Text("CameraPicker ehre oder so")
            Spacer()
            Button("Lets go c:") {
                // TODO:
                coordinator.presentedView = .camera
                
            }
            
            Button("Join session") {
                // TODO: + add info texts
            }
        }.padding()
    }
}
