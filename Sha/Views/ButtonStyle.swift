//
//  ButtonStyle.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI

struct PrimaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 15)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}

struct SecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 15)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(0.5))
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}
