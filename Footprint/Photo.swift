//
//  HatuPhoto.swift
//  Footprint
//
//  Created by Melvin Tu on 4/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var url: String
    @NSManaged var path: Path

    func copyFrom(metadata: PhotoMetadata) {
        self.latitude = metadata.latitude
        self.longitude = metadata.longitude
        self.timestamp = metadata.timestamp
        self.url = metadata.url
    }
    
    func toMetadata() -> PhotoMetadata {
        var metadata = PhotoMetadata()
        metadata.latitude = self.latitude
        metadata.longitude = self.longitude
        metadata.timestamp = self.timestamp
        metadata.url = self.url
        return metadata
    }
}
