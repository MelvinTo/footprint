//
//  ConnectorManager.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData

public class ConnectorManager {
    static var sharedConnectorManager: ConnectorManager? = nil

    public class func getSharedConnectorManager() -> ConnectorManager {
        
        if let s = sharedConnectorManager {
            return s
        } else {
            sharedConnectorManager = ConnectorManager()
            return sharedConnectorManager!
        }
    }
    
    var connectors: [String : Connector] = [:]
    
    private init() {
        // PERFROMANCE IMPROVEMENT HERE
        let photosConnector = PhotosConnector()
        connectors[photosConnector.name] = photosConnector
        
        let dropboxConnector = DropboxConnector.getSharedDropboxConnector()
        connectors[dropboxConnector.name] = dropboxConnector
    }
    
    func getAvailableConnectors() -> [Connector] {
        return [PhotosConnector()]
    }
    
    func findConnectorManager(photo : PhotoObject) -> Connector? {
        let source = photo.source
        return findConnectorManager(source)
    }
    
    func findConnectorManager(source: String) -> Connector? {
        let c = connectors[source]
        if let cc = c {
            return cc
        } else {
            return nil
        }
    }
    
    func syncWithConnectors() {
        
    }
    
    func flushPhotos(photos: [PhotoObject], context: NSManagedObjectContext) -> Bool {
        for var index = 0; index < photos.count; ++index {
            photos[index].toNewPhoto(context)
            //                NSLog("photo format transformmed: \(photosToBeAdded[index].identifier)")
        }
        
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            return false
        } else {
            return true
        }
    }
    
    public func storeNewPhotos(connector: Connector, context: NSManagedObjectContext, progress: (Float -> Void)?, completed: (Void -> Void)? ) {
        var photoDBManager = NewPhotoDBManager(context: context)
        let count = connector.numberOfPhotos()
        var photosToBeAdded : [PhotoObject] = []
        
        connector.loadPhotos({ photo, index in
            if !photoDBManager.photoExists(photo.identifier) {
                photosToBeAdded.append(photo)
//                NSLog("Photo \(photo.identifier) is added")
                
                if photosToBeAdded.count >= 10 {
                    if self.flushPhotos(photosToBeAdded, context: context) {
                        photosToBeAdded.removeAll(keepCapacity: true)
                    }
                }
            
//                if let p = progress {
//                    if let i = index {
//                        dispatch_async(dispatch_get_main_queue()) {
//                            p(Float(i)/Float(count)/2.0)
//                        }
//                    }
//                }
            }
        }, completed: {
            
            for var index = 0; index < photosToBeAdded.count; ++index {
                photosToBeAdded[index].toNewPhoto(context)
//                NSLog("photo format transformmed: \(photosToBeAdded[index].identifier)")
                if let p = progress {
                    dispatch_async(dispatch_get_main_queue()) {
                        p(0.5 + Float(index)/Float(photosToBeAdded.count)/2.0)
                    }
                }
            }
            
            var error: NSError? = nil
            if context.hasChanges && !context.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
            }
            completed!()
        })
    }
}