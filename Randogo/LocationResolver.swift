//
//  LocationResolver.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/3/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import CoreLocation

class LocationResolver: NSObject {
    fileprivate let locationManager = CLLocationManager()
    fileprivate var completion: ((CLLocation?) -> Void)!
    fileprivate let maxAttempts = 10
    fileprivate var allowedAttempts: Int
    fileprivate let desiredAccuracy = 100.0
    
    override init() {
        self.allowedAttempts = maxAttempts
        
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func retrieveLocation(completion: @escaping ((CLLocation?) -> Void)) {
        self.completion = completion
        locationManager.startUpdatingLocation()
    }
    
    func coordinates(for address: String, completion: @escaping ((CLLocationCoordinate2D?) -> Void)) {
        let decoder = CLGeocoder()
        decoder.geocodeAddressString(address) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    
    func address(for coordinates: CLLocationCoordinate2D, completion: @escaping ((String?) -> Void)) {
        let decoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        decoder.reverseGeocodeLocation(location) { placemarks, error in
            if let address = placemarks?.first {
                var addressText = "Unknown location address"
                if let name = address.name {
                    addressText = name
                    addressText += address.subLocality != nil ? ", " + address.subLocality! : (address.locality != nil ? ", " + address.locality! : "")
                    addressText += address.administrativeArea != nil ? ", " + address.administrativeArea! : ""
                }
            } else {
                completion(nil)
            }
        }
    }
}

extension LocationResolver: CLLocationManagerDelegate {
    private func didFinishLocationRetrieval(location: CLLocation?) {
        locationManager.stopUpdatingLocation()
        allowedAttempts = maxAttempts
        completion(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, location.horizontalAccuracy <= desiredAccuracy {
            didFinishLocationRetrieval(location: location)
        } else {
            allowedAttempts -= 1
            if allowedAttempts == 0 {
                didFinishLocationRetrieval(location: nil)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = error as! CLError
        allowedAttempts -= 1
        
        if locationError.code == .denied || allowedAttempts == 0 {
            didFinishLocationRetrieval(location: nil)
        }
    }
}
