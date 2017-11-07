//
//  File.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/19/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class PlaceInfoView: UIView {
    
    let place: PlaceInfo
    
    init(forPlace place: PlaceInfo) {
        self.place = place
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupView()
        applyShadow(ofRadius: 200.0, andOpacity: 0.45)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillProportionally
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainStackView)
        mainStackView.clipToSuperview()
        
        let phoneEntry = createEntryStackView()
        phoneEntry.addArrangedSubview(createLabel(text: "Phone number:"))
        phoneEntry.addArrangedSubview(createLabel(text: place.displayPhoneNumber))
        
        let distanceEntry = createEntryStackView()
        distanceEntry.addArrangedSubview(createLabel(text: "Distance:"))
        distanceEntry.addArrangedSubview(createLabel(text: "\(String(format: "%.3f", place.distance / 1600.0)) miles"))
        
        let closeTimeEntry = createEntryStackView()
        closeTimeEntry.addArrangedSubview(createLabel(text: "Closes today at:"))
        
        closeTimeEntry.addArrangedSubview(createLabel(text: place.todayCloseTimeText))
        
        let priceEntry = createEntryStackView()
        priceEntry.addArrangedSubview(createLabel(text: "Price category:"))
        priceEntry.addArrangedSubview(createLabel(text: String(repeating: "$", count: place.priceRange)))

        let transactionsEntry = createEntryStackView()
        transactionsEntry.addArrangedSubview(createLabel(text: "Transactions:"))
        let transactionsListLabel = createLabel(text: String(place.transactions.reduce("", { $0 + $1.capitalized + ", " }).characters.dropLast(2)))
        transactionsListLabel.numberOfLines = 0
        transactionsEntry.addArrangedSubview(transactionsListLabel)
        
        let categoryEntry = createEntryStackView()
        categoryEntry.addArrangedSubview(createLabel(text: "Categories:"))
        let categoriesListLabel = createLabel(text: String(place.categories.reduce("", { $0 + $1 + ", " }).characters.dropLast(2)))
        categoriesListLabel.numberOfLines = 0
        categoryEntry.addArrangedSubview(categoriesListLabel)
        
        let ratingEntry = createEntryStackView()
        ratingEntry.addArrangedSubview(createLabel(text: "Rating:"))
        let reviews = createEntryStackView()
        let ratingImageView = UIImageView()
        ratingImageView.translatesAutoresizingMaskIntoConstraints = false
        ratingImageView.backgroundColor = .clear
        ratingImageView.contentMode = .scaleAspectFit
        ratingImageView.image = UIImage(named: "rating_\(Int(place.rating))\(place.rating > Double(Int(place.rating)) ? "_half" : "")")
        reviews.addArrangedSubview(ratingImageView)
        reviews.addArrangedSubview(createLabel(text: "  (\(place.reviewCount))"))
        ratingEntry.addArrangedSubview(reviews)
        
        let entries = [ratingEntry, phoneEntry, distanceEntry, closeTimeEntry, priceEntry, transactionsEntry, categoryEntry]
        for entry in entries {
            let view = createBackgroundView()
            view.addSubview(entry)
            entry.topAnchor.constraint(equalTo: view.topAnchor, constant: 4.0).isActive = true
            entry.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4.0).isActive = true
            entry.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0).isActive = true
            entry.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
            mainStackView.addArrangedSubview(view)
        }
        
        if place.transactions.isEmpty {
            transactionsEntry.removeFromSuperview()
        }
        
        if place.priceRange == 0 {
            priceEntry.removeFromSuperview()
        }
        
        if place.distance == 0.0 {
            distanceEntry.removeFromSuperview()
        }
        
        if place.phoneNumber.isEmpty {
            phoneEntry.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 12.0, height: 12.0))
        let mask = CAShapeLayer()
        mask.path = bezierPath.cgPath
        self.layer.mask = mask
    }
    
    private func createBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.flatDarkTeal
        view.clipsToBounds = true
        return view
    }
    
    private func createEntryStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.backgroundColor = UIColor.flatLightTeal
        stackView.axis = .horizontal
        return stackView
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.baselineAdjustment = .alignCenters
        label.textColor = UIColor.white
        label.text = text
        label.numberOfLines = 1
        return label
    }
}
