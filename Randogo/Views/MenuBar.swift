//
//  MenuBar.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/26/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import FoldingTabBar

@objc protocol MenuBarResponder: class {
    @objc optional func menuBar(_ menuBar: MenuBar, didTapItemAt index: Int)
    @objc optional func menuBarDidTapLeftButton(_ menuBar: MenuBar)
    @objc optional func menuBarDidTapRightButton(_ menuBar: MenuBar)
    @objc optional func menuBarDidTouchDownRightButton(_ menuBar: MenuBar)
}

class MenuBar: YALFoldingTabBar {
    var allowLayoutUpdate = true
    
    var leftBarItems: [YALTabBarItem] = []
    var rightBarItems: [YALTabBarItem] = []
    var selectedIndex: Int? = nil
    weak var menuResponder: MenuBarResponder?
    var singleModeAction: (() -> Void)? = nil
    var centerButtonImage: UIImage!
    private var allowCenterButtonAnimation = false
    
    var searchButtonOffset: CGFloat {
        return YALForExtraTabBarItemsDefaultOffset
    }
    
    private override init() {
        super.init()
        setupView()
    }
    
    static func createFor(_ viewController: UIViewController) -> MenuBar {
        let bar = MenuBar()
        
        if viewController is MainViewController {
            let item1 = YALTabBarItem(itemImage: UIImage(named: "history_icon")!.withRenderingMode(.alwaysTemplate), leftItemImage: UIImage(named: "search_icon")!.withRenderingMode(.alwaysTemplate), rightItemImage: UIImage(named: "location_icon")?.withRenderingMode(.alwaysTemplate))
            let item2 = YALTabBarItem(itemImage: UIImage(named: "favorite_on_icon")!.withRenderingMode(.alwaysTemplate), leftItemImage: UIImage(named: "search_icon")!.withRenderingMode(.alwaysTemplate), rightItemImage: UIImage(named: "location_icon")?.withRenderingMode(.alwaysTemplate))
   
            bar.leftBarItems = [item1]
            bar.rightBarItems = [item2]
            bar.centerButtonImage = UIImage(named: "plus_icon")
            bar.allowCenterButtonAnimation = true
        } else if viewController is PresenterViewController {
            let dummyItem = YALTabBarItem(itemImage: nil, leftItemImage: UIImage(named: "back_icon")?.withRenderingMode(.alwaysTemplate), rightItemImage: UIImage(named: "view_icon")?.withRenderingMode(.alwaysTemplate))
            
            bar.leftBarItems = [dummyItem]
            bar.centerButtonImage = UIImage(named: "filter_icon")
        } else if viewController is PlaceDetailsViewController {
            let item1 = YALTabBarItem(itemImage: UIImage(named: "call_icon")!.withRenderingMode(.alwaysTemplate),
                                      leftItemImage: UIImage(named: "back_icon")!.withRenderingMode(.alwaysTemplate),
                                      rightItemImage: UIImage(named: "favorite_off_icon")!.withRenderingMode(.alwaysTemplate))
            
            let item2 = YALTabBarItem(itemImage: UIImage(named: "yelp_icon")!.withRenderingMode(.alwaysTemplate),
                                      leftItemImage: UIImage(named: "back_icon")!.withRenderingMode(.alwaysTemplate),
                                      rightItemImage: UIImage(named: "favorite_off_icon")!.withRenderingMode(.alwaysTemplate))
            
            let item3 = YALTabBarItem(itemImage: UIImage(named: "directions_icon")!.withRenderingMode(.alwaysTemplate),
                                      leftItemImage: UIImage(named: "back_icon")!.withRenderingMode(.alwaysTemplate),
                                      rightItemImage: UIImage(named: "favorite_off_icon")!.withRenderingMode(.alwaysTemplate))
            
            let item4 = YALTabBarItem(itemImage: UIImage(named: "share_icon")!.withRenderingMode(.alwaysTemplate),
                                      leftItemImage: UIImage(named: "back_icon")!.withRenderingMode(.alwaysTemplate),
                                      rightItemImage: UIImage(named: "favorite_off_icon")!.withRenderingMode(.alwaysTemplate))
            
            bar.leftBarItems = [item1, item2]
            bar.rightBarItems = [item3, item4]
            bar.centerButtonImage = UIImage(named: "plus_icon")
            bar.allowCenterButtonAnimation = true
        }
        
        bar.delegate = bar
        bar.dataSource = bar
        
        viewController.view.addSubview(bar)
        bar.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
        bar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.135).isActive = true
        
        bar.menuResponder = viewController as? MenuBarResponder
        
        return bar
    }
    
    override func layoutSubviews() {
        if allowLayoutUpdate {
            super.layoutSubviews()
        }
    }
    
    override func animateCenterButtonExpand() {
        if allowCenterButtonAnimation {
            super.animateCenterButtonExpand()
        }
    }
    
    override func animateCenterButtonCollapse() {
        if allowCenterButtonAnimation {
            super.animateCenterButtonCollapse()
        }
    }
    
    func switchToSingleMode(withImage image: UIImage, andAction action: @escaping () -> Void) {
        self.centerButton?.isEnabled = false
        
        if state == .expanded {
            state = .collapsed
        }
        
        singleModeAction = action
        
        UIView.animate(withDuration: 0.25, animations: {
            self.centerButton?.imageView?.alpha = 0.0
        }) { success in
            self.centerButton?.setImage(image, for: .normal)
            UIView.animate(withDuration: 0.25, animations: {
                self.centerButton?.imageView?.alpha = 1.0
            }, completion: { success in
                self.centerButton?.isEnabled = true
            })
        }
    }
    
    func switchToNormalMode() {
        self.centerButton?.isEnabled = false
        
        singleModeAction = nil
        
        UIView.animate(withDuration: 0.25, animations: {
            self.centerButton?.imageView?.alpha = 0.0
        }) { success in
            self.centerButton?.setImage(self.dataSource?.centerImage(inTabBarView: self), for: .normal)
            UIView.animate(withDuration: 0.25, animations: {
                self.centerButton?.imageView?.alpha = 1.0
            }, completion: { success in
                self.centerButton?.isEnabled = true
            })
        }
    }
    
    func playShowAnimation(withDelay delay: Double) {
        transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    func playHideAnimation() {
        UIView.animate(withDuration: 0.55) {
            self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }
    }
    
    override func centerButtonPressed() {
        if let action = singleModeAction {
            action()
        } else {
            super.centerButtonPressed()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight
        offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset
        tabBarColor = UIColor.flatLightTeal
        tintColor = .white
        tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets
        tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets
        dotColor = .clear
        applyShadow(ofRadius: 8.0, andOpacity: 0.4)
    }
}

extension MenuBar: YALTabBarDataSource, YALTabBarDelegate
{
    func leftTabBarItems(inTabBarView tabBarView: YALFoldingTabBar) -> [Any] {
        return leftBarItems
    }
    
    func rightTabBarItems(inTabBarView tabBarView: YALFoldingTabBar) -> [Any] {
        return rightBarItems
    }
    
    func centerImage(inTabBarView tabBarView: YALFoldingTabBar) -> UIImage {
        return centerButtonImage.withRenderingMode(.alwaysTemplate)
    }
    
    func tabBar(_ tabBar: YALFoldingTabBar, didSelectItemAt index: UInt) {
        selectedIndex = Int(index)
    }
    
    func tabBarDidSelectExtraLeftItem(_ tabBar: YALFoldingTabBar) {
        menuResponder?.menuBarDidTapLeftButton?(self)
    }
    
    func tabBarDidSelectExtraRightItem(_ tabBar: YALFoldingTabBar) {
        menuResponder?.menuBarDidTapRightButton?(self)
    }
    
    func tabBarDidTouchDownExtraRightItem(_ tabBar: YALFoldingTabBar) {
        menuResponder?.menuBarDidTouchDownRightButton?(self)
    }
    
    func tabBarWillCollapse(_ tabBar: YALFoldingTabBar) {
        if selectedIndex != nil {
            menuResponder?.menuBar?(self, didTapItemAt: selectedIndex!)
            selectedIndex = nil
        }
    }
    
    func tabBar(_ tabBar: YALFoldingTabBar, shouldSelectItemAt index: UInt) -> Bool {
        return true
    }
}

