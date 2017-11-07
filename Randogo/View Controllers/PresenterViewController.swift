//
//  PresenterViewController.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/28/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import MapKit
import expanding_collection
import LiquidLoader
import PopupDialog
import DZNEmptyDataSet

class PresenterViewController: ExpandingViewController {
    static let cellSize = CGSize(width: 0.7 * UIScreen.main.bounds.width, height: 0.5 * UIScreen.main.bounds.height)
    
    let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.flatPurple
        return view
    }()
    
    private func createErrorAlert(for error: DataLoaderError) -> PopupDialog {
        let title = error == .noInternetConnection ? "Connection error" : "Yelp server error"
        let message = error == .noInternetConnection ? "It appears that your device is not connected to the Internet." : "Randogo could not retrieve data from Yelp servers."
        
        let vc = PopupDialog(title: title, message: message, image: nil, buttonAlignment: .horizontal,
                             transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        
        let retryButton = DefaultButton(title: "Try again", height: 60, dismissOnTap: true, action: {
            self.loadData()
        })
        
        let returnButton = DefaultButton(title: "Cancel", height: 60, dismissOnTap: true, action: {
            self.animator.playOutAnimation()
        })
        
        vc.addButtons([returnButton, retryButton])
        
        return vc
    }
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.flatLightTeal
        label.font = UIFont(name: "AvenirNext-Demibold", size: 18.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Shake your device to show another random place"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.isHidden = true
        label.applyShadow(ofRadius: 8.0, andOpacity: 0.45)
        return label
    }()
    
    var filterPopover: UIView!
    var filterPopoverContstraint: NSLayoutConstraint!
    var blurView: UIView!
    let filterController = FilterPopoverViewController()
    weak var main: MainViewController?
    var mapView: PlaceMapView!
    var loader: LiquidLoader!
    let animator = PresenterScreenAnimator()
    var foldingBar: MenuBar!
    var allowShaking = false
    let requestData: RequestData
    var didLoadData = false
    var places: [PlaceMetadata] = []
    var anchor: UIView!
    
    init(withRequestData requestData: RequestData, mainScreen: MainViewController) {
        self.requestData = requestData
        super.init(nibName: nil, bundle: nil)
        animator.presenterScreen = self
        self.main = mainScreen
        
        loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = PlaceMapView(in: self.view)
        
        view.addSubview(overlayView)
        overlayView.clipToSuperview()
        
        itemSize = PresenterViewController.cellSize
        collectionView?.register(PlaceExpandingCell.self, forCellWithReuseIdentifier: String(describing: PlaceExpandingCell.self))
        collectionView?.isScrollEnabled = false
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        view.bringSubview(toFront: self.collectionView!)
        setupSwipeGestures()
        
        view.addSubview(infoLabel)
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
        infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0).isActive = true
        
        foldingBar = MenuBar.createFor(self)
        foldingBar.isHidden = true
        foldingBar.switchToSingleMode(withImage: UIImage(named: "filter_icon")!.withRenderingMode(.alwaysTemplate)) { [weak self] in
            self?.allowShaking = false
            self?.displayPopover()
        }
        
        view.layoutIfNeeded()
        
        collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: view.frame.height - foldingBar.frame.height - infoLabel.frame.height - 40.0).isActive = true
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.alpha = 0.0
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, belowSubview: foldingBar)
        blurView.clipToSuperview()
        
        filterPopover = UIView()
        filterPopover.translatesAutoresizingMaskIntoConstraints = false
        filterPopover.layer.cornerRadius = 16.0
        filterPopover.isOpaque = true
        filterPopover.layer.shouldRasterize = true
        filterPopover.layer.rasterizationScale = UIScreen.main.scale
        filterPopover.clipsToBounds = true
        view.addSubview(filterPopover)
        filterPopover.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        filterPopover.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        filterPopover.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55).isActive = true
        filterPopoverContstraint = filterPopover.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -view.frame.height)
        filterPopoverContstraint.isActive = true
        
        self.addChildViewController(filterController)
        filterController.view.translatesAutoresizingMaskIntoConstraints = false
        filterPopover.addSubview(filterController.view)
        filterController.view.clipToSuperview()
        self.filterController.didMove(toParentViewController: self)
        
        filterController.delegate = self
        
        anchor = UIView(frame: CGRect(x: self.view.bounds.midX, y: 40 + infoLabel.frame.height, width: 1.0, height: 1.0))
        anchor.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(anchor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.allowShaking = true
    }
    
    fileprivate func displayPopover() {
        self.filterPopoverContstraint.constant = 0.0
        self.allowShaking = false
        self.filterController.prepare()
        self.foldingBar.hideExtraLeftTabBarItem()
        self.foldingBar.hideExtraRightTabBarItem()
        
        DispatchQueue.main.async {
            self.foldingBar.switchToSingleMode(withImage: UIImage(named: "close_icon")!.withRenderingMode(.alwaysTemplate), andAction: { [weak self] in
                self?.hidePopover()
            })
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.blurView.alpha = 1.0
        }, completion: nil)
    }
    
    fileprivate func hidePopover(completion: (() -> Void)? = nil) {
        self.filterPopoverContstraint.constant = -self.view.frame.height
        self.foldingBar.showExtraLeftTabBarItem()
        self.foldingBar.showExtraRightTabBarItem()
        
        DispatchQueue.main.async {
            self.foldingBar.switchToSingleMode(withImage: UIImage(named: "filter_icon")!.withRenderingMode(.alwaysTemplate), andAction: { [weak self] in
                self?.displayPopover()
            })
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.blurView.alpha = 0.0
        }, completion: { success in
            self.allowShaking = true
            completion?()
        })
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake && allowShaking {
            if currentIndex == self.places.count - 1 {
                self.infoLabel.text = "No more places"
                self.infoLabel.isHidden = false
                self.animator.shakeAnimation()
                return
            }
            
            UIView.animate(withDuration: 0.35, animations: {
                self.overlayView.alpha = 1.0
            })
            
            self.infoLabel.isHidden = true
            self.animator.playPlaceUpdateAnimation(updateAction: {
                guard let cell = self.collectionView?.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? PlaceExpandingCell else { return }
                if cell.isOpened {
                    cell.cellIsOpen(false, animated: false)
                }
            
                self.collectionView?.scrollToItem(at: IndexPath(row: self.currentIndex + 1, section: 0), at: .centeredHorizontally, animated: false)
            })
        }
    }
    
    func createLoadingLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.flatLightTeal
        label.font = UIFont(name: "AvenirNext-Demibold", size: 24.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.applyShadow(ofRadius: 8.0, andOpacity: 0.45)
        label.text = "Retrieving places..."
        return label
    }
    
    fileprivate func loadData() {
        if self.loader == nil {
            loader = LiquidLoader(frame: CGRect(x: 100, y: 200, width: view.frame.width - 200, height: view.frame.width - 200), effect: .growCircle(UIColor.flatDarkTeal, 8, 1.0, nil))
            loader.applyShadow(ofRadius: 8.0, andOpacity: 0.45)
            self.loader.show(in: self.view)
        }
        
        self.allowShaking = false
        self.didLoadData = false
        
        let label = createLoadingLabel()
        self.view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: loader.topAnchor, constant: -40.0).isActive = true
        
        YelpDataLoader.shared.loadPlaces(forRequest: self.requestData, filterOptions: self.filterController.currentOptions, completion: { places, error in
            self.places.removeAll()
            
            guard error == nil else {
                let alert = self.createErrorAlert(for: error!)
                label.removeFromSuperview()
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.allowShaking = true
            self.didLoadData = true
            
            self.loader.hide()
            self.loader = nil
            label.removeFromSuperview()
            
            self.places = places ?? []
            self.presentData()
            self.animator.playInAnimation {
                if !self.places.isEmpty {
                    FirstTimeHints.shared.handlePresenterScreenHint(for: self)
                }
            }
        })
    }
    
    fileprivate func presentData() {
        self.foldingBar.extraRightButton?.isEnabled = !self.places.isEmpty
        self.collectionView?.setContentOffset(CGPoint(x: -0.159 * UIScreen.main.bounds.width, y: 0), animated: false)
        self.collectionView?.reloadData()
        self.collectionView?.isScrollEnabled = false
        self.infoLabel.alpha = 1.0
        self.infoLabel.isHidden = self.places.isEmpty
        
        if !self.places.isEmpty {
            self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
            self.infoLabel.text = "Shake your device to show another place"
            self.infoLabel.isHidden = false
            self.allowShaking = true
        }
    }
}

extension PresenterViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "no_places_placeholder")!
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String: Any] = [NSFontAttributeName: UIFont(name: "AvenirNext-Demibold", size: 24.0)!,
                                         NSForegroundColorAttributeName: UIColor.white]
        
        return NSAttributedString(string: "No open places found...", attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = "Try to increase the search radius or change price categories."
        let attributes: [String: Any] = [NSFontAttributeName: UIFont(name: "AvenirNext-Demibold", size: 18.0)!,
                                         NSForegroundColorAttributeName: UIColor.lightText]
        
        return NSAttributedString(string: description, attributes: attributes)
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return didLoadData
    }
}

extension PresenterViewController: FilterPopoverViewControllerDelegate {
    func filterController(_ filterController: FilterPopoverViewController, didCommitChanges changes: Bool) {
        self.hidePopover {
            if changes {
                self.foldingBar.playHideAnimation()
                UIView.animate(withDuration: 0.5, animations: {
                    self.collectionView!.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    self.infoLabel.alpha = 0.0
                    self.overlayView.alpha = 1.0
                }, completion: { success in
                    DispatchQueue.main.async {
                        self.loadData()
                    }
                })
            }
        }
    }
}

extension PresenterViewController {
    fileprivate func setupSwipeGestures() {
        let upGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        upGesture.direction = .up
        collectionView?.addGestureRecognizer(upGesture)
        
        let downGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        downGesture.direction = .down
        collectionView?.addGestureRecognizer(downGesture)
    }
    
    @objc private func swipeHandler(_ recognizer: UISwipeGestureRecognizer) {
        guard let cell = collectionView?.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? PlaceExpandingCell else { return }
        
        if cell.isOpened && recognizer.direction == .up {
            self.foldingBar.playHideAnimation()
            let detailsVC = PlaceDetailsViewController(forPlace: cell.place!, withRequestData: self.requestData)
            self.allowShaking = false
            pushToViewController(detailsVC) { [weak self] in
                self?.foldingBar.playShowAnimation(withDelay: 0.0)
            }
        } else if !cell.isOpened && recognizer.direction == .up {
            cell.cellIsOpen(true)
        } else if cell.isOpened && recognizer.direction == .down {
            cell.cellIsOpen(false)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.places.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PlaceExpandingCell.self), for: indexPath) as! PlaceExpandingCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let cell = cell as? PlaceExpandingCell {
            loadInfo(for: cell)
        }
    }
    
    private func loadInfo(for cell: PlaceExpandingCell) {
        cell.errorOverlayView?.removeFromSuperview()
        cell.errorOverlayView = nil
        
        cell.startAnimating()
        YelpDataLoader.shared.loadPlaceInfo(forPlace: self.places[self.currentIndex], completion: { place in
            if let place = place {
                cell.allowOpening = true
                self.foldingBar.extraRightButton?.isEnabled = true
                cell.setupCell(withPlaceInfo: place)
                self.mapView.showPlace(place, animated: false)
                CoreDataManager.shared.addPlaceToHistory(place)
                UIView.animate(withDuration: 0.35, animations: {
                    self.overlayView.alpha = 0.7
                })
            } else {
                cell.allowOpening = false
                self.foldingBar.extraRightButton?.isEnabled = false
                cell.showError {
                    self.loadInfo(for: cell)
                }
            }
            cell.stopAnimating()
        })

    }
}

extension PresenterViewController: MenuBarResponder {
    func menuBarDidTapRightButton(_ menuBar: MenuBar) {
        self.animator.playRevealMapAnimation()
    }
    
    func menuBarDidTouchDownRightButton(_ menuBar: MenuBar) {
        self.animator.playHideMapAnimation()
    }
    
    func menuBarDidTapLeftButton(_ menuBar: MenuBar) {
        self.filterController.removeFromParentViewController()
        mapView.delegate = nil
        mapView.removeFromSuperview()
        mapView = nil
        
        self.animator.playOutAnimation()
    }
}
