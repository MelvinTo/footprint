//
//  SyncStatusDB.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/30/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData

public class SyncStatusDB {
    var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // check if any connector has pending syncing folders/identifiers
    func hasPendingItems(source: String) -> Bool {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "SyncStatus")
        
        fReq.predicate = NSPredicate(format:"source == \"\(source)\"")
        
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let items = result as? [SyncStatus] {
            if(items.count > 0) {
                return true
            } else {
                return false
            }
        } else {
            NSLog("Failed to get sync status items")
            return false
        }
    }
    
    func hasItem(identifier: String, source: String) -> SyncStatus? {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "SyncStatus")
        
        fReq.predicate = NSPredicate(format:"source == \"\(source)\" and identifier ==\"\(identifier)\"")
        
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let items = result as? [SyncStatus] {
            if(items.count > 0) {
                return items[0]
            } else {
                return nil
            }
        } else {
            NSLog("Failed to get sync status items")
            return nil
        }
    }
    
    public func addSyncItem(identifier: String, source: String) {
        let exists = self.hasItem(identifier, source: source)

        if exists == nil {
            var item = (NSEntityDescription
                .insertNewObjectForEntityForName(   "SyncStatus",
                    inManagedObjectContext: context)
                as! SyncStatus)
            item.identifier = identifier
            item.source = source
            item.createdDate = NSDate()
            
            var error: NSError? = nil
            if context.hasChanges && !context.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                return
            }
        }
        
        return
    }
    
    func deleteSyncItem(identifier: String, source: String) {
        if let exists = self.hasItem(identifier, source: source) {
            context.deleteObject(exists)
            
            var error: NSError? = nil
            if context.hasChanges && !context.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                return
            }
        }
        
        return

    }
    
    func getFetchedResultsController(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController {
        
        let entity = NSEntityDescription.entityForName("Path", inManagedObjectContext: self.context)
        let sort = NSSortDescriptor(key: "timestamp", ascending: true)
        let req = NSFetchRequest()
        req.entity = entity
        req.sortDescriptors = [sort]
        
        /* NSFetchedResultsController initialization
        a `nil` `sectionNameKeyPath` generates a single section */
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = delegate
        
        // perform initial model fetch
        var e: NSError?
        if !aFetchedResultsController.performFetch(&e) {
            println("fetch error: \(e!.localizedDescription)")
            abort();
        }
        
        return aFetchedResultsController
    }
}