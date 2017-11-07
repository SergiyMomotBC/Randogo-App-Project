//
//  AuthorizationResolver.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/5/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Alamofire
import SwiftyJSON

class AuthorizationResolver {
    private static let clientID = "RzPd81IBxDPwaWBeNhRk8w"
    private static let clientSecretKey = "6OBeumnnO8hFQgolIlAb5esFpXqLehdx8mtdocFeP07drab77eXWec09GYNQhOj7"
    private static let accessTokenEndpoint = "https://api.yelp.com/oauth2/token"
    private static let accessTokenKey = "accessTokenKey"
    private static let accessTokenExpirationDateKey = "accessTokenExprirationDateKey"
    private static var accessToken: String? = nil
    
    static func retrieveAccessToken(completion: @escaping ((String) -> Void)) {
        if accessToken != nil {
            completion(accessToken!)
            return
        }
        
        let tokenExpiration = UserDefaults.standard.integer(forKey: accessTokenExpirationDateKey)
        let currentDate = Int(Date().timeIntervalSince1970)
        
        if tokenExpiration == 0 || tokenExpiration < currentDate {
            let parameters: Parameters = ["grant_type": "client_credentials",
                                          "client_id": clientID,
                                          "client_secret": clientSecretKey]
            
            Alamofire.request(accessTokenEndpoint, method: .post, parameters: parameters).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.accessToken = json["access_token"].stringValue
                    
                    let expiresIn = json["expires_in"].intValue
                    let expirationTime = Date(timeIntervalSinceNow: Double(expiresIn))
                    
                    UserDefaults.standard.set(self.accessToken!, forKey: self.accessTokenKey)
                    UserDefaults.standard.set(Int(expirationTime.timeIntervalSince1970), forKey: self.accessTokenExpirationDateKey)
                    
                    completion(accessToken!)
                    
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            accessToken = UserDefaults.standard.string(forKey: accessTokenKey)
            completion(accessToken!)
        }
    }
}
