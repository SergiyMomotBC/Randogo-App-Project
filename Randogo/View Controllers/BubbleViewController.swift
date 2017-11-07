//
//  ViewController.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import BubbleTransition
import FoldingTabBar
import DZNEmptyDataSet
import PopupDialog
import LiquidLoader
import ImageSlideshow

class TableView: UITableView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let fadePercentage = 0.25
        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.white.cgColor
        
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        gradientLayer.colors = [opaque, transparent]
        gradientLayer.locations = [NSNumber(floatLiteral: 1 - fadePercentage), 1]
        
        maskLayer.addSublayer(gradientLayer)
        self.layer.mask = maskLayer
    }
}

class BubbleViewController: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDelegate
{
    lazy var tableView: UITableView = {
        let table = TableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorInset = UIEdgeInsets(top: 0.0, left: table.separatorInset.left, bottom: 0.0, right: table.separatorInset.left)
        table.separatorColor = .flatDarkTeal
        table.alwaysBounceVertical = false
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: UIScreen.main.bounds.height * 0.135))
        table.tableFooterView = footer
        table.scrollIndicatorInsets = UIEdgeInsets(top: 40.0, left: 0, bottom: UIScreen.main.bounds.height * 0.135, right: 0)
        table.emptyDataSetSource = self
        return table
    }()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont(name: "AvenirNext-Bold", size: 36.0)
        label.textColor = UIColor.flatLightTeal
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var clearAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        button.setTitleColor(UIColor(red: 211.0/255, green: 84.0/255, blue: 0.0/255, alpha: 1.0), for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .highlighted)
        button.setTitle("Clear All", for: .normal)
        return button
    }()
    
    private let transition = BubbleTransition()
    private let transitionColor: UIColor
    private let transitionCenter: CGPoint
    fileprivate var overlayLoadingView: UIView!
    var searchbar: PlacesSearchbar!
    var isSearching = false
    
    init(withCenter center: CGPoint) {
        self.transitionColor = UIColor.flatPurple
        self.transitionCenter = center
        
        super.init(nibName: nil, bundle: nil)
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = transitionColor
        
        view.addSubview(headerLabel)
        headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        
        headerLabel.addSubview(clearAllButton)
        clearAllButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor, constant: 3.0).isActive = true
        clearAllButton.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: -10.0).isActive = true
        
        searchbar = PlacesSearchbar(icon: UIImage(named: "search_icon")!.withRenderingMode(.alwaysTemplate))
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        searchbar.searchbarDelegete = self
        searchbar.delegate = self
        searchbar.placeholder = "Search places..."
        view.addSubview(searchbar)
        searchbar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor).isActive = true
        searchbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        searchbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        searchbar.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: searchbar.bottomAnchor, constant: 12.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.delegate = self
        
        let size = UIScreen.main.bounds.height * 0.135 - 2 * YALTabBarViewHDefaultEdgeInsets.top
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
        button.backgroundColor = UIColor.flatLightTeal
        button.tintColor = .white
        button.setImage(UIImage(named: "close_icon")!.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = button.bounds.width / 2.0
        view.addSubview(button)
        button.center = transitionCenter
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.applyShadow(ofRadius: 8.0, andOpacity: 0.4)
    }

    
    func createAlert(withTitle title: String, message: String, action: @escaping () -> Void) -> PopupDialog {
        let vc = PopupDialog(title: title, message: message, image: nil, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        
        let confirmButton = DefaultButton(title: "Confirm", height: 60, dismissOnTap: true, action:  action)
        let cancelButton = DefaultButton(title: "Cancel", height: 60, dismissOnTap: true, action: nil)
        vc.addButtons([cancelButton, confirmButton])
        
        return vc
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.duration = 0.45
        transition.startingPoint = transitionCenter
        transition.bubbleColor = transitionColor
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.duration = 0.45
        transition.startingPoint = transitionCenter
        transition.bubbleColor = transitionColor
        return transition
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isSearching && searchbar.isEditing {
            searchbar.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.setContentOffset(.zero, animated: false)
        }
    }
    
    func getCellForRowAt(indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableViewCell.self))
            cell!.backgroundColor = .clear
            cell!.textLabel?.textColor = .flatLightTeal
            cell!.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 20.0)
            cell!.detailTextLabel?.textColor = .lightText
            cell!.detailTextLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        }
        
        return cell!
    }
    
    func updatePlacesFor(_ text: String) {
        self.tableView.setContentOffset(.zero, animated: false)
    }
}

extension BubbleViewController: PlacesSearchbarDelegate, UITextFieldDelegate {
    func placesSearchbar(_ searchbar: PlacesSearchbar, didChangeTextTo text: String?) {
        if text == nil {
            self.searchbar.endEditing(true)
            self.searchbar.text = nil
        }
        
        updatePlacesFor(text ?? "")
        tableView.reloadData()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clearAllButton.isHidden = true
        self.isSearching = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.clearAllButton.isHidden = false
        self.isSearching = false
    }
}

extension BubbleViewController {
    func loadDataForPlaceID(_ placeID: String) {
        if isSearching && searchbar.isEditing {
            searchbar.endEditing(true)
        }
        
        self.overlayLoadingView = UIView()
        overlayLoadingView.translatesAutoresizingMaskIntoConstraints = false
        overlayLoadingView.backgroundColor = UIColor.flatPurple
        self.view.addSubview(overlayLoadingView)
        overlayLoadingView.clipToSuperview()
        
        let loader = LiquidLoader(frame: CGRect(x: 100, y: 200, width: view.frame.width - 200, height: view.frame.width - 200), effect: .growCircle(UIColor.flatDarkTeal, 8, 1.0, nil))
        loader.applyShadow(ofRadius: 8.0, andOpacity: 0.45)
        loader.show(in: overlayLoadingView)
        
        load(placeID)
    }
    
    private func load(_ placeID: String) {
        YelpDataLoader.shared.loadPlaceInfo(forPlace: PlaceMetadata(id: placeID, priceRange: 0, distance: 0.0, rating: 0.0), completion: { placeInfo in
            if let place = placeInfo {
                self.overlayLoadingView.removeFromSuperview()
                self.overlayLoadingView = nil
                
                let detailsVC = PlaceDetailsViewController(forPlace: place, withRequestData: nil)
                detailsVC.view.tag = 0
                detailsVC.modalTransitionStyle = .crossDissolve

                let frontImageView = ImageSlideshow()
                frontImageView.translatesAutoresizingMaskIntoConstraints = false
                frontImageView.contentScaleMode = .scaleAspectFill
                frontImageView.activityIndicator = DefaultActivityIndicator(style: .whiteLarge, color: UIColor.flatDarkTeal)
                frontImageView.tag = 11
                detailsVC.headerView.addSubview(frontImageView)
                frontImageView.clipToSuperview()
                
                if !place.imageURLs.isEmpty {
                    let sources = place.imageURLs.map { KingfisherSource(urlString: $0, placeholder: UIImage(named: "loading_image_placeholder"))! } as [InputSource]
                    frontImageView.setImageInputs(sources)
                } else {
                    frontImageView.setImageInputs([ImageSource(image: UIImage(named: "no_image_placeholder")!)])
                }
                
                self.present(detailsVC, animated: true, completion: nil)
            } else {
                let alert = PopupDialog(title: "Loading error", message: "Your device is either not connected to the Internet or Yelp server is not responding.",
                                        image: nil, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
                
                let retryButton = DefaultButton(title: "Try again", height: 60, dismissOnTap: true, action: {
                    self.load(placeID)
                })
                
                let returnButton = DefaultButton(title: "Cancel", height: 60, dismissOnTap: true, action: {
                    self.overlayLoadingView.removeFromSuperview()
                    self.overlayLoadingView = nil
                })
                
                alert.addButtons([returnButton, retryButton])
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}

extension BubbleViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Demibold", size: 24.0)!, NSForegroundColorAttributeName: UIColor.lightText]
        return NSAttributedString(string: !isSearching ? "No places here so far." : "No places found.", attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty_places")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(UIScreen.main.bounds.height - 110.0 - UIApplication.shared.statusBarFrame.height) * 0.093
    }
}

























