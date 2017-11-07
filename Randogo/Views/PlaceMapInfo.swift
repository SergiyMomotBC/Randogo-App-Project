//
//  PlaceMapInfo.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/13/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics

class PlaceMapInfo: UIView {
    let regionRadius = 200.0
    
    let mapView: MKMapView = {
        let map = MKMapView(frame: .zero)
        map.translatesAutoresizingMaskIntoConstraints = false
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isPitchEnabled = false
        map.isRotateEnabled = false
        map.isUserInteractionEnabled = false
        return map
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        label.textColor = UIColor.flatDarkTeal
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        
        self.addSubview(mapView)
        mapView.clipToSuperview()
        
        self.addSubview(addressLabel)
        addressLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0).isActive = true
        addressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        addressLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0).isActive = true
        addressLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5, constant: -16.0).isActive = true
        
        func createLine() -> UIView {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.flatDarkTeal
            return view
        }
        
        let topLine = createLine()
        self.addSubview(topLine)
        topLine.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        topLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        topLine.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        let bottomLine = createLine()
        self.addSubview(bottomLine)
        bottomLine.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(for place: PlaceInfo) {
        addressLabel.text = place.address
        
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(place.location, regionRadius * 2, regionRadius * 2), animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.location
        mapView.addAnnotation(annotation)
        
        var center = place.location
        center.longitude -= mapView.region.span.longitudeDelta * 0.25
        mapView.setCenter(center, animated: false)
        
        let mask = CAGradientLayer()
        mask.frame = mapView.bounds
        mask.colors = [UIColor(white: 0.0, alpha: 0.1).cgColor, UIColor(white: 0.0, alpha: 1.0).cgColor]
        mask.startPoint = CGPoint(x: 0.1, y: 0.5)
        mask.endPoint = CGPoint(x: 1.0, y: 0.5)
        mapView.layer.mask = mask
    }
}
