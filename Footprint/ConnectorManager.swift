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
    
    public init() {
        
    }
    
    func getAvailableConnectors() -> [Connector] {
        return [PhotosConnector()]
    }
    
    func syncWithConnectors() {
        
    }
    
    public func storeNewPhotos(connector: Connector, context: NSManagedObjectContext) {
        var photoDBManager = NewPhotoDBManager(context: context)
        connector.loadPhotos() { photo in
            if !photoDBManager.photoExists(photo.identifier) {
                let result = photoDBManager.insertPhoto(photo)
                if result {
                    NSLog("Photo \(photo.identifier) is added successfully")
                } else {
                    NSLog("Failed to add photo \(photo.identifier)")
                }
            }
        }
    }
}