//
//  FavoritesTableViewController.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/27/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class FavoritesViewController: BubbleViewController, UITableViewDataSource {
    var places: [FavoritePlace] = []
    var lastSearchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerLabel.text = "Favorites"
        self.clearAllButton.addTarget(self, action: #selector(clearAllHistory), for: .touchUpInside)
        
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if searchbar.text?.isEmpty ?? true {
            self.places = CoreDataManager.shared.getPlacesInFavorites().reversed()
            self.tableView.reloadData()
        } else {
            self.updatePlacesFor(lastSearchText)
            self.tableView.reloadData()
        }
    }
    
    override func updatePlacesFor(_ text: String) {
        super.updatePlacesFor(text)
        
        self.lastSearchText = text
        self.places = CoreDataManager.shared.getPlacesInFavorites().reversed().filter {
            $0.name.lowercased().hasPrefix(text.lowercased()) || $0.name.lowercased().contains(text.lowercased())
        }
    }
    
    @objc private func clearAllHistory() {
        let alert = createAlert(withTitle: "Clear favorites", message: "Are you sure you want to delete all favorites records?") {
            for place in self.places {
                CoreDataManager.shared.deletePlaceFromFavorites(place)
            }
            
            self.places.removeAll()
            self.tableView.reloadData()
        }
        
        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isSearching {
            self.clearAllButton.isHidden = self.places.isEmpty
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCellForRowAt(indexPath: indexPath)
        
        cell.textLabel?.text = self.places[indexPath.row].name
        cell.detailTextLabel?.text = String((self.places[indexPath.row].categories as [String]).reduce("", { $0 + ", " + $1 }).characters.dropFirst(2))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            CoreDataManager.shared.deletePlaceFromFavorites(self.places[indexPath.row])
            self.places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.loadDataForPlaceID(self.places[indexPath.row].placeID)
    }
}
