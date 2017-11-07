//
//  FirstTimeHints.swift
//  Randogo
//
//  Created by Sergiy Momot on 8/3/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import EasyTipView
import PopupDialog

class FirstTimeHints: EasyTipViewDelegate {
    private static let mainScreenKey = "mainScreenKey"
    private static let presenterScreenKey = "presenterScreenKey"
    private static let placeDetailsScreenKey = "placeDetailsScreenKey"
    
    static let shared = FirstTimeHints()
    
    private var shouldShowMainScreenHint: Bool
    private var shouldShowPresenterScreenHint: Bool
    private var shouldShowPlaceDetailsScreenHint: Bool
    private var nextTooltipIndex = 0
    private var tooltipSequence: [(view: UIView, text: String)] = []
    
    private var previousOrigin: CGPoint?
    private var previousParent: UIView?
    private var currentHighlightedView: UIView?
    private weak var menubar: MenuBar?
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()
    
    private init() {
        shouldShowMainScreenHint = UserDefaults.standard.object(forKey: FirstTimeHints.mainScreenKey) == nil
        shouldShowPresenterScreenHint = UserDefaults.standard.object(forKey: FirstTimeHints.presenterScreenKey) == nil
        shouldShowPlaceDetailsScreenHint = UserDefaults.standard.object(forKey: FirstTimeHints.placeDetailsScreenKey) == nil
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "AvenirNext-Regular", size: 14.0)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor.flatDarkTeal
        preferences.drawing.arrowHeight = 10.0
        preferences.drawing.arrowWidth = 15.0
        preferences.positioning.bubbleHInset = 16.0
        preferences.positioning.bubbleVInset = 5.0
        preferences.animating.showDuration = 0.5
        preferences.animating.dismissDuration = 0.4
        EasyTipView.globalPreferences = preferences
    }
    
    private func highlight(view: UIView) {
        previousOrigin = view.frame.origin
        previousParent = view.superview
        view.frame = CGRect(origin: view.superview!.convert(view.frame.origin, to: nil), size: view.frame.size)
        UIApplication.shared.keyWindow!.addSubview(view)
        view.isUserInteractionEnabled = false
        currentHighlightedView = view
    }
    
    func handleMainScreenHint(for vc: MainViewController) {
        if shouldShowMainScreenHint {
            let welcomeDialog = PopupDialog(title: "Welcome", message: "Thank you for downloading my app. You will be shown quick tooltips which will help you understand how to use the app. Tap on the tooltip box to dismiss it.", transitionStyle: .zoomIn, gestureDismissal: false)
            
            welcomeDialog.addButton(DefaultButton(title: "Got it!", height: 60, dismissOnTap: true, action: { 
                self.tooltipSequence = [(view: vc.tableView.visibleCells.first!, text: "Tap on one of four major categories cells to reveal the list of all available subcategories. Up to 5 subcategories can be selected."),
                                        (view: vc.menubar.extraLeftButton!, text: "Tap on the Categories Search button to manually search for the desired category."),
                                        (view: vc.menubar.extraRightButton!, text: "Tap on the Location button when you want to enter a different location than your own or if you have disabled location services for this app. You will also need to enter your location if the device could not retrieve your location automatically."),
                                        (view: vc.menubar.centerButton!, text: "Tap on the Plus button to show your favorite places and the history of all places that you have viewed using this application.")]
                
                vc.menubar.allowLayoutUpdate = false
                self.menubar = vc.menubar
                self.startTooltipSequence(vc: vc)
                
                self.shouldShowMainScreenHint = false
                UserDefaults.standard.set(true, forKey: FirstTimeHints.mainScreenKey)
            }))
            
            vc.present(welcomeDialog, animated: true, completion: nil)
        }
    }
    
    func handlePresenterScreenHint(for vc: PresenterViewController) {
        if shouldShowPresenterScreenHint {
            tooltipSequence = [(view: vc.collectionView!.visibleCells.first!, text: "Slide the cell up to reveal place's rating and closing time. Slide up again to view full details about the place. Slide down to collapse the cell."),
                               (view: vc.foldingBar.extraRightButton!, text: "Hold the Map View button to see place's location on the map."),
                               (view: vc.foldingBar.centerButton!, text: "Tap on the Filter button to reveal filter options which allow you to change search radius and price categories."),
                               (view: vc.anchor, text: "If you are not happy with the selected place, then shake your device to view another random choice."),
                               (view: vc.foldingBar.extraLeftButton!, text: "Tap on the Back button to return to the previous screen.")]
            
            vc.foldingBar.allowLayoutUpdate = false
            self.menubar = vc.foldingBar
            startTooltipSequence(vc: vc)
            
            shouldShowPresenterScreenHint = false
            UserDefaults.standard.set(true, forKey: FirstTimeHints.presenterScreenKey)
        }
    }
    
    func handlePlaceDetailsScreenHint(for vc: PlaceDetailsViewController) {
        if shouldShowPlaceDetailsScreenHint {
            tooltipSequence = [(view: vc.menubar.centerButton!, text: "Tap on the Plus button to reveal additional options regarding this place which include calling the business, opening place's Yelp webpage, getting map directions and displaying sharing actions."),
                               (view: vc.menubar.extraRightButton!, text: "Tap on the Star button to add this place to the Favorites list. Tap it again to remove place from the list."),
                               (view: vc.anchor, text: "Tap on the picture to view it fullscreen.")]
            
            vc.menubar.allowLayoutUpdate = false
            self.menubar = vc.menubar
            startTooltipSequence(vc: vc)
            
            shouldShowPlaceDetailsScreenHint = false
            UserDefaults.standard.set(true, forKey: FirstTimeHints.placeDetailsScreenKey)
        }
    }
    
    private func showTooltip() {
        let view = self.tooltipSequence[nextTooltipIndex].view
        let text = self.tooltipSequence[nextTooltipIndex].text
        
        highlight(view: view)
        EasyTipView.show(forView: view, text: text, delegate: self)
    }
    
    private func startTooltipSequence(vc: UIViewController) {
        vc.view.addSubview(overlayView)
        overlayView.clipToSuperview()
        UIView.animate(withDuration: 0.3, animations: { 
            self.overlayView.alpha = 0.6
        }, completion: { success in
            self.showTooltip()
        })
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        nextTooltipIndex += 1
        
        if let view = self.currentHighlightedView {
            view.frame = CGRect(origin: self.previousOrigin!, size: view.frame.size)
            self.previousParent!.addSubview(view)
            view.isUserInteractionEnabled = true
        }
        
        if nextTooltipIndex == tooltipSequence.count {
            self.previousParent = nil
            self.currentHighlightedView = nil
            self.previousOrigin = nil
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.overlayView.alpha = 0.0
            }, completion: { success in
                self.overlayView.removeFromSuperview()
                self.menubar?.allowLayoutUpdate = true
                self.menubar = nil
            })
            
            nextTooltipIndex = 0
            tooltipSequence.removeAll()
            
        } else {
            showTooltip()
        }
    }
}
