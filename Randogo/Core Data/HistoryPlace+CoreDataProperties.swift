//
//  HistoryPlace+CoreDataProperties.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/27/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//
//

import CoreData

extension HistoryPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryPlace> {
        return NSFetchRequest<HistoryPlace>(entityName: "HistoryPlace")
    }

    @NSManaged public var placeID: String
    @NSManaged public var name: String
    @NSManaged public var categories: [NSString]
    @NSManaged public var viewedDate: NSDate

}
