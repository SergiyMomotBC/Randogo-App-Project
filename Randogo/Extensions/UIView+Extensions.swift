//
//  UIView+Extensions.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/27/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

extension UIView {
    func applyShadow(ofRadius radius: CGFloat, andOpacity opacity: CGFloat) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = radius
    }
    
    func clipToSuperview(withMargin margin: CGFloat = 0.0) {
        if let superview = self.superview {
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: margin).isActive = true
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margin).isActive = true
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -margin).isActive = true
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margin).isActive = true
        }
    }
    
    func centerInSuperview() {
        if let superview = self.superview {
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        }
    }
}
