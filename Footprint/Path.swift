//
//  Path.swift
//  Footprint
//
//  Created by Melvin Tu on 4/6/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData

@objc(Path)
class Path: NSManagedObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var name: String?
    @NSManaged var location: String?
    @NSManaged var photos: NSSet

    func copyFrom(fp : Footprint) {
        self.name = fp.name
        self.location = fp.location
        self.timestamp = fp.timestamp
    }
    
    func toFootprint() -> Footprint? {
        if let name2 = self.name {
            var fp = Footprint(name: name2)
            if let location2 = self.location {
                fp.location = location2
            }
            
            fp.timestamp = self.timestamp
            for photo in photos {
                let p = photo as! Photo
                var metadata = p.toMetadata()
                fp.photos.append(metadata)
            }
            return fp
        }
        
        return nil
    }
}
