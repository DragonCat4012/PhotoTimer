//
//  SettingsView.swift
//  Sha
//
//  Created by Akora on 28.06.22.
//

import UIKit
import simd

class SettingsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(StaticCell.self, forCellReuseIdentifier: StaticCell.identifier)
        return table
    }()
    

    var models = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        // Add tableView footer
              let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
              let headerView = UIView(frame: CGRect(x: 0, y: 0,  width: self.tableView.frame.width, height: 17))
         
              let versionLabel = UILabel()
              versionLabel.frame = headerView.frame
              versionLabel.text = "Version: \(appVersion)"
              versionLabel.textColor = .systemGray3
              versionLabel.adjustsFontSizeToFitWidth = true
              versionLabel.textAlignment = .center

              headerView.addSubview(versionLabel)
              self.tableView.tableFooterView = headerView
    }
    
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          update()
      }
    
    func update() {
          self.models = []
          self.configure()
          self.tableView.reloadData()
      }

    //MARK: Table Setup
       func numberOfSections(in tableView: UITableView) -> Int {
           return models.count
       }
       
       func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           let section = models[section]
           return section.title
       }
       
       func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
       { return models[section].options.count}
       
       func tableView(_ tableView: UITableView, cellForRowAt indexpath: IndexPath) -> UITableViewCell{
           let model = models[indexpath.section].options[indexpath.row]
           
           switch model.self{
           case .staticCell(let model):
               guard let cell = tableView.dequeueReusableCell(withIdentifier: StaticCell.identifier, for: indexpath) as? StaticCell else {
                   return UITableViewCell()
               }
               cell.configure(with: model)
               return cell
           }
       }
       
       
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           let type = models[indexPath.section].options[indexPath.row]
           
           switch type.self{
           case .staticCell(let model):
               model.selectHandler()
           }
       }
       
       func navigateSubjectSettings(){
         print("hi")
       }
       
       func navigateAddSubject(){
           print("aaa")
       }
       
       func configure(){
           var arr: [SettingsOptionType] = []


           arr.append(
               .staticCell(
                   model:
                       StaticOption(
                           title: "Github",
                           subtitle: "",
                           icon: UIImage(systemName: "info.circle.fill"),
                           iconBackgroundColor: .systemBlue
                       ){
                           let url = URL(string: "https://github.com/AKORA-Studios/Calq-iOS")
                           UIApplication.shared.open(url!)
                       })
           )
        
           models.append(Section(title: "Settings", options: [
            
            .staticCell(model:StaticOption(title: "Timer", subtitle: "", icon: UIImage(systemName: "clock.fill"), iconBackgroundColor: .systemPink)
                           {
                           
                           }),
            .staticCell(model:StaticOption(title: "Count", subtitle: "", icon: UIImage(systemName: "chart.bar.fill"), iconBackgroundColor: .systemTeal)
                           {
                            
                           }),
            .staticCell(model:StaticOption(title: "Change Camera", subtitle: "", icon: UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill"), iconBackgroundColor: .systemPurple)
                           {
                            
                           })

                 
           ] ))
           
           models.append(Section(title: "", options: arr))
       }
}
