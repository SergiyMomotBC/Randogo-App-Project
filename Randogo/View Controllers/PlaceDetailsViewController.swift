//
//  PlaceDetailsViewController.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/29/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import expanding_collection
import FoldingTabBar
import PopupDialog
import ImageSlideshow

class PlaceDetailsViewController: ExpandingTableViewController {
    var place: PlaceInfo!
    var requestData: RequestData?
    let mapInfo = PlaceMapInfo()
    var menubar: MenuBar!
    var slideshow: ImageSlideshow!
    var frontNameLabel: UILabel!
    var nameLabelBackgroundView: UIView!
    var anchor: UIView!
    
    fileprivate func createMapChooserAlert() -> PopupDialog {
        let vc = PopupDialog(title: "Choose map directions provider:", message: nil,
                             image: nil, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true, completion: nil)

        let button = DefaultButton(title: "Apple Maps", height: 60, dismissOnTap: true, action: {
            var directionsURLString: String
            if let requestData = self.requestData {
                directionsURLString = "http://maps.apple.com/?saddr=\(requestData.location.latitude),\(requestData.location.longitude)&daddr=\(self.place.location.latitude),\(self.place.location.longitude)&dirflg=d"
            } else {
                directionsURLString = "http://maps.apple.com/?saddr=&daddr=\(self.place.location.latitude),\(self.place.location.longitude)&dirflg=d"
            }
            
            if let url = URL(string: directionsURLString) {
                UIApplication.shared.open(url)
            }
        })

        let returnButton = DefaultButton(title: "Google Maps", height: 60, dismissOnTap: true, action: {
            var directionsURLString: String
            if let requestData = self.requestData {
                directionsURLString = "https://www.google.com/maps/dir/?api=1&origin=\(requestData.location.latitude),\(requestData.location.longitude)&destination=\(self.place.location.latitude),\(self.place.location.longitude)&travelmode=driving"
            } else {
                directionsURLString = "https://www.google.com/maps/dir/?api=1&origin=&destination=\(self.place.location.latitude),\(self.place.location.longitude)&travelmode=driving"
            }
           
            if let url = URL(string: directionsURLString) {
                UIApplication.shared.open(url)
            }
        })

        vc.addButtons([returnButton, button])

        return vc
    }
    
    init(forPlace place: PlaceInfo, withRequestData requestData: RequestData?) {
        self.requestData = requestData
        self.place = place
        super.init(nibName: nil, bundle: nil)
        self.headerHeight = UIScreen.main.bounds.height * 0.334
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.flatPurple

        
        view.addSubview(mapInfo)
        mapInfo.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        mapInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapInfo.heightAnchor.constraint(equalTo: self.headerView.heightAnchor, multiplier: 0.36).isActive = true
        view.layoutIfNeeded()
        mapInfo.update(for: self.place)
        
        menubar = MenuBar.createFor(self)
        menubar.isHidden = true
        
        let yelpProviderLabel = UILabel()
        yelpProviderLabel.translatesAutoresizingMaskIntoConstraints = false
        yelpProviderLabel.textAlignment = .center
        yelpProviderLabel.textColor = .lightText
        yelpProviderLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        yelpProviderLabel.text = "Place information is provided by Yelp."
        view.addSubview(yelpProviderLabel)
        yelpProviderLabel.bottomAnchor.constraint(equalTo: menubar.topAnchor).isActive = true
        yelpProviderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        yelpProviderLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        let infoView = PlaceInfoView(forPlace: self.place)
        view.addSubview(infoView)
        infoView.topAnchor.constraint(equalTo: mapInfo.bottomAnchor).isActive = true
        infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: YALForExtraTabBarItemsDefaultOffset).isActive = true
        infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -YALForExtraTabBarItemsDefaultOffset).isActive = true
        infoView.bottomAnchor.constraint(equalTo: yelpProviderLabel.topAnchor).isActive = true
        
        self.frontNameLabel = UILabel()
        frontNameLabel.alpha = 0.0
        frontNameLabel.font = UIFont(name: "AvenirNext-Demibold", size: 24.0)
        frontNameLabel.translatesAutoresizingMaskIntoConstraints = false
        frontNameLabel.numberOfLines = 0
        frontNameLabel.textAlignment = .center
        frontNameLabel.textColor = UIColor.flatLightTeal
        frontNameLabel.text = place.name
        view.addSubview(frontNameLabel)
        frontNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
        frontNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        frontNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 8.0).isActive = true
        frontNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -8.0).isActive = true
        
        self.nameLabelBackgroundView = UIView()
        nameLabelBackgroundView.alpha = 0.0
        nameLabelBackgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        nameLabelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(nameLabelBackgroundView, belowSubview: frontNameLabel)
        nameLabelBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        nameLabelBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        nameLabelBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        nameLabelBackgroundView.heightAnchor.constraint(equalTo: frontNameLabel.heightAnchor, multiplier: 1.0, constant: UIApplication.shared.statusBarFrame.height).isActive = true
        
        view.layoutSubviews()
        infoView.applyShadow(ofRadius: 8.0, andOpacity: 0.45)
        
        anchor = UIView(frame: CGRect(x: self.view.bounds.midX, y: self.headerHeight, width: 1.0, height: 1.0))
        anchor.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(anchor)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.frontNameLabel.alpha = 0.0
        self.nameLabelBackgroundView.alpha = 0.0
    }
    
    @objc private func didTap() {
        slideshow.presentFullScreenController(from: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menubar.isHidden = false
        menubar.playShowAnimation(withDelay: 0.0)
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: {
            self.frontNameLabel.alpha = 1.0
            self.nameLabelBackgroundView.alpha = 1.0
        }, completion: nil)
        
        if slideshow == nil {
            if let slideshow = self.headerView.subviews.first as? ImageSlideshow {
                self.slideshow = slideshow
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
                slideshow.addGestureRecognizer(gestureRecognizer)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0166667) { 
            if CoreDataManager.shared.isPlaceInFavorites(placeID: self.place.id) {
                self.menubar.changeExtraRightTabBarItem(with: UIImage(named: "favorite_on_icon")!.withRenderingMode(.alwaysTemplate))
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirstTimeHints.shared.handlePlaceDetailsScreenHint(for: self)
    }
}

extension PlaceDetailsViewController: MenuBarResponder {
    func menuBarDidTapLeftButton(_ menuBar: MenuBar) {
        if self.requestData != nil {
            self.popTransitionAnimation()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func menuBar(_ menuBar: MenuBar, didTapItemAt index: Int) {
        switch index {
        case 0:
            makeCall()
        case 1:
            openYelpWebpage()
        case 2:
            getMapDirections()
        case 3:
            shareLink()
        default:
            fatalError()
        }
    }
    
    func menuBarDidTapRightButton(_ menuBar: MenuBar) {
        if !CoreDataManager.shared.isPlaceInFavorites(placeID: self.place.id) {
            menuBar.changeExtraRightTabBarItem(with: UIImage(named: "favorite_on_icon")!.withRenderingMode(.alwaysTemplate))
            CoreDataManager.shared.addPlaceToFavorites(self.place)
        } else {
            menubar.changeExtraRightTabBarItem(with: UIImage(named: "favorite_off_icon")!.withRenderingMode(.alwaysTemplate))
            CoreDataManager.shared.deletePlaceFromFavorites(self.place)
        }
    }
    
    private func makeCall() {
        if let callURL = URL(string: "telprompt://\(String(self.place.phoneNumber.characters.dropFirst()))"), UIApplication.shared.canOpenURL(callURL) {
            UIApplication.shared.open(callURL)
        }
    }
    
    private func openYelpWebpage() {
        if let yelpURL = URL(string: self.place.yelpURL) {
            UIApplication.shared.open(yelpURL)
        }
    }
    
    private func getMapDirections() {
        let alert = createMapChooserAlert()
        self.present(alert, animated: true, completion: nil)
    }
    
    private func shareLink() {
        let text = "Randogo app helped me to discover this awesome place. Check it out on Yelp."
        let webpage = URL(string: self.place.yelpURL)!
        let shareSheet = UIActivityViewController(activityItems: [text, webpage], applicationActivities: nil)
        shareSheet.excludedActivityTypes = [.airDrop, .assignToContact, .print, .postToVimeo, .postToFlickr, .saveToCameraRoll]
        self.present(shareSheet, animated: true, completion: nil)
    }
}
