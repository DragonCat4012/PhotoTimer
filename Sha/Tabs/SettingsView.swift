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
    private var blurAmount: Int = 10
    
    private var gridEnabled: Bool = true
    private var liveEnabled: Bool = false
    private var portraitEnabled: Bool = true
    
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeStepper: UIStepper!
    @IBOutlet weak var PhotoStepper: UIStepper!
    
    @IBOutlet weak var gridSwitch: UISwitch!
    @IBOutlet weak var liveSwitch: UISwitch!
    @IBOutlet weak var portraitSwitch: UISwitch!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    
    @IBAction func cameraPick(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let index = pickerDataSource.firstIndex(of: self.camera) ?? 0
        pickerView.selectRow(index, inComponent: 0, animated: true)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select a camera", message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = cameraButton
        alert.popoverPresentationController?.sourceRect = cameraButton.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(UIAlertAction) in
        }))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {(UIAlertAction) in
            let cameraString = self.pickerDataSource[pickerView.selectedRow(inComponent: 0)]
            self.camera = cameraString
            self.update()
        }))
        self.present(alert, animated: true)
    }
    
    var pickerDataSource = ["builtInDualCamera", "builtInDualWideCamera", "builtInTripleCamera", "builtInWideAngleCamera", "builtInUltraWideCamera", "builtInTelephotoCamera", "builtInLiDARDepthCamera", "builtInTrueDepthCamera"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(self.count, forKey: "PhotoCount")
        UserDefaults.standard.set(self.time, forKey: "Timercount")
        UserDefaults.standard.set(self.camera, forKey: "CameraType")
        UserDefaults.standard.set(self.blurAmount, forKey: "BlurAmount")
        
        UserDefaults.standard.set(self.gridEnabled, forKey: "GridEnabled")
        UserDefaults.standard.set(self.liveEnabled, forKey: "LiveEnabled")
        UserDefaults.standard.set(self.portraitEnabled, forKey: "PortraitEnabled")
        self.callback()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.count = UserDefaults.standard.integer(forKey: "PhotoCount")
        self.time = UserDefaults.standard.integer(forKey: "Timercount")
        self.camera = UserDefaults.standard.string(forKey: "CameraType") ?? "builtInWideAngleCamera"
        self.blurAmount = UserDefaults.standard.integer(forKey: "BlurAmount")
        
        self.gridEnabled = UserDefaults.standard.bool(forKey: "GridEnabled")
        self.liveEnabled = UserDefaults.standard.bool(forKey: "LiveEnabled")
        self.portraitEnabled = UserDefaults.standard.bool(forKey: "PortraitEnabled")
        
        update()
    }
    
    func update() {
        timeStepper.value = Double(self.time)
        PhotoStepper.value = Double(self.count)
        timelabel.text = String(self.time)
        countLabel.text = String(self.count)
        
        cameraButton.setTitle(self.camera, for: .normal)
        gridSwitch.isOn = self.gridEnabled
        liveSwitch.isOn = self.liveEnabled
        portraitSwitch.isOn = self.portraitEnabled
    }
    
    //SwitchAction
    @IBAction func gridSwitched(_ sender: UISwitch) {
        print(sender.restorationIdentifier)
        print(sender.isOn)
        switch sender.restorationIdentifier {
        case "gridSwitch":
            self.gridEnabled = gridSwitch.isOn
        case "liveSwitch":
            self.liveEnabled = liveSwitch.isOn
            self.portraitEnabled = !liveSwitch.isOn
            portraitSwitch.isOn = !liveSwitch.isOn
        case "portraitSwitch":
            self.portraitEnabled = portraitSwitch.isOn
            self.liveEnabled = !portraitSwitch.isOn
            liveSwitch.isOn = !portraitSwitch.isOn
        default:
            print("switch not found")
        }
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = pickerDataSource[row]
        label.sizeToFit()
        return label
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
