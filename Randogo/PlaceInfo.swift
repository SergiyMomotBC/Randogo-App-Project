//
//  PlaceInfo.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/4/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import CoreLocation
import SwiftyJSON

class CloseTime: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(day, forKey: "day")
        aCoder.encode(closeTime, forKey: "closeTime")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.day = aDecoder.decodeInteger(forKey: "day")
        self.closeTime = aDecoder.decodeInteger(forKey: "closeTime")
    }
    
    let day: Int
    let closeTime: Int
    
    init(day: Int, closeTime: Int) {
        self.day = day
        self.closeTime = closeTime
    }
}

class PlaceInfo: NSObject, NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(reviewCount, forKey: "reviewCount")
        aCoder.encode(priceRange, forKey: "priceRange")
        aCoder.encode(yelpURL, forKey: "yelpURL")
        aCoder.encode(location.latitude, forKey: "latitude")
        aCoder.encode(location.longitude, forKey: "longitude")
        aCoder.encode(imageURLs, forKey: "imageURLs")
        aCoder.encode(phoneNumber, forKey: "phoneNumber")
        aCoder.encode(displayPhoneNumber, forKey: "displayPhoneNumber")
        aCoder.encode(transactions, forKey: "transactions")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(closeTimes, forKey: "closeTimes")
        aCoder.encode(distance, forKey: "distance")
        aCoder.encode(categories, forKey: "categories")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.rating = aDecoder.decodeDouble(forKey: "rating")
        self.reviewCount = aDecoder.decodeInteger(forKey: "reviewCount")
        self.priceRange = aDecoder.decodeInteger(forKey: "priceRange")
        self.yelpURL = aDecoder.decodeObject(forKey: "yelpURL") as! String
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.imageURLs = aDecoder.decodeObject(forKey: "imageURLs") as! [String]
        self.phoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as! String
        self.displayPhoneNumber = aDecoder.decodeObject(forKey: "displayPhoneNumber") as! String
        self.transactions = aDecoder.decodeObject(forKey: "transactions") as! [String]
        self.address = aDecoder.decodeObject(forKey: "address") as! String
        self.closeTimes = aDecoder.decodeObject(forKey: "closeTimes") as! [CloseTime]
        self.distance = aDecoder.decodeDouble(forKey: "distance")
        self.categories = aDecoder.decodeObject(forKey: "categories") as! [String]
    }
    
    let id: String
    let name: String
    let rating: Double
    let reviewCount: Int
    let priceRange: Int
    let yelpURL: String
    var location: CLLocationCoordinate2D
    let imageURLs: [String]
    let phoneNumber: String
    let displayPhoneNumber: String
    let transactions: [String]
    let address: String
    private let closeTimes: [CloseTime]
    let distance: Double
    let categories: [String]
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.rating = json["rating"].doubleValue
        self.reviewCount = json["review_count"].intValue
        self.priceRange = json["price"].stringValue.characters.count
        self.yelpURL = json["url"].stringValue
        self.location = CLLocationCoordinate2D(latitude: json["coordinates"]["latitude"].doubleValue, longitude: json["coordinates"]["longitude"].doubleValue)
        self.imageURLs = json["photos"].arrayValue.map { $0.stringValue }
        self.phoneNumber = json["phone"].stringValue
        self.displayPhoneNumber = json["display_phone"].stringValue
        self.transactions = json["transactions"].arrayValue.map { $0.stringValue }
        self.address = json["location"]["display_address"][0].stringValue + "\n" + json["location"]["display_address"][1].stringValue
        self.distance = json["distance"].doubleValue
        self.categories = json["categories"].arrayValue.map { $0["title"].stringValue }
        self.closeTimes = json["hours"][0]["open"].arrayValue.map {
            let time = Int($0["end"].stringValue)!
            return CloseTime(day: $0["day"].intValue, closeTime: time / 100 * 60 + time % 100)
        }
    }
    
    var todayCloseTimeText: String {
        let day = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        if let closeTime = self.closeTimes.filter({ $0.day == day }).max(by: { $0.closeTime > $1.closeTime })?.closeTime {
            var hour = closeTime >= 720 ? closeTime / 60 - 12 : closeTime / 60
            if hour == 0 {
                hour = 12
            }
            
            let minute = closeTime % 60
            return "\(hour):\(minute < 10 ? "0\(minute)" : "\(minute)") \(closeTime >= 720 ? "pm" : "am")"
        } else {
            return "No info"
        }
    }
}
