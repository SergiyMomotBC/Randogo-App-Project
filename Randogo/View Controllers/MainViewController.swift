//
//  MainViewController.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import CoreLocation
import PopupDialog

class MainViewController: UIViewController
{
    var tableView: CategoriesTableView!
    var menubar: MenuBar!
    var categorySearchbar: SearchBar!
    var locationSearchbar: SearchBar!
    var animator: MainScreenAnimator!
    var locationResolver: LocationResolver!
    var requestData = RequestData()
    var searchBarPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.flatPurple
        
        menubar = MenuBar.createFor(self)
        menubar.playShowAnimation(withDelay: 1.0)
        
        tableView = CategoriesTableView(frame: CGRect.zero, andMenuBar: menubar)
        tableView.categoriesSelectionDelegate = self
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 20.0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: menubar.topAnchor, constant: -8.0).isActive = true
        
        view.layoutIfNeeded()
        
        categorySearchbar = SearchBar(frame: CGRect(x: menubar.searchButtonOffset, y: menubar.frame.origin.y + menubar.searchButtonOffset, width: menubar.extraTabBarItemHeight, height: menubar.extraTabBarItemHeight),
                                      icon: UIImage(named: "search_icon"),
                                      suggestionsProvider: CategoryAutocompleteProvider())
        categorySearchbar.searchbarDelegete = self
        view.addSubview(categorySearchbar)
        
        locationSearchbar = LocationSearchBar(frame: CGRect(x: menubar.frame.width - menubar.searchButtonOffset - menubar.extraTabBarItemHeight, y: menubar.frame.origin.y + menubar.searchButtonOffset, width: menubar.extraTabBarItemHeight, height: menubar.extraTabBarItemHeight),
                                              icon: UIImage(named: "location_icon"),
                                              suggestionsProvider: AddressAutocompletionProvider())
        locationSearchbar.searchbarDelegete = self
        view.addSubview(locationSearchbar)
        
        view.layoutIfNeeded()
        
        animator = MainScreenAnimator()
        animator.mainScreen = self
        animator.playLaunchAnimation(completion: {
            FirstTimeHints.shared.handleMainScreenHint(for: self)
        })
        
        locationResolver = LocationResolver()
        
        requestLocation()
    }
    
    @objc fileprivate func requestLocation() {
        self.menubar.changeExtraRightTabBarItem(with: UIImage(named: "location_icon")!.withRenderingMode(.alwaysTemplate))
        self.menubar.extraRightButton?.isEnabled = false
        
        self.menubar.extraRightButton?.imageView?.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
            self.menubar.extraRightButton?.imageView?.alpha = 0.0
        }, completion: nil)
        
        locationResolver.retrieveLocation { location in
            if let location = location {
                self.requestData.location = location.coordinate
                self.requestData.isLocationFromGPS = true
                self.menubar.changeExtraRightTabBarItem(with: UIImage(named: "location_on_icon")!.withRenderingMode(.alwaysTemplate))
                self.checkRequestData()
            } else {
                self.menubar.changeExtraRightTabBarItem(with: UIImage(named: "location_off_icon")!.withRenderingMode(.alwaysTemplate))
            }
            
            self.menubar.extraRightButton?.isEnabled = true
        }
    }
    
    fileprivate func presentSearchbar(_ searchbar: SearchBar) {
        guard !self.searchBarPresented else {
            return
        }
        
        searchBarPresented = true
        menubar.isHidden = true
        searchbar.isHidden = false
        searchbar.expand(to: CGPoint(x: searchbar.center.x, y: 60.0), andWidth: view.frame.width - 2 * self.categorySearchbar.frame.origin.x)
        UIView.animate(withDuration: 0.25) {
            self.tableView.alpha = 0.0
        }
    }
}

extension MainViewController: SearchbarDelegate, CategorySelectionDelegate {
    fileprivate func checkRequestData() {
        if requestData.isReady {
            self.menubar.playHideAnimation()
            self.animator.playOutAnimation {
                self.present(PresenterViewController(withRequestData: self.requestData, mainScreen: self), animated: false, completion: nil)
            }
        } else if requestData.categories != nil {
            if self.menubar.extraRightButton!.imageView!.tag == 0 {
                self.animator.blinkLocation()
            }
        }
    }
    
    func willExpandCategoryCell(_ tableView: CategoriesTableView) {
        if self.menubar.state == .expanded {
            self.menubar.state = .collapsed
        }
    }
    
    func categoriesTableView(_ tableView: CategoriesTableView, didSelect selection: [String]?) {
        if let selection = selection {
            self.requestData.categories = selection
        }
        
        self.view.isUserInteractionEnabled = false
        tableView.collapse(completion: {
            self.view.isUserInteractionEnabled = true
            self.checkRequestData()
        })
    }
    
    func searchbar(_ searchbar: SearchBar, didSelect selection: String?) {
        if let selection = selection {
            if searchbar is LocationSearchBar {
                locationResolver.coordinates(for: selection, completion: { coordinate in
                    self.requestData.location = coordinate
                    self.requestData.isLocationFromGPS = false
                    self.menubar.changeExtraRightTabBarItem(with: UIImage(named: "location_on_icon")!.withRenderingMode(.alwaysTemplate))
                })
            } else {
                self.requestData.categories = [CategoriesDataSource.allSubcategories[selection]!]
            }
        }
        
        searchbar.collapse(completion: {
            UIView.animate(withDuration: 0.25) {
                self.tableView.alpha = 1.0
            }
            searchbar.isHidden = true
            self.menubar.isHidden = false
            self.searchBarPresented = false
            self.checkRequestData()
        })
    }
}

extension MainViewController: MenuBarResponder {
    func menuBar(_ menuBar: MenuBar, didTapItemAt index: Int) {
        if index == 0 {
            present(HistoryViewController(withCenter: menuBar.center), animated: true, completion: nil)
        } else {
            present(FavoritesViewController(withCenter: menuBar.center), animated: true, completion: nil)
        }
    
    }
    
    func menuBarDidTapRightButton(_ menuBar: MenuBar) {
        presentSearchbar(self.locationSearchbar)
        
        if let location = self.requestData.location, self.requestData.isLocationFromGPS {
            self.locationResolver.address(for: location) { address in
                if let addressText = address {
                    self.locationSearchbar.placeholderText = "Current: " + addressText
                }
            }
        }
    }
    
    func menuBarDidTapLeftButton(_ menuBar: MenuBar) {
        presentSearchbar(self.categorySearchbar)
    }
}

