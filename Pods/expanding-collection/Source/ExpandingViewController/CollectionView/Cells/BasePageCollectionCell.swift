//
//  PageConllectionCell.swift
//  TestCollectionView
//
//  Created by Alex K. on 04/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

/// Base class for UICollectionViewCell
open class BasePageCollectionCell: UICollectionViewCell {
    
    /// DEPRECATED! Animation oposition offset when cell is open
    @IBInspectable open var yOffset: CGFloat = 40
    /// Spacing between centers of views
    @IBInspectable open var ySpacing: CGFloat = CGFloat.greatestFiniteMagnitude
    /// Additional height of back view, when it grows
    @IBInspectable open var additionalHeight: CGFloat = CGFloat.greatestFiniteMagnitude
    /// Additional width of back view, when it grows
    @IBInspectable open var additionalWidth: CGFloat = CGFloat.greatestFiniteMagnitude
    /// Should front view drow shadow to bottom or not
    @IBInspectable open var dropShadow: Bool = true
    
    // MARK: Vars
    
    /// The view used as the face of the cell must connectid from xib or storyboard.
    open var frontContainerView: UIView!
    /// The view used as the back of the cell must connectid from xib or storyboard.
    open var backContainerView: UIView!
    
    /// constraints for backContainerView must connectid from xib or storyboard
    open var backConstraintY: NSLayoutConstraint!
    /// constraints for frontContainerView must connectid from xib or storyboard
    open var frontConstraintY: NSLayoutConstraint!
    
    open var shadowView: UIView?
    
    /// A Boolean value that indicates whether the cell is opened.
    open var isOpened = false
    
    public func commonInit() {
        configurationViews()
        shadowView = createShadowViewOnView(frontContainerView)
    }
    
    open func copyCell() -> BasePageCollectionCell? {
        return nil
    }

    /**
     Open or close cell.
     
     - parameter isOpen: Contains the value true if the cell should display open state, if false should display close state.
     - parameter animated: Set to true if the change in selection state is animated.
     */
    open func cellIsOpen(_ isOpen: Bool, animated: Bool = true) {
        if isOpen == isOpened { return }
        
        if ySpacing == .greatestFiniteMagnitude {
            frontConstraintY.constant = isOpen == true ? -frontContainerView.bounds.size.height / 5 : 0
            backConstraintY.constant  = isOpen == true ? frontContainerView.bounds.size.height / 5 - yOffset / 2 : 0
        } else {
            frontConstraintY.constant = isOpen == true ? -ySpacing / 2 : 0
            backConstraintY.constant  = isOpen == true ? ySpacing / 2 : 0
        }
        
        if let widthConstant = backContainerView.getConstraint(.width) {
            if additionalWidth == .greatestFiniteMagnitude {
                widthConstant.constant = isOpen == true ? frontContainerView.bounds.size.width + yOffset : frontContainerView.bounds.size.width
            } else {
                widthConstant.constant = isOpen == true ? frontContainerView.bounds.size.width + additionalWidth : frontContainerView.bounds.size.width
            }
        }
        
        if let heightConstant = backContainerView.getConstraint(.height) {
            if additionalHeight == .greatestFiniteMagnitude {
                heightConstant.constant = isOpen == true ? frontContainerView.bounds.size.height + yOffset : frontContainerView.bounds.size.height
            } else {
                heightConstant.constant = isOpen == true ? frontContainerView.bounds.size.height + additionalHeight : frontContainerView.bounds.size.height
            }
        }
        
        isOpened = isOpen
        configurationCell()
        
        if animated == true {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.contentView.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.contentView.layoutIfNeeded()
        }
        
    }
}

// MARK: Configuration

extension BasePageCollectionCell {
    
    fileprivate func configurationViews() {
        backContainerView.layer.masksToBounds = true
        backContainerView.layer.cornerRadius  = 5
        
        frontContainerView.layer.masksToBounds = true
        frontContainerView.layer.cornerRadius  = 5
        
        contentView.layer.masksToBounds = false
        layer.masksToBounds             = false
    }
    
    fileprivate func createShadowViewOnView(_ view: UIView?) -> UIView? {
        guard let view = view else {return nil}
        
        let shadow = Init(UIView(frame: .zero)) {
            $0.backgroundColor                           = UIColor(white: 0, alpha: 0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.masksToBounds                       = false;
            if dropShadow {
                $0.layer.shadowColor                         = UIColor.black.cgColor
                $0.layer.shadowRadius                        = 10
                $0.layer.shadowOpacity                       = 0.45
                $0.layer.shadowOffset                        = CGSize(width: 0, height:0)
            }
        }
        contentView.insertSubview(shadow, belowSubview: view)
        
        // create constraints
        for info: (attribute: NSLayoutAttribute, scale: CGFloat)  in [(NSLayoutAttribute.width, 0.8), (NSLayoutAttribute.height, 0.9)] {
            if let frontViewConstraint = view.getConstraint(info.attribute) {
                shadow >>>- {
                    $0.attribute = info.attribute
                    $0.constant  = frontViewConstraint.constant * info.scale
                    return
                }
            }
        }
        
        for info: (attribute: NSLayoutAttribute, offset: CGFloat)  in [(NSLayoutAttribute.centerX, 0), (NSLayoutAttribute.centerY, 30)] {
            (contentView, shadow, view) >>>- {
                $0.attribute = info.attribute
                $0.constant  = info.offset
                return
            }
        }
        
        // size shadow
        let width  = shadow.getConstraint(.width)?.constant
        let height = shadow.getConstraint(.height)?.constant
        
        shadow.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width!, height: height!), cornerRadius: 0).cgPath
        
        return shadow
    }
    
    
    func configurationCell() {
        // Prevents indefinite growing of the cell issue
        let i: CGFloat = self.isOpened ? 1 : -1
        let superHeight = superview?.frame.size.height ?? 0
        
        frame.size.height += i * superHeight
        frame.origin.y -= i * superHeight / 2
        if additionalWidth == .greatestFiniteMagnitude {
            frame.origin.x -= i * yOffset / 2
            frame.size.width += i * yOffset
        } else {
            frame.origin.x -= i * additionalWidth / 2
            frame.size.width += i * additionalWidth
        }
    }
    
    func configureCellViewConstraintsWithSize(_ size: CGSize) {
        guard isOpened == false && frontContainerView.getConstraint(.width)?.constant != size.width else { return }
        
        [frontContainerView, backContainerView].forEach {
            let constraintWidth = $0?.getConstraint(.width)
            constraintWidth?.constant = size.width
            
            let constraintHeight = $0?.getConstraint(.height)
            constraintHeight?.constant = size.height
        }
    }
}
