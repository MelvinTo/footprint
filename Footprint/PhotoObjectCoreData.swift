//
//  PhotoObjectCoreData.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/7/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData

public extension PhotoObject {
    public func toNewPhoto(context: NSManagedObjectContext) -> NewPhoto {
        var photo = NSEntityDescription.insertNewObjectForEntityForName("NewPhoto", inManagedObjectContext: context) as! NewPhoto
        photo.name = self.name
        photo.identifier = self.identifier
        photo.latitude = self.latitude
        photo.longitude = self.longitude
        photo.source = self.source
        photo.timestamp = self.timestamp
        
        if let t = self.thumb {
            photo.thumb = t
        }
        
        return photo
    }
}

public class NewPhotoDBManager {
    var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func numberOfNewPhotos() -> Int {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "NewPhoto")
        
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let photos = result as? [NewPhoto] {
            return photos.count
        } else {
            NSLog("Failed to get number of photos")
            return -1
        }
    }
    
    public func photoExists(identifier: String) -> Bool {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "NewPhoto")
        
        fReq.predicate = NSPredicate(format:"identifier == \"\(identifier)\"")
        
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let photos = result as? [NewPhoto] {
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
    
    public func insertPhoto(photo: PhotoObject) -> Bool {
        var object = photo.toNewPhoto(self.context)
        
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            return false
        }
        
        return true
    }
}