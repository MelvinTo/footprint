//
//  NewPhoto.swift
//  
//
//  Created by Melvin Tu on 5/5/15.
//
//

import Foundation
import CoreData

@objc(NewPhoto)

public class NewPhoto: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var identifier: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var source: String
    @NSManaged var timestamp: NSDate
    @NSManaged var thumb: NSData

}
