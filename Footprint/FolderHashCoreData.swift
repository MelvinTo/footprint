//
//  FolderHashCoreData.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/15/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData

class FolderHashCoreData {
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadAllFolderHashes() -> [DropboxFolderHash]? {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "DropboxFolderHash")
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let photos = result as? [DropboxFolderHash] {
            return photos
        } else {
            NSLog("Failed to get photos")
            return nil
        }
    }
    
    func createOrUpdateFolderHash(path: String, hash: String) -> (hash: DropboxFolderHash?, NSError?) {
        var folderHash = self.pathExists(path)
        
        if folderHash != nil {
            folderHash?.folderHash = hash
        } else {
            folderHash = (NSEntityDescription
                .insertNewObjectForEntityForName(   "DropboxFolderHash",
                                                    inManagedObjectContext: context)
                as! DropboxFolderHash)
            folderHash?.folderPath = path
            folderHash?.folderHash = hash
        }
        
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            return (nil, error)
        }
        
        return (folderHash, nil)
    }
    
    func hashExists(path: String, hash: String) -> Bool {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "DropboxFolderHash")
        
        fReq.predicate = NSPredicate(format:"folderHash == \"\(hash)\" and folderPath ==\"\(path)\"")
        
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let hashes = result as? [DropboxFolderHash] {
            if(hashes.count > 0) {
                return true
            } else {
                return false
            }
        } else {
            NSLog("Failed to get photos")
            return false
        }
    }
    
    func pathExists(path: String) -> DropboxFolderHash? {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "DropboxFolderHash")
        
        fReq.predicate = NSPredicate(format:"folderPath ==\"\(path)\"")
        
        var result = context.executeFetchRequest(fReq, error:&error)
        
        if let hashes = result as? [DropboxFolderHash] {
            if(hashes.count > 0) {
                return hashes[0]
            } else {
                return nil
            }
        } else {
            NSLog("Failed to get photos")
            return nil
        }

    }

}