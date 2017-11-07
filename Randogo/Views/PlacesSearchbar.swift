//
//  PlacesSearchbar.swift
//  Randogo
//
//  Created by Sergiy Momot on 8/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

protocol PlacesSearchbarDelegate: class {
    func placesSearchbar(_ searchbar: PlacesSearchbar, didChangeTextTo text: String?)
}

class PlacesSearchbar: UITextField
{
    private var sideViewsPadding: CGFloat = 8.0
    private var leftIcon: UIImage?
    
    weak var searchbarDelegete: PlacesSearchbarDelegate?
    
    init(icon: UIImage?) {
        self.leftIcon = icon
        super.init(frame: .zero)
        initialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialization() {
        backgroundColor = UIColor.flatLightTeal
        textColor = .white
        font = UIFont(name: "AvenirNext-Demibold", size: 18.0)
        autocorrectionType = .no
        keyboardAppearance = .dark
        
        self.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        let image = UIImageView(image: self.leftIcon?.withRenderingMode(.alwaysTemplate))
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        
        leftViewMode = .always
        leftView = image
        
        let button = UIButton()
        button.setImage(UIImage(named: "close_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        rightViewMode = .whileEditing
        rightView = button
    }
    
    @objc private func closeAction() {
        self.searchbarDelegete?.placesSearchbar(self, didChangeTextTo: nil)
    }
    
    @objc private func textChanged() {
        self.searchbarDelegete?.placesSearchbar(self, didChangeTextTo: self.text)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
        sideViewsPadding = frame.height * 0.25
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let size = frame.height - 2.0 * sideViewsPadding
        return CGRect(x: frame.width - size - sideViewsPadding, y: sideViewsPadding, width: size, height: size)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let size = frame.height - 2.0 * sideViewsPadding
        return CGRect(x: sideViewsPadding, y: sideViewsPadding, width: size, height: size)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: frame.height, y: bounds.origin.y, width: bounds.width - frame.height + 6.0 - sideViewsPadding, height: bounds.height)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return self.editingRect(forBounds: bounds)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.editingRect(forBounds: bounds)
    }
}
