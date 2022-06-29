//
//  TableCell.swift
//  Sha
//
//  Created by Kiara on 29.06.22.
//

import UIKit

class TextInputCell: UITableViewCell {
    static let identifier = "TextInputCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let sublabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .systemGray4
        label.textAlignment = .right
        return label
    }()
    
    private let inputField: UITextField = {
        let field = UITextField()
        field.keyboardType = .numberPad
        field.placeholder = "3"
        field.backgroundColor = .systemGray5
        field.textAlignment = .center
        field.layer.cornerRadius = 8
        return field
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(inputField)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size : CGFloat = contentView.frame.size.height - 12
        let width = contentView.frame.size.width - 12
        
        iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
        
        let imageSize: CGFloat = size/1.5
        iconImageView.frame = CGRect(x: (size-imageSize)/2, y: (size-imageSize)/2, width: imageSize, height: imageSize)
        
        label.frame = CGRect(x: 25+iconContainer.frame.size.width, y: 0, width: width/2, height: contentView.frame.size.height)
        inputField.frame = CGRect(x: label.frame.maxX + 20, y: 0, width: width-20-iconContainer.frame.size.width - label.frame.width - 40, height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        sublabel.text = nil
        iconContainer.backgroundColor = nil
        inputField.placeholder = "3"
    }
    
    public func configure(with model: InputOption){
        label.text =  model.title
        inputField.text =  model.subtitle != nil ? model.subtitle : ""
  
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
        
        self.selectionStyle = .none
        self.accessoryType = .none
    }
}
