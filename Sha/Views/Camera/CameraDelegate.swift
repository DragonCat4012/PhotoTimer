//
//  CameraDelegate.swift
//  Sha
//
//  Created by Kiara on 15.03.24.
//

import UIKit
import AVFoundation
import Photos

class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var isPortraitEnabled = true
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("CameraManager: Error while capturing photo: \(error)")
            completion(nil)
            return
        }
        
        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            saveImageToGallery(capturedImage)
            completion(capturedImage)
            print("captrue portrait?")
            if isPortraitEnabled {
                guard let mattingImage = photo.portraitEffectsMatte?.mattingImage else { return }
                let portraitEffectsMatte = CIImage(cvPixelBuffer: mattingImage)
                //resize portraiteffect to image
                
                let matteResized = portraitEffectsMatte.transformed (by: CGAffineTransform(scaleX: 2.0, y: 2.0) )
                
                //invert depth mask
                let invertFilter = CIFilter(name: "CIColorInvert")
                invertFilter?.setValue(matteResized, forKey: kCIInputImageKey)
                
                //create blur effect
                let inputCIImage = CIImage(image: capturedImage)
                let maskImage = invertFilter?.outputImage!
                var blurredImage = appyBlur(background: inputCIImage, mask: maskImage)
                
                //rotate and crop result
                blurredImage = blurredImage!.cropped(to: inputCIImage!.extent)
                blurredImage = blurredImage!.oriented(.right)
                
                
                guard let cgIm = CIContext().createCGImage(blurredImage!, from: (blurredImage?.extent)!) else {  NSLog("⚠️ ciContext failed"); return}
                
                let FinalUIImage = UIImage(cgImage: cgIm)
                saveImageToGallery(FinalUIImage)
                // completion(capturedImage)
            }
        } else {
            print("CameraManager: Image not fetched.")
        }
        
    }
    
    func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            if success {
                print("Image saved to gallery.")
            } else if let error {
                print("Error saving image to gallery: \(error)")
            }
        }
    }
    
    func appyBlur(background: CIImage?, mask: CIImage?) -> CIImage?{
        guard let background else { return nil}
        guard let mask else { return nil}
        
        let maskFilter = CIFilter(name: "CIMaskedVariableBlur")
        maskFilter?.setValue(background, forKey: "inputImage")
        maskFilter?.setValue(mask, forKey: "inputMask")
        maskFilter?.setValue(12, forKey: "inputRadius")
        
        guard let image = maskFilter?.outputImage else {
            NSLog("⚠️ failed blurring image")
            return nil
        }
        return image
    }
    
}
