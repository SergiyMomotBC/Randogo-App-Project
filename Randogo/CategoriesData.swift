//
//  CategoriesData.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/18/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import SwiftyJSON

struct CategoryInfo {
    let coverImageName: String
    let title: String
    let subtitle: String
    var subcategories: [String: String] = [:]
    var anySelectionCategories: [String]
    
    init(json: JSON) {
        self.title = json["title"].stringValue
        self.subtitle = json["subtitle"].stringValue
        self.coverImageName = json["cover_image_name"].stringValue
        
        for element in json["subcategories"].arrayValue {
            self.subcategories[element["title"].stringValue] = element["category_id"].stringValue
        }
        
        self.anySelectionCategories = json["any_selection_categories"].stringValue.components(separatedBy: ",").map { String($0) }
    }
}

class CategoriesDataSource {
    private(set) static var categoriesInfo: [CategoryInfo] = []
    private(set) static var allSubcategories: [String: String] = [:]
    
    static func load() {
        for name in ["restaurants", "entertainment", "shopping", "beautyandcare"] {
            if let categoriesDataPath = Bundle.main.path(forResource: "categories_data_" + name, ofType: "json") {
                if let categoriesData = try? Data(contentsOf: URL(fileURLWithPath: categoriesDataPath), options: .alwaysMapped) {
                    let category = CategoryInfo(json: JSON(data: categoriesData))
                    self.categoriesInfo.append(category)
                    
                    for (key, value) in category.subcategories {
                        self.allSubcategories[key] = value
                    }
                }
            }
        }
    }
            
}
