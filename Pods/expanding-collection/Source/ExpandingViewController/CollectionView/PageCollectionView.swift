//
//  PageCollectionView.swift
//  TestCollectionView
//
//  Created by Alex K. on 05/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

class PageCollectionView: UICollectionView {
  class func createOnView(_ view: UIView,
                          layout: UICollectionViewLayout,
                          height: CGFloat,
                          dataSource: UICollectionViewDataSource,
                          delegate: UICollectionViewDelegate) -> PageCollectionView {
    
    let collectionView = Init(PageCollectionView(frame: CGRect.zero, collectionViewLayout: layout)) {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.decelerationRate                          = UIScrollViewDecelerationRateFast
      $0.showsHorizontalScrollIndicator            = false
      $0.dataSource                                = dataSource
      $0.delegate                                  = delegate
      $0.backgroundColor                           = UIColor(white: 0, alpha: 0)
    }
    view.addSubview(collectionView)
    
//    collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
//    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//    collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0.0).isActive = true
    
    return collectionView
  }
  
}
