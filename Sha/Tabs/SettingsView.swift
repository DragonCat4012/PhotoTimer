//
//  SettingsView2.swift
//  Sha
//
//  Created by Kiara on 30.06.22.
//

import UIKit

class SettingsView: UIViewController {
    var callback: (() -> Void)!
    private var count: Int = 3
    private var time: Int = 3
    private var camera: String = ""
    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeStepper: UIStepper!
    @IBOutlet weak var PhotoStepper: UIStepper!
    @IBOutlet weak var camerapicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(self.count, forKey: "PhotoCount")
        UserDefaults.standard.set(self.time, forKey: "Timercount")
        UserDefaults.standard.set(self.camera, forKey: "CameraType")
        self.callback()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.count = UserDefaults.standard.integer(forKey: "PhotoCount")
        self.time = UserDefaults.standard.integer(forKey: "Timercount")
        self.camera = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        update()
    }
    
    func update() {
        timeStepper.value = Double(self.time)
        PhotoStepper.value = Double(self.count)
        timelabel.text = String(self.time)
        countLabel.text = String(self.count)
      }
    
    @IBAction func timeStepUp(_ sender: UIStepper) {
        self.time = Int(sender.value)
        update()
        
    }
    
    @IBAction func countStepUp(_ sender: UIStepper) {
        self.count = Int(sender.value)
        update()
    }
}
