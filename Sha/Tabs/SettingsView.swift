//
//  SettingsView.swift
//  Sha
//
//  Created by Akora on 28.06.22.
//

import UIKit
import simd

class SettingsView: UIViewController {
    var timer: Timer!
    var timeLeft = 3
    
    var timerLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        label.text = ""
        label.textColor = .blue
        label.textAlignment = .center
        label.font = label.font.withSize(80)
        return label
    }()
    
    var shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.red.cgColor
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 70)
        view.addSubview(shutterButton)
        view.addSubview(timerLabel)
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        
   
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        timerLabel.text = "\(timeLeft)"
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.timerLabel.alpha = 1.0
        }, completion: {
            (finished: Bool) -> Void in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                self.timerLabel.alpha = 0.0
            }, completion: nil)
        })
        
        if(timeLeft != 0){
            timeLeft -= 1
        }else {
            timer.invalidate()
            timeLeft = 3
        }
        
    }
    
    @objc func didTapTakePhoto(){
        startTimer()
        
    }

}
