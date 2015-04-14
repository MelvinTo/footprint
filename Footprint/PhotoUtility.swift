//
//  PhotoUtility.swift
//  Footprint
//
//  Created by Melvin Tu on 4/13/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

func loadImage(cell: PhotoCollectionCell, photo : PhotoMetadata) {
    var imageView = cell.imageView
    let retinaMultiplier = UIScreen.mainScreen().scale
    
    var retinaSquare = CGSizeMake(imageView.bounds.size.width * retinaMultiplier, imageView.bounds.size.height * retinaMultiplier)
    
    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
    let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
    dispatch_async(backgroundQueue, {
        println("Getting image \(photo.url) with background queue")
        
        var asset : PHAsset? = nil
        var fetchOptions = PHFetchOptions()
        var result = PHAsset.fetchAssetsWithLocalIdentifiers([photo.url], options: PHFetchOptions())
        
        
        if (result != nil && result.count > 0) {
            // get last photo from Photos
            asset = result.lastObject as? PHAsset
        }
        
        if let a = asset {
            var manager = PHImageManager.defaultManager()
            manager.requestImageForAsset(a, targetSize: retinaSquare, contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (image : UIImage!, info:[NSObject : AnyObject]!) -> Void in
                imageView.image = image
            })
        }
    })
}