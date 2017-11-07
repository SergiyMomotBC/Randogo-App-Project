//
//  LocationSearchBar.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class LocationSearchBar: SearchBar {
    override var emptyStateText: String {
        return "Choose your location from the suggestions shown here."
    }
    
    override init(frame: CGRect, icon: UIImage?, suggestionsProvider: SuggestionsProvider) {
        super.init(frame: frame, icon: icon, suggestionsProvider: suggestionsProvider)
        placeholderText = "Start entering your location..."
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func expand(to center: CGPoint, andWidth width: CGFloat) {
        isActivated = true
        originalCenter = self.center
        let xDestination = superview!.frame.width - self.frame.origin.x - self.frame.width
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center = center
        }, completion: { success in
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
                self.frame = CGRect(x: xDestination, y: self.frame.origin.y, width: width, height: self.frame.height)
            }, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.placeholder = self.placeholderText
                self.becomeFirstResponder()
            })
        })
    }
    
    override func collapse(completion: (() -> Void)?) {
        self.placeholder = nil
        self.text = nil
        self.resignFirstResponder()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: self.originalCenter.x - self.frame.height / 2, y: self.frame.origin.y, width: self.frame.height, height: self.frame.height)
        }, completion: { success in
            UIView.animate(withDuration: 0.3, animations: {
                self.center = self.originalCenter
            }, completion: { success in
                self.isActivated = false
                completion?()
            })
        })
    }
}
