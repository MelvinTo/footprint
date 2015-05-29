//
//  SyncStatus.swift
//  
//
//  Created by Melvin Tu on 5/30/15.
//
//

import Foundation
import CoreData

@objc(SyncStatus)

class SyncStatus: NSManagedObject {

    @NSManaged var source: String
    @NSManaged var identifier: String
    @NSManaged var createdDate: NSDate

}
