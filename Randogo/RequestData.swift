//
//  RequestData.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/18/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import CoreLocation

struct RequestData {
    var location: CLLocationCoordinate2D!
    var categories: [String]!
    var isLocationFromGPS = false
    
    var isReady: Bool {
        return location != nil && categories != nil
    }
}
