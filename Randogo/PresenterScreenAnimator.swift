//
//  PresenterScreenAnimator.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/7/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class PresenterScreenAnimator {
    weak var presenterScreen: PresenterViewController?
    
    func shakeAnimation() {
        guard let presenterScreen = self.presenterScreen else {
            return
        }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.4
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        
        presenterScreen.collectionView?.visibleCells.first?.layer.add(animation, forKey: "shake")
        presenterScreen.infoLabel.layer.add(animation, forKey: "shake")
    }
    
    func playPlaceUpdateAnimation(updateAction: (() -> Void)?) {
        guard let presenterScreen = self.presenterScreen else {
            return
        }
        
        presenterScreen.allowShaking = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            presenterScreen.collectionView?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }) { success in
            updateAction?()
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                presenterScreen.collectionView?.transform = CGAffineTransform.identity
            }, completion: { success in
                presenterScreen.allowShaking = true
            })
        }
    }
    
    func playInAnimation(completion: (() -> Void)?) {
        guard let presenterScreen = self.presenterScreen else {
            return
        }
        
        presenterScreen.foldingBar.isHidden = false
        presenterScreen.foldingBar.playShowAnimation(withDelay: 0.0)
        presenterScreen.collectionView!.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            presenterScreen.collectionView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { success in
            completion?()
        })
    }
    
    func playOutAnimation() {
        guard let presenterScreen = self.presenterScreen else {
            return
        }
        
        presenterScreen.foldingBar.playHideAnimation()
        
        UIView.animate(withDuration: 0.55) {
            presenterScreen.collectionView!.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            presenterScreen.infoLabel.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.35) {
            presenterScreen.overlayView.alpha = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            presenterScreen.dismiss(animated: false) {
                presenterScreen.main?.menubar.playShowAnimation(withDelay: 0.0)
                presenterScreen.main?.animator.playInAnimation(completion: nil)
                presenterScreen.main?.requestData.categories = nil
            }
        }
    }
    
    func playRevealMapAnimation() {
        guard let presenterScreen = self.presenterScreen else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            presenterScreen.overlayView.alpha = 0.7
            presenterScreen.collectionView?.alpha = 1.0
            presenterScreen.infoLabel.alpha = 1.0
        }
    }
    
    func playHideMapAnimation() {
        guard let presenterScreen = self.presenterScreen else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            presenterScreen.overlayView.alpha = 0.0
            presenterScreen.collectionView?.alpha = 0.0
            presenterScreen.infoLabel.alpha = 0.0
        }
    }
}
