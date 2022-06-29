//
//  TableStruct.swift
//  Sha
//
//  Created by Kiara on 29.06.22.
//

import Foundation
import UIKit

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType{
    case staticCell(model: StaticOption)
}

struct StaticOption{
    let title: String
    let subtitle: String?
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let selectHandler: (()-> Void)
}
