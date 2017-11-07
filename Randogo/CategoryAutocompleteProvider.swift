//
//  CategoryAutocompleteProvider.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/1/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import MapKit

class CategoryAutocompleteProvider: NSObject, SuggestionsProvider {
    func getSuggestions(for text: String, completion: @escaping (([String]) -> Void)) {
        completion(CategoriesDataSource.allSubcategories.keys.filter {
            let title = $0.lowercased()
            let query = text.lowercased()
            return title.hasPrefix(query) || title.contains(query)
        })
    }
}

class AddressAutocompletionProvider: NSObject, SuggestionsProvider, MKLocalSearchCompleterDelegate {
    private var completion: (([String]) -> Void)!
    private let autocompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        autocompleter.delegate = self
        autocompleter.filterType = .locationsOnly
    }
    
    func getSuggestions(for text: String, completion: @escaping (([String]) -> Void)) {
        self.completion = completion
        autocompleter.queryFragment = text
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.map { $0.title + ($0.subtitle.isEmpty ? "" : ", " + $0.subtitle) }
        completion(results)
    }
}
