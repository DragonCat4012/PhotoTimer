//
//  SettingsView.swift
//  Sha
//
//  Created by Kiara on 30.06.22.
//

import UIKit

class SettingsView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    var callback: (() -> Void)!
    private var count: Int = 3
    private var time: Int = 3
    private var camera: String = ""
    private var gridEnabled: Bool = true
    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeStepper: UIStepper!
    @IBOutlet weak var PhotoStepper: UIStepper!
    @IBOutlet weak var camerapicker: UIPickerView!
    @IBOutlet weak var gridSwitch: UISwitch!
    
    var pickerDataSource = ["builtInDualCamera", "builtInDualWideCamera", "builtInTripleCamera", "builtInWideAngleCamera", "builtInUltraWideCamera", "builtInTelephotoCamera", "builtInLiDARDepthCamera", "builtInTrueDepthCamera"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
        camerapicker.delegate = self
        camerapicker.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(self.count, forKey: "PhotoCount")
        UserDefaults.standard.set(self.time, forKey: "Timercount")
        UserDefaults.standard.set(self.camera, forKey: "CameraType")
        UserDefaults.standard.set(self.gridEnabled, forKey: "GridEnabled")
        
        self.callback()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.count = UserDefaults.standard.integer(forKey: "PhotoCount")
        self.time = UserDefaults.standard.integer(forKey: "Timercount")
        self.camera = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        self.gridEnabled = UserDefaults.standard.bool(forKey: "GridEnabled")
        update()
    }
    
    func update() {
        timeStepper.value = Double(self.time)
        PhotoStepper.value = Double(self.count)
        timelabel.text = String(self.time)
        countLabel.text = String(self.count)
        
        let index = pickerDataSource.firstIndex(of: self.camera) ?? 0
        camerapicker.selectRow(index, inComponent: 0, animated: true)
        
        gridSwitch.isOn = self.gridEnabled
    }
    
    //SwitchAction
    @IBAction func gridSwitched(_ sender: Any) {
        self.gridEnabled = gridSwitch.isOn
    }
    
    //Setup Picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cameraString = pickerDataSource[row]
        self.camera = cameraString
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
