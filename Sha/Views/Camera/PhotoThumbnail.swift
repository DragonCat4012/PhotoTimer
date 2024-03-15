//
//  PhotoThumbnail.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import SwiftUI

struct PhotoThumbnail: View {
    @Binding var images: [UIImage]
    
    var body: some View {
        if !images.isEmpty {
            ZStack(alignment: .leading) {
                if images.count >= 3 {
                    Image(uiImage: images[2])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                if images.count >= 2 {
                    Image(uiImage: images[1])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 55)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                Image(uiImage: images[0])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }.frame(width: 100)
        } else {
            Rectangle()
                .frame(width: 100, height: 60, alignment: .center)
                .foregroundColor(.black)
        }    }
}


struct CaptureButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(.white)
                .frame(width: 70, height: 70, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 59, height: 59, alignment: .center)
                )
        }
    }
}

struct CameraSwitchButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        }
    }
}
