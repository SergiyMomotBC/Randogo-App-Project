//
//  TableViewController.swift
//  TestCollectionView
//
//  Created by Alex K. on 06/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

/// Base class for UITableViewcontroller which have back transition method
open class ExpandingTableViewController: UIViewController {
    open var headerHeight: CGFloat = 50
    var transitionDriver: TransitionDriver?
    open var headerView: UIView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        self.view.addSubview(headerView)
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: self.headerHeight).isActive = true
    }
}

// MARK: Helpers 

extension ExpandingTableViewController {
  
  fileprivate func getScreen() -> UIImage? {
    let height = headerHeight
    let backImageSize = CGSize(width: view.bounds.width, height: view.bounds.height - height)
    let backImageOrigin = CGPoint(x: 0, y: height)
    return view.takeSnapshot(CGRect(origin: backImageOrigin, size: backImageSize))
  }
}

// MARK: Methods

extension ExpandingTableViewController {
  
  /**
   Pops the top view controller from the navigation stack and updates the display with custom animation.
   */
  public func popTransitionAnimation() {
    guard let transitionDriver = self.transitionDriver else {
      return
    }

    transitionDriver.popTransitionAnimationContantOffset(headerHeight, backImage: getScreen())
    self.dismiss(animated: false)
  }
}
