//
//  PhotoLoader.swift
//  Footprint
//
//  Created by Melvin Tu on 4/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import AssetsLibrary
import ImageIO

protocol PhotoLoaderDelegate {
    func loadPhotoComplete(loader: PhotoLoader)
}

class PhotoLoader {
    var store: PhotoStore = PhotoStore()
    var photos: [PhotoMetadata] = []
    var queue = dispatch_queue_create("me.hatu.loadphoto", DISPATCH_QUEUE_SERIAL)
    var delegate: PhotoLoaderDelegate? = nil
    
    func parseAsset(asset: ALAsset) {
        let url = asset.valueForProperty(ALAssetPropertyAssetURL) as! NSURL
        let metadata = asset.defaultRepresentation().metadata()
        let gps_optional = metadata["{GPS}"] as! [NSObject : AnyObject]?
        if let gps = gps_optional {
            var photo = PhotoMetadata()
            photo.latitude = gps["Latitude"]! as! Double // 30.226155
            photo.longitude = gps["Longitude"]! as! Double // 120.126113833333
            
            let datestamp = gps["DateStamp"]! as! String // 2015:06:19
            let timestamp = gps["TimeStamp"]!as! String // 18:44:28
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            photo.timestamp = dateFormatter.dateFromString("\(datestamp) \(timestamp)")!
            
            photo.url = "\(url)"
            
            dispatch_async(queue, { // concurrently check and add photo in the queue
                if !self.store.isPhotoExists(photo) {
                    self.photos.append(photo)
                }
//                NSLog("queued")
            })
        }
    }
    
    func loadPhotos() { // load photos from iPhone photo libreary
        NSLog("Loading photos")
        
        var assetLib = ALAssetsLibrary()
        
        assetLib.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: {(group : ALAssetsGroup!, stop : UnsafeMutablePointer<ObjCBool>) in
            if let photo_folder = group {
                photo_folder.enumerateAssetsUsingBlock({(asset: ALAsset!, index: Int, stop2: UnsafeMutablePointer<ObjCBool>) in
                    if let photo = asset {
                        self.parseAsset(photo)
                    }
                })
            } else {
                // enumeration complete
                // phone load is done, then store all new available metadatas into core data

                dispatch_async(self.queue, {
                    NSLog("Number of new photos: \(self.photos.count)")
                    if self.store.storePhoto(self.photos) {
                        self.photos = []
                    }
                    
                    // delegate callback
                    if let d = self.delegate {
                        d.loadPhotoComplete(self)
                    }
                    NSLog("Loading photos is finished")
                })
            }
        }, failureBlock:  { (error:NSError?) in
            println("xxx")
        })
    }
}