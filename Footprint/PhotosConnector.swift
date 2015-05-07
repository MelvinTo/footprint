//
//  PhotosConnector.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

public class PhotosConnector : Connector {
    var imageManager: PHCachingImageManager? = nil

    public override init() {
        super.init()
        imageManager = PHCachingImageManager()
    }
    
    deinit {
        if let i = imageManager {
            i.stopCachingImagesForAllAssets()
        }
    }
    
    public override func getRawImage(photo: PhotoObject, width: CGFloat, height: CGFloat, block: (UIImage?, NSError?) -> Void) {
        let retinaMultiplier = UIScreen.mainScreen().scale
        let identifier = photo.identifier
        let fetchAssetsResult = PHAsset.fetchAssetsWithLocalIdentifiers([identifier], options: PHFetchOptions())
        
        if fetchAssetsResult.count == 0 {
            block(nil, nil)
            return
        }
        
        let photo = fetchAssetsResult.objectAtIndex(0) as! PHAsset
        
        var retinaSquare = CGSizeMake(width * retinaMultiplier, height * retinaMultiplier)
        
        var requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.Exact
        
        imageManager?.requestImageForAsset(photo,
            targetSize: retinaSquare,
            contentMode: PHImageContentMode.AspectFill,
            options: requestOptions,
            resultHandler: { (image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
                block(image, nil)
        })
    }
    
    public override func loadPhotos(block: (PhotoObject) -> Void) {
        let fetchAssetsResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: PHFetchOptions())
        var indexSet = NSIndexSet(indexesInRange: NSMakeRange(0, fetchAssetsResult!.count))
        fetchAssetsResult!.enumerateObjectsAtIndexes(indexSet, options: nil, usingBlock: { object, index, stop in
            if let p = object as? PHAsset {
                if let l = p.location {
                    var photoObject = PhotoObject(identifier: p.localIdentifier,
                        timestamp: p.creationDate,
                        latitude: p.location.coordinate.latitude,
                        longitude: p.location.coordinate.longitude)
                    
                    block(photoObject)
                }
            }
        })
    }
}