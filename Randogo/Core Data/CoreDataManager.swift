//
//  CoreDataManager.swift
//  Randogo
//
//  Created by Sergiy Momot on 7/27/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private var persistentContainer: NSPersistentContainer
    private let historyExpireDays = 7
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "PlacesDataModel")
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        let today = Date()
        let historyPlaces = (try? managedContext.fetch(HistoryPlace.fetchRequest())) ?? []
        for place in historyPlaces {
            if let difference = Calendar.current.dateComponents([.day], from: place.viewedDate as Date, to: today).day, difference >= historyExpireDays {
                managedContext.delete(place)
            }
        }
        
        saveContext()
    }
    
    private var managedContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    func saveContext() {
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addPlaceToFavorites(_ place: PlaceInfo) {
        let managedPlace = FavoritePlace(entity: FavoritePlace.entity(), insertInto: managedContext)
        managedPlace.placeID = place.id
        managedPlace.name = place.name
        managedPlace.categories = place.categories as [NSString]
        saveContext()
    }
    
    func isPlaceInFavorites(placeID: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoritePlace> = FavoritePlace.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeID == %@", placeID)
        return ((try? managedContext.count(for: fetchRequest)) ?? 0) > 0
    }
    
    func addPlaceToHistory(_ place: PlaceInfo) {
        let managedPlace = HistoryPlace(entity: HistoryPlace.entity(), insertInto: managedContext)
        managedPlace.placeID = place.id
        managedPlace.name = place.name
        managedPlace.categories = place.categories as [NSString]
        managedPlace.viewedDate = NSDate()
        saveContext()
    }
    
    func deletePlaceFromFavorites(_ place: PlaceInfo) {
        let fetchRequest: NSFetchRequest<FavoritePlace> = FavoritePlace.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeID == %@", place.id)
        
        if let placeToDelete = (try? managedContext.fetch(fetchRequest))?.first {
            managedContext.delete(placeToDelete)
            saveContext()
        }
    }
    
    func deletePlaceFromFavorites(_ place: FavoritePlace) {
        managedContext.delete(place)
        saveContext()
    }
    
    func deletePlaceFromHistory(_ place: HistoryPlace) {
        managedContext.delete(place)
        saveContext()
    }
    
    func getPlacesInHistory() -> [HistoryPlace] {
        return (try? managedContext.fetch(HistoryPlace.fetchRequest())) ?? []
    }
    
    func getPlacesInFavorites() -> [FavoritePlace] {
        return (try? managedContext.fetch(FavoritePlace.fetchRequest())) ?? []
    }
}

