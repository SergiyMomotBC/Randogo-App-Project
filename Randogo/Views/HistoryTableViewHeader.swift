//
//  HistoryTableViewHeader.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/31/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class HistoryTableViewHeader: UITableViewHeaderFooterView {
    let clearButton = UIButton()
    let dayLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.flatPurple
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.white
        contentView.addSubview(line)
        line.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.numberOfLines = 1
        dayLabel.font = UIFont(name: "AvenirNext-Demibold", size: 24.0)
        dayLabel.textColor = UIColor.white
        dayLabel.adjustsFontSizeToFitWidth = true
        dayLabel.minimumScaleFactor = 0.5
        contentView.addSubview(dayLabel)
        dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0).isActive = true
        dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0).isActive = true
        dayLabel.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -2.0).isActive = true
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(UIColor(red: 211.0/255, green: 84.0/255, blue: 0.0/255, alpha: 1.0), for: .normal)
        clearButton.setTitleColor(.lightGray, for: .highlighted)
        contentView.addSubview(clearButton)
        clearButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0).isActive = true
        clearButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0).isActive = true
        clearButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
