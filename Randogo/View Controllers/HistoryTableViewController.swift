//
//  HistoryTableViewController.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/28/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import PopupDialog

class HistoryViewController: BubbleViewController, UITableViewDataSource {
    var places: [(dayDate: Date, places: [HistoryPlace])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerLabel.text = "History"
        self.clearAllButton.addTarget(self, action: #selector(clearAllHistory), for: .touchUpInside)
        
        processPlaces(CoreDataManager.shared.getPlacesInHistory())
        
        self.tableView.dataSource = self
    }
    
    private func processPlaces(_ places: [HistoryPlace]) {
        self.places.removeAll()
        
        var filteredPlaces: [Date: [HistoryPlace]] = [:]
        for place in places {
            let components = Calendar.current.dateComponents([.day, .month, .year], from: place.viewedDate as Date)
            let date = Calendar.current.date(from: components)!
            
            if filteredPlaces[date] != nil {
                filteredPlaces[date]!.append(place)
            } else {
                filteredPlaces.updateValue([place], forKey: date)
            }
        }
        
        for (date, values) in filteredPlaces {
            self.places.append((dayDate: date, places: values))
        }
        
        self.places.sort(by: { $0.dayDate > $1.dayDate })
        for (index, place) in self.places.enumerated() {
            self.places[index].places = place.places.sorted(by: { $0.viewedDate as Date > $1.viewedDate as Date })
        }
    }
    
    override func updatePlacesFor(_ text: String) {
        super.updatePlacesFor(text)
        
        processPlaces(CoreDataManager.shared.getPlacesInHistory().filter {
            $0.name.lowercased().hasPrefix(text.lowercased()) || $0.name.lowercased().contains(text.lowercased())
        })
    }
    
    @objc private func clearAllHistory() {
        let alert = createAlert(withTitle: "Clear history", message: "Are you sure you want to delete all history records?") {
            for section in self.places {
                for place in section.places {
                    CoreDataManager.shared.deletePlaceFromHistory(place)
                }
            }
            
            self.places.removeAll()
            self.tableView.reloadData()
        }
        
        present(alert, animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if !self.isSearching {
            self.clearAllButton.isHidden = self.places.isEmpty
        }
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places[section].places.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCellForRowAt(indexPath: indexPath)
        
        cell.textLabel?.text = self.places[indexPath.section].places[indexPath.row].name
        
        cell.detailTextLabel?.text = String((self.places[indexPath.section].places[indexPath.row].categories as [String]).reduce("", { $0 + ", " + $1 }).characters.dropFirst(2))
        
        if cell.accessoryView as? UILabel == nil {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            label.numberOfLines = 1
            label.textAlignment = .right
            label.textColor = UIColor(white: 0.8, alpha: 1.0)
            label.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
            cell.accessoryView = label
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        (cell.accessoryView as? UILabel)?.text = dateFormatter.string(from: self.places[indexPath.section].places[indexPath.row].viewedDate as Date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: HistoryTableViewHeader.self)) as? HistoryTableViewHeader
        
        if header == nil {
            header = HistoryTableViewHeader(reuseIdentifier: String(describing: HistoryTableViewHeader.self))
            header!.clearButton.addTarget(self, action: #selector(clearDayHistory(_:)), for: .touchUpInside)
        }
        
        let dayDate = self.places[section].dayDate
        let today = Date()
        
        var headerText: String
        if Calendar.current.compare(dayDate, to: today, toGranularity: .day) == .orderedSame {
            headerText = "Today"
        } else if Calendar.current.compare(Calendar.current.date(byAdding: .day, value: 1, to: dayDate)!, to: today, toGranularity: .day) == .orderedSame {
            headerText = "Yesterday"
        } else {
            let shouldDisplayYear = Calendar.current.compare(dayDate, to: today, toGranularity: .year) != .orderedSame
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d\(shouldDisplayYear ? ", y" : "")"
            headerText = formatter.string(from: dayDate)
        }
        
        header!.dayLabel.text = headerText
        header!.clearButton.tag = section
        return header
    }
    
    @objc private func clearDayHistory(_ button: UIButton) {
        let alert = createAlert(withTitle: "Clear history", message: "Are you sure you want to delete all history records of selected day?") {
            self.tableView.beginUpdates()
            for place in self.places[button.tag].places {
                CoreDataManager.shared.deletePlaceFromHistory(place)
            }
            self.places.remove(at: button.tag)
            self.tableView.deleteSections([button.tag], with: .automatic)
            self.tableView.endUpdates()
        }

        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            CoreDataManager.shared.deletePlaceFromHistory(self.places[indexPath.section].places[indexPath.row])
            if self.places[indexPath.section].places.count > 1 {
                self.places[indexPath.section].places.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                self.places.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.loadDataForPlaceID(self.places[indexPath.section].places[indexPath.row].placeID)
    }
}
