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

    public init() {
        imageManager = PHCachingImageManager()
    }
    
    deinit {
        if let i = imageManager {
            i.stopCachingImagesForAllAssets()
        }
    }
    
    public func numberOfPhotos() -> Int {
        let fetchAssetsResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: PHFetchOptions())
        return fetchAssetsResult.count
    }

    public func getRawImage(photo: PhotoObject, width: CGFloat, height: CGFloat, block: (UIImage?, NSError?) -> Void) {
        let identifier = photo.identifier
        let fetchAssetsResult = PHAsset.fetchAssetsWithLocalIdentifiers([identifier], options: PHFetchOptions())
        
        if fetchAssetsResult.count == 0 {
            block(nil, nil)
            return
        }
        
        let photo = fetchAssetsResult.objectAtIndex(0) as! PHAsset
        
        var size = CGSizeMake(width, height)
        
        var requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.Exact
        
        imageManager?.requestImageForAsset(photo,
            targetSize: size,
            contentMode: PHImageContentMode.AspectFill,
            options: requestOptions,
            resultHandler: { (image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
                block(image, nil)
        })
    }
    
    public func loadPhotos(blockForEachPhoto: (PhotoObject, Int?) -> Void, completed: (Void -> Void)?) {
        let fetchAssetsResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: PHFetchOptions())
        var indexSet = NSIndexSet(indexesInRange: NSMakeRange(0, fetchAssetsResult!.count))
        fetchAssetsResult!.enumerateObjectsAtIndexes(indexSet, options: nil, usingBlock: { object, index, stop in
            if let p = object as? PHAsset {
                if let l = p.location {
                    var photoObject = PhotoObject(identifier: p.localIdentifier,
                        timestamp: p.creationDate,
                        latitude: p.location.coordinate.latitude,
                        longitude: p.location.coordinate.longitude)
                    photoObject.source = self.name
                    
                    blockForEachPhoto(photoObject, index)
                }
            }
        })
        if let x = completed {
            x()
        }
    }
    
    public var name: String {
        get {
            return "Photos"
        }
    }
    
    func checkAccess() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status != .Authorized {
            let alert = UIAlertView(title: "Attention", message: "Please give this app permission to access your photo library in your settings app!", delegate: nil, cancelButtonTitle: "Close")
            alert.show()
            return false
        }
        
        return true
    }
}