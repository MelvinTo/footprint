    //
//  PhotoUtil.swift
//  Footprint
//
//  Created by Melvin Tu on 4/3/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class PhotoStore {
    
    public var context : NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.cdh.managedObjectContext!
    }

    
    public init() {
    }
    
    public func resetPhotos() -> Bool {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Photo")
        var result = context.executeFetchRequest(fReq, error:&error)
        if let photos = result as? [Photo] {
            for photo in photos {
                context.deleteObject(photo)
            }
            
            if context.hasChanges && !context.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                return false
            } else {
                NSLog("\(photos.count) photo(s) have been deleted from Core Data")
            }
        }
        return true
    }
    
    public func countPhotos() -> Int {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Photo")
        
        var result = context.executeFetchRequest(fReq, error:&error)

        if let photos = result as? [Photo] {
            NSLog("\(photos.count)")
            return photos.count
        } else {
            NSLog("Failed to get photos")
            return -1
        }

    }
    
    public func countPaths() -> Int {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Path")
        
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let pathes = result as? [Path] {
            NSLog("\(pathes.count)")
            return pathes.count
        } else {
            NSLog("Failed to get pathes")
            return -1
        }
    }
    
    public func isPhotoExists(photo: PhotoMetadata) -> Bool {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Photo")
        
        fReq.predicate = NSPredicate(format:"url == \"\(photo.url)\"")
        
        var result = context.executeFetchRequest(fReq, error:&error)

        if let photos = result as? [Photo] {
            if(photos.count > 0) {
                return true
            } else {
                return false
            }
        } else {
            NSLog("Failed to get photos")
            return false
        }
    }
    
    // no duplication check for batch stores..
    public func storePhoto(photos: [PhotoMetadata]) -> Bool {
        for photo in photos {
            var newItem: Photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
            newItem.copyFrom(photo)
            NSLog("Inserted New Photo for \(newItem.url) ")
        }
        
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            return false
        }
        
        return true

    }
    
    public func storePhoto(photo: PhotoMetadata) -> Bool {
        
        if isPhotoExists(photo) {
            NSLog("Photo \(photo.url) is already added into Core Data")
            return false
        }
        
        var newItem: Photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
        
        newItem.copyFrom(photo)
        
        
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            return false
        }
        
        return true
    }
    
    public func storeFootprint(fp: Footprint) -> Bool {
        // TODO
        var path: Path = NSEntityDescription.insertNewObjectForEntityForName("Path", inManagedObjectContext: context) as! Path
        path.copyFrom(fp)
        
        for metadata in fp.photos {
            var photo: Photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
            photo.copyFrom(metadata)
            photo.path = path
        }
        
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            return false
        }
        
        return true
    }
    
}