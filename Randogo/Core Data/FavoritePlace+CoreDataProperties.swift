//
//  FavoritePlace+CoreDataProperties.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/27/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//
//

import Foundation
import CoreData

extension FavoritePlace {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePlace> {
        return NSFetchRequest<FavoritePlace>(entityName: "FavoritePlace")
    }

    @NSManaged public var placeID: String
    @NSManaged public var name: String
    @NSManaged public var categories: [NSString]

}
