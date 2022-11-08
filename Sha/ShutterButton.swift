//
//  Button.swift
//  Sha
//
//  Created by Kiara on 07.11.22.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/56077276/how-to-create-uibutton-pulse-animation-using-swift
class PulsatingButton: UIButton {
    let pulseLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.clear.cgColor
        shape.lineWidth = 10
        shape.fillColor = UIColor.red.withAlphaComponent(0.3).cgColor
        shape.lineCap = .round
        return shape
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShapes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShapes()
    }
    
    fileprivate func setupShapes() {
        setNeedsLayout()
        layoutIfNeeded()
        
        let backgroundLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: self.center, radius: bounds.size.height/2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        pulseLayer.frame = bounds
        pulseLayer.path = circularPath.cgPath
        pulseLayer.position = self.center
        self.layer.addSublayer(pulseLayer)
        
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = .round
        self.layer.addSublayer(backgroundLayer)
    }
    
    func pulse() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.2
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        pulseLayer.add(animation, forKey: "pulsing")
    }
    
    func stopPulse(){
        pulseLayer.removeAllAnimations()
    }
}
