//
//  PlaceMapView.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/6/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import MapKit

class PlaceMapView: MKMapView {
    private let regionRadius = 800.0
    private var annotation: MKPointAnnotation?
    
    init(in view: UIView) {
        super.init(frame: CGRect.zero)
        self.isRotateEnabled = false
        self.isZoomEnabled = false
        self.isUserInteractionEnabled = false
        self.showsUserLocation = false
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        self.clipToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showPlace(_ place: PlaceInfo?, animated: Bool = true) {
        guard let place = place else {
            return
        }
        
        if let pin = self.annotation {
            self.removeAnnotation(pin)
            self.annotation = nil
        }
        
        let region = MKCoordinateRegionMakeWithDistance(place.location, regionRadius * 2, regionRadius * 2)
        self.setRegion(region, animated: animated)
        self.annotation = MKPointAnnotation()
        annotation!.coordinate = place.location
        annotation!.title = place.name
        annotation!.subtitle = place.address
        self.addAnnotation(self.annotation!)
        self.selectAnnotation(self.annotation!, animated: false)
    }
    
    deinit {
        self.annotation = nil
    }
}
