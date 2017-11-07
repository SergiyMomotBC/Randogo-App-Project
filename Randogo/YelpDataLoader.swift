//
//  YelpDataLoader.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/4/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Alamofire
import SwiftyJSON
import CoreLocation
import PINCache

enum DataLoaderError: Error {
    case noInternetConnection
    case internalError
}

struct PlaceMetadata {
    let id: String
    let priceRange: Int
    let distance: Double
    let rating: Double
}

class YelpDataLoader {
    private static let placesSearchEndpoint = "https://api.yelp.com/v3/businesses/search"
    private static let placeInfoEndpoint = "https://api.yelp.com/v3/businesses/"
    
    private static let placesSearchResultsLimit = 50
    private static let placesSearchOnlyOpenNow = true
    private static let placesSearchSortByField = "rating"
    
    static let shared = YelpDataLoader()
    
    func loadPlaces(forRequest requestData: RequestData, filterOptions: FilterOptions, completion: (([PlaceMetadata]?, DataLoaderError?) -> Void)?) {
        AuthorizationResolver.retrieveAccessToken { accessToken in
            let parameters: Parameters = ["latitude": requestData.location.latitude,
                                          "longitude": requestData.location.longitude,
                                          "categories": String(requestData.categories.reduce("", { $0 + "," + $1 }).characters.dropFirst()),
                                          "sort_by": YelpDataLoader.placesSearchSortByField,
                                          "open_now": YelpDataLoader.placesSearchOnlyOpenNow,
                                          "limit": YelpDataLoader.placesSearchResultsLimit,
                                          "radius": filterOptions.distance * 1600.0]
            
            
            Alamofire.request(YelpDataLoader.placesSearchEndpoint, parameters: parameters, headers: ["Authorization": "Bearer " + accessToken]).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var retrievedPlaces: [PlaceMetadata] = []
                    
                    for place in json["businesses"].arrayValue {
                        retrievedPlaces.append(PlaceMetadata(id: place["id"].stringValue, priceRange: place["price"].stringValue.characters.count, distance: place["distance"].doubleValue, rating: place["rating"].doubleValue))
                    }
                    
                    retrievedPlaces = retrievedPlaces.filter {
                        return $0.priceRange > 0 ? filterOptions.prices.contains($0.priceRange) : true
                    }
                    
                    
                    completion?(self.randomize(retrievedPlaces), nil)
                    
                case .failure(let error):
                    print(error)
                    if let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet {
                        completion?(nil, DataLoaderError.noInternetConnection)
                    } else {
                        completion?(nil, DataLoaderError.internalError)
                    }
                }
            }
        }
    }
    
    func loadPlaceInfo(forPlace place: PlaceMetadata, completion: @escaping ((PlaceInfo?) -> Void), allowRetry: Bool = true) {
        if let placeInfo = PINCache.shared().object(forKey: place.id) as? PlaceInfo {
            completion(placeInfo)
            return
        }
        
        AuthorizationResolver.retrieveAccessToken { accessToken in
            Alamofire.request(YelpDataLoader.placeInfoEndpoint + place.id, headers: ["Authorization": "Bearer " + accessToken]).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    var json = JSON(value)
                    json["distance"].doubleValue = place.distance
                    
                    //until Yelp API "null coordinates" issue is not solved
                    if json["coordinates"]["latitude"].double == nil {
                        let addressParts = json["location"]["display_address"]
                        CLGeocoder().geocodeAddressString(addressParts[0].stringValue + ", " + addressParts[1].stringValue) { placemark, error in
                            if let coordinate = placemark?.first?.location?.coordinate {
                                json["coordinates"]["latitude"].double = coordinate.latitude
                                json["coordinates"]["longitude"].double = coordinate.longitude
                                let placeInfo = PlaceInfo(json: json)
                                PINCache.shared().setObject(placeInfo, forKey: place.id)
                                completion(placeInfo)
                            }
                        }
                    } else {
                        let placeInfo = PlaceInfo(json: json)
                        PINCache.shared().setObject(placeInfo, forKey: place.id)
                        completion(placeInfo)
                    }
                    
                case .failure(let error):
                    print(error)
                    
                    if allowRetry && (response.response?.statusCode ?? 0) == 504 {
                        self.loadPlaceInfo(forPlace: place, completion: completion, allowRetry: false)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    private func randomize(_ retrievedPlaces: [PlaceMetadata]) -> [PlaceMetadata] {
        guard !retrievedPlaces.isEmpty else { return [] }
        
        var filteredData = retrievedPlaces.sorted(by: { $0.rating > $1.rating }).prefix(12)
        
        for _ in 1...500 {
            let index1 = Int(arc4random_uniform(UInt32(filteredData.count)))
            let index2 = Int(arc4random_uniform(UInt32(filteredData.count)))
            
            let temp = filteredData[index1]
            filteredData[index1] = filteredData[index2]
            filteredData[index2] = temp
        }
        
        return [PlaceMetadata](filteredData)
    }
}
