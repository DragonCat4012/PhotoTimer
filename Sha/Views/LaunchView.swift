//
//  LaunchView.swift
//  Sha
//
//  Created by Kiara on 19.07.22.
//

import UIKit

class LaunchView: UIViewController {
    private var count: Int = 3
    private var time: Int = 3
    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeStepper: UIStepper!
    @IBOutlet weak var PhotoStepper: UIStepper!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var GoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(self.count, forKey: "PhotoCount")
        UserDefaults.standard.set(self.time, forKey: "Timercount")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.count = UserDefaults.standard.integer(forKey: "PhotoCount")
        self.time = UserDefaults.standard.integer(forKey: "Timercount")
        update()
    }
    
    func update() {
        timeStepper.value = Double(self.time)
        PhotoStepper.value = Double(self.count)
        timelabel.text = String(self.time)
        countLabel.text = String(self.count)
        cameraLabel.text = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
    }
    
    //Button action
    @IBAction func tapButton(_ sender: Any) {
        let newView = storyboard?.instantiateViewController(withIdentifier: "CameraView") as! CameraView
        newView.modalTransitionStyle = .crossDissolve
        newView.view.layer.speed = 0.1
        
        self.navigationController?.pushViewController(newView, animated: true)
    }
    
    //Stepper Actions
    @IBAction func timeStepUp(_ sender: UIStepper) {
        self.time = Int(sender.value)
        update()
        
    }
    
    @IBAction func countStepUp(_ sender: UIStepper) {
        self.count = Int(sender.value)
        update()
    }
}

