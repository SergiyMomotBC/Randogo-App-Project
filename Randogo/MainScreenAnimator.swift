//
//  MainScreenAnimator.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/28/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class MainScreenAnimator {
    private var initialYPositions: [CGFloat] = []
    weak var mainScreen: MainViewController?
    
    func blinkLocation() {
        guard let mainScreen = self.mainScreen else {
            return
        }

        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            mainScreen.menubar.extraRightButton?.imageView?.tintColor = UIColor.red
            mainScreen.menubar.extraRightButton?.imageView?.tag = 1
        }, completion: { success in
            mainScreen.menubar.extraRightButton?.imageView?.tintColor = UIColor.white
            mainScreen.menubar.extraRightButton?.imageView?.tag = 0
        })
    }
    
    func playLaunchAnimation(completion: (() -> Void)?) {
        guard let mainScreen = self.mainScreen else { return }
        
        mainScreen.view.isUserInteractionEnabled = false
        mainScreen.tableView.reloadData()
        
        for (index, cell) in mainScreen.tableView.visibleCells.enumerated() {
            let initialCenter = cell.center
            cell.center.x = 2 * mainScreen.tableView.frame.width
            cell.transform = CGAffineTransform(scaleX: 1.15, y: 0.95)
            
            UIViewPropertyAnimator(duration: 0.8, controlPoint1: CGPoint(x: 0.019886, y: 0.730288), controlPoint2: CGPoint(x: 0.354003, y: 1.0), animations: {
                cell.center = initialCenter
            }).startAnimation(afterDelay: 0.3 + 0.1 * Double(index))
            
            UIViewPropertyAnimator(duration: 0.8, controlPoint1: CGPoint(x: 0.333333, y: 0.0), controlPoint2: CGPoint(x: 0.666666, y: 1.0), animations: {
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }).startAnimation(afterDelay: 0.3 + 0.1 * Double(index))
        }
        
        mainScreen.tableView.tableHeaderView?.subviews.first?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.7, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            mainScreen.tableView.tableHeaderView?.subviews.first?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            mainScreen.view.isUserInteractionEnabled = true
            completion?()
        }
    }
    
    func playOutAnimation(completion: (() -> Void)?) {
        guard initialYPositions.isEmpty, let mainScreen = self.mainScreen else { return }
        
        mainScreen.view.isUserInteractionEnabled = false
        mainScreen.tableView.tableHeaderView?.alpha = 0.0
        
        for (index, cell) in mainScreen.tableView.visibleCells.enumerated() {
            cell.tag = index
            initialYPositions.append(cell.center.y)
            
            UIViewPropertyAnimator(duration: 0.85, controlPoint1: CGPoint(x: 0.57893, y: 0.23139), controlPoint2: CGPoint(x: 0.1112, y: 1.1703)) {
                cell.center.y = -mainScreen.tableView.frame.width * 0.75
            }.startAnimation(afterDelay: Double(index) * 0.05)
            
            UIViewPropertyAnimator(duration: 0.5, controlPoint1: CGPoint(x: 0.16, y: 0.0), controlPoint2: CGPoint(x: 0.84, y: 1.0)) {
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.15)
            }.startAnimation(afterDelay: Double(index) * 0.05)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            mainScreen.view.isUserInteractionEnabled = true
            completion?()
        }
    }
    
    func playInAnimation(completion: (() -> Void)?) {
        guard !initialYPositions.isEmpty, let mainScreen = self.mainScreen else { return }
        
        mainScreen.view.isUserInteractionEnabled = false
        
        for (index, cell) in mainScreen.tableView.visibleCells.reversed().enumerated() {
            UIViewPropertyAnimator(duration: 0.85, controlPoint1: CGPoint(x: 0.57893, y: 0.23139), controlPoint2: CGPoint(x: 0.1112, y: 1.1703)) {
                cell.center.y = self.initialYPositions[cell.tag]
            }.startAnimation(afterDelay: Double(index) * 0.05)
            
            UIViewPropertyAnimator(duration: 0.55, controlPoint1: CGPoint(x: 0.16, y: 0.0), controlPoint2: CGPoint(x: 0.84, y: 1.0)) {
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }.startAnimation(afterDelay: 0.3 + Double(index) * 0.05)
        }
        
        initialYPositions.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            mainScreen.view.isUserInteractionEnabled = true
            mainScreen.tableView.tableHeaderView?.alpha = 1.0
            completion?()
        }
    }
}
