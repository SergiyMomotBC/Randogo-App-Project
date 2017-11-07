//
//  File.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/29/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import expanding_collection
import Kingfisher
import ImageSlideshow
import LiquidLoader

class PlaceExpandingCell: BasePageCollectionCell {
    var frontImageView: ImageSlideshow!
    var frontNameLabel: UILabel!
    var closesAtLabel: UILabel!
    var ratingImageView: UIImageView!
    var reviewsCountLabel: UILabel!
    var yelpLogoImageView: UIImageView!
    var allowOpening = true
    var place: PlaceInfo?
    var errorOverlayView: UIView?
    private var retryAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backContainerView = createBackView()
        frontContainerView = createFrontView()
        super.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(withPlaceInfo place: PlaceInfo) {
        self.place = place
        frontNameLabel.text = place.name

        if !place.imageURLs.isEmpty {
            let sources = place.imageURLs.map { KingfisherSource(urlString: $0, placeholder: UIImage(named: "loading_image_placeholder"))! } as [InputSource]
            frontImageView.setImageInputs(sources)
        } else {
            frontImageView.setImageInputs([ImageSource(image: UIImage(named: "no_image_placeholder")!)])
        }
 
        let timeText = NSMutableAttributedString(string: "Closes today at ")
        timeText.append(NSAttributedString(string: place.todayCloseTimeText,attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Bold", size: closesAtLabel.font.pointSize)!]))
        closesAtLabel.attributedText = timeText
        
        ratingImageView.image = UIImage(named: "rating_\(Int(place.rating))\(place.rating > Double(Int(place.rating)) ? "_half" : "")")
        reviewsCountLabel.text = "Based on \(place.reviewCount) \(place.reviewCount > 1 ? "reviews" : "review")"
    }
    
    override func copyCell() -> BasePageCollectionCell? {
        let copy = PlaceExpandingCell(frame: .zero)
        copy.setupCell(withPlaceInfo: self.place!)
        copy.frontImageView.setCurrentPage(self.frontImageView.currentPage, animated: false)
        return copy
    }
    
    override func cellIsOpen(_ isOpen: Bool, animated: Bool = true) {
        if allowOpening {
            super.cellIsOpen(isOpen, animated: animated)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if isOpened {
            cellIsOpen(false, animated: false)
        }
        self.frontImageView.setCurrentPage(0, animated: false)
        
        if self.errorOverlayView != nil {
            errorOverlayView?.removeFromSuperview()
            self.errorOverlayView = nil
        }
    }
    
    func showError(retryAction: (() -> Void)?) {
        self.retryAction = retryAction
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.flatLightTeal
        self.frontContainerView.addSubview(view)
        view.clipToSuperview()
        self.errorOverlayView = view
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Demibold", size: 20.0)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.text = "Error while loading place information from Yelp server."
        label.textAlignment = .center
        view.addSubview(label)
        label.centerInSuperview()
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Try again", for: .normal)
        button.setTitleColor(UIColor.flatDarkTeal, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 24.0)
        view.addSubview(button)
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -26.0).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
    }
    
    @objc private func retry() {
        self.retryAction?()
        self.retryAction = nil
    }
    
    func startAnimating() {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.tag = 33
        overlay.backgroundColor = UIColor.flatLightTeal
        frontContainerView.addSubview(overlay)
        overlay.clipToSuperview()
        
        let size = PresenterViewController.cellSize.width * 0.4
        let loader = LiquidLoader(frame: CGRect(x: (PresenterViewController.cellSize.width - size) / 2, y: (PresenterViewController.cellSize.height - size) / 2, width: size, height: size), effect: .growCircle(UIColor.flatDarkTeal, 8, 0.75, nil))
        loader.show(in: overlay)
        self.allowOpening = false
    }
    
    func stopAnimating() {
        frontContainerView.viewWithTag(33)?.removeFromSuperview()
    }

    private func createTransactionLabel(text: String, image: UIImage) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        label.textColor = UIColor.white
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0.0, y: -4.0, width: image.size.width, height: image.size.height)
        
        let result = NSMutableAttributedString(string: "")
        let imageString = NSAttributedString(attachment: attachment)
        let textString = NSMutableAttributedString(string: "  " + text)
        result.append(imageString)
        result.append(textString)

        label.attributedText = result
        label.tintColor = .green
        
        return label
    }
    
    private func createFrontView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.flatLightTeal
        
        contentView.addSubview(view)
        view.heightAnchor.constraint(equalToConstant: PresenterViewController.cellSize.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: PresenterViewController.cellSize.width).isActive = true
        view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        frontConstraintY = view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        frontConstraintY.isActive = true
        
        frontImageView = ImageSlideshow()
        frontImageView.translatesAutoresizingMaskIntoConstraints = false
        frontImageView.contentScaleMode = .scaleAspectFill
        frontImageView.activityIndicator = DefaultActivityIndicator(style: .whiteLarge, color: UIColor.flatDarkTeal)
        frontImageView.tag = 11
        view.addSubview(frontImageView)
        frontImageView.clipToSuperview()
        
        frontNameLabel = createLabel(font: UIFont(name: "AvenirNext-Demibold", size: 24.0)!, lines: 0)
        frontNameLabel.textColor = UIColor.flatLightTeal
        frontNameLabel.tag = 101
        view.addSubview(frontNameLabel)
        frontNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        frontNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        frontNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 8.0).isActive = true
        frontNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -8.0).isActive = true
        
        let nameLabelBackgroundView = UIView()
        nameLabelBackgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        nameLabelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        nameLabelBackgroundView.tag = 101
        view.insertSubview(nameLabelBackgroundView, belowSubview: frontNameLabel)
        nameLabelBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        nameLabelBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        nameLabelBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        nameLabelBackgroundView.heightAnchor.constraint(equalTo: frontNameLabel.heightAnchor, multiplier: 1.0).isActive = true
        
        return view
    }
    
    private func createLabel(font: UIFont, lines: Int) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = font
        label.textAlignment = .center
        label.numberOfLines = lines
        return label
    }
    
    private func createBackView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.flatLightTeal
        
        contentView.addSubview(view)
        view.heightAnchor.constraint(equalToConstant: PresenterViewController.cellSize.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: PresenterViewController.cellSize.width).isActive = true
        view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        backConstraintY = view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        backConstraintY.isActive = true
        
        let ratingContainer = UIView()
        ratingContainer.backgroundColor = .clear
        ratingContainer.translatesAutoresizingMaskIntoConstraints = false
        
        ratingImageView = UIImageView()
        ratingImageView.translatesAutoresizingMaskIntoConstraints = false
        ratingImageView.backgroundColor = .clear
        ratingImageView.contentMode = .scaleAspectFit
        ratingImageView.applyShadow(ofRadius: 6.0, andOpacity: 0.45)
        ratingContainer.addSubview(ratingImageView)
        ratingImageView.topAnchor.constraint(equalTo: ratingContainer.topAnchor, constant: 0.0).isActive = true
        ratingImageView.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor, constant: 0.0).isActive = true
        ratingImageView.heightAnchor.constraint(equalTo: ratingContainer.heightAnchor, multiplier: 0.5).isActive = true
        ratingImageView.widthAnchor.constraint(equalTo: ratingContainer.widthAnchor, multiplier: 0.5).isActive = true

        reviewsCountLabel = createLabel(font: UIFont(name: "AvenirNext-Regular", size: 16.0)!, lines: 1)
        reviewsCountLabel.textAlignment = .left
        reviewsCountLabel.minimumScaleFactor = 0.5
        reviewsCountLabel.adjustsFontSizeToFitWidth = true
        ratingContainer.addSubview(reviewsCountLabel)
        reviewsCountLabel.topAnchor.constraint(equalTo: ratingImageView.bottomAnchor, constant: 0.0).isActive = true
        reviewsCountLabel.bottomAnchor.constraint(equalTo: ratingContainer.bottomAnchor, constant: 0.0).isActive = true
        reviewsCountLabel.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor, constant: 0.0).isActive = true
        reviewsCountLabel.widthAnchor.constraint(equalTo: ratingImageView.widthAnchor, multiplier: 1.0).isActive = true
        
        yelpLogoImageView = UIImageView(image: UIImage(named: "Yelp_trademark"))
        yelpLogoImageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapYelpLogo))
        tapRecognizer.numberOfTapsRequired = 1
        yelpLogoImageView.addGestureRecognizer(tapRecognizer)
        yelpLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        yelpLogoImageView.contentMode = .scaleAspectFit
        yelpLogoImageView.backgroundColor = .clear
        ratingContainer.addSubview(yelpLogoImageView)
        yelpLogoImageView.trailingAnchor.constraint(equalTo: ratingContainer.trailingAnchor, constant: 16.0).isActive = true
        yelpLogoImageView.topAnchor.constraint(equalTo: ratingContainer.topAnchor, constant: -8.0).isActive = true
        yelpLogoImageView.bottomAnchor.constraint(equalTo: ratingContainer.bottomAnchor, constant: -8.0).isActive = true

        view.addSubview(ratingContainer)
        ratingContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0).isActive = true
        ratingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        ratingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        ratingContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.18).isActive = true
        
        closesAtLabel = createLabel(font: UIFont(name: "AvenirNext-Demibold", size: 18.0)!, lines: 1)
        closesAtLabel.adjustsFontSizeToFitWidth = true
        closesAtLabel.minimumScaleFactor = 0.5
        view.addSubview(closesAtLabel)
        closesAtLabel.bottomAnchor.constraint(equalTo: ratingContainer.topAnchor, constant: -6.0).isActive = true
        closesAtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        closesAtLabel.heightAnchor.constraint(equalTo: ratingContainer.heightAnchor, multiplier: 0.5).isActive = true
        closesAtLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20.0).isActive = true
        closesAtLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20.0).isActive = true
        
        return view
    }
    
    @objc private func didTapYelpLogo() {
        if let url = URL(string: self.place?.yelpURL ?? "-1"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
