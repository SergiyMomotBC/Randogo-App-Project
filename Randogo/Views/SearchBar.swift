//
//  SearchBar.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/19/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

protocol SuggestionsProvider: class {
    func getSuggestions(for text: String, completion: @escaping (([String]) -> Void))
}

protocol SearchbarDelegate: class {
    func searchbar(_ searchbar: SearchBar, didSelect selection: String?)
}

class SearchBar: UITextField, SuggestionsDelegate
{
    private static let suggestionsViewMargin: CGFloat = 20.0
    var originalCenter: CGPoint!
    private var suggestionsView: SearchSuggestionsTableView!
    let suggestionsProvider: SuggestionsProvider
    private var leftIcon: UIImage?
    var isActivated = false
    
    var placeholderText: String = "Start entering category..."
    
    weak var searchbarDelegete: SearchbarDelegate?
    
    var emptyStateText: String {
        return "Choose a category from the suggestions shown here."
    }
    
    var noSuggestionsText: String {
        return "No search results..."
    }
    
    init(frame: CGRect, icon: UIImage?, suggestionsProvider: SuggestionsProvider) {
        self.leftIcon = icon
        self.suggestionsProvider = suggestionsProvider
        super.init(frame: frame)
        self.sideViewsPadding = frame.height * 0.3
        initialization()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didSelectSuggestion(_ suggestion: String) {
        self.suggestionsView.removeFromSuperview()
        self.suggestionsView = nil
        self.placeholderText = "Current: " + suggestion
        searchbarDelegete?.searchbar(self, didSelect: suggestion)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard isActivated, self.suggestionsView == nil else { return }
        
        if let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            let height = frame.origin.y - (self.frame.origin.y + self.frame.height) - 2 * SearchBar.suggestionsViewMargin
            self.suggestionsView = SearchSuggestionsTableView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.height + SearchBar.suggestionsViewMargin, width: self.frame.width, height: height))
            self.suggestionsView.layer.cornerRadius = self.layer.cornerRadius
            self.suggestionsView.suggestionDelegate = self
            self.suggestionsView.emptyStateText = self.emptyStateText
            self.suggestionsView.noSuggestionsStateText = self.noSuggestionsText
            self.superview!.addSubview(suggestionsView)
        }
    }
    
    private func initialization() {
        isHidden = true
        backgroundColor = UIColor.flatLightTeal
        layer.cornerRadius = bounds.height / 2.0
        textColor = .white
        font = UIFont(name: "AvenirNext-Demibold", size: 18.0)
        autocorrectionType = .no
        keyboardAppearance = .dark
        applyShadow(ofRadius: 8.0, andOpacity: 0.45)
        
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
    
    @objc private func textChanged() {
        if self.text!.isEmpty {
            self.suggestionsView.update(withSuggestions: [])
        } else {
            suggestionsProvider.getSuggestions(for: self.text!) { results in
                self.suggestionsView.update(withSuggestions: results)
            }
        }
    }
    
    func expand(to center: CGPoint, andWidth width: CGFloat) {
        isActivated = true
        originalCenter = self.center
        
        UIView.animate(withDuration: 0.3, animations: {
            self.center = center
        }, completion: { success in
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.height)
            }, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.placeholder = self.placeholderText
                self.becomeFirstResponder()
            })
        })
    }
    
    @objc private func closeAction() {
        self.suggestionsView.removeFromSuperview()
        self.suggestionsView = nil
        searchbarDelegete?.searchbar(self, didSelect: nil)
    }
    
    func collapse(completion: (() -> Void)?) {
        self.placeholder = nil
        self.text = nil
        self.resignFirstResponder()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.height, height: self.frame.height)
        }, completion: { success in
            UIView.animate(withDuration: 0.3, animations: {
                self.center = self.originalCenter
            }, completion: { success in
                self.isActivated = false
                completion?()
            })
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sideViewsPadding = frame.height * 0.3
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
        return CGRect(x: frame.height - 2.0, y: bounds.origin.y, width: bounds.width - frame.height - 2 * sideViewsPadding - 2.0, height: bounds.height)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

