//
//  DropboxFolderHash.swift
//  
//
//  Created by Melvin Tu on 5/15/15.
//
//

import Foundation
import CoreData

class DropboxFolderHash: NSManagedObject {

    @NSManaged var folderPath: String
    @NSManaged var folderHash: String

}
