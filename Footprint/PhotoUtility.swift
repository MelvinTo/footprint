//
//  PhotoUtility.swift
//  Footprint
//
//  Created by Melvin Tu on 4/13/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        var secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        var dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        var secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        var dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

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

public func aggregatePhotos(photos: [PhotoMetadata]) -> [PhotoMetadata : [PhotoMetadata]]? {
    // sort by timestamp
    let sortedPhotos = photos.sorted { $0.timestamp.isLessThanDate($1.timestamp) }
    var result : [PhotoMetadata : [PhotoMetadata]] = [:]
    var tmpPhoto : PhotoMetadata? = nil
    var tmpLocation : CLLocation? = nil
    var photoArray : [PhotoMetadata]? = nil
    
    
    for photo in sortedPhotos {
        if tmpPhoto == nil {
            tmpPhoto = photo
            tmpLocation = CLLocation(latitude: tmpPhoto!.latitude.doubleValue, longitude: tmpPhoto!.longitude.doubleValue)
            photoArray = [photo]
        } else {
            let curLocation = CLLocation(latitude: photo.latitude.doubleValue, longitude: photo.longitude.doubleValue)
            let distance = curLocation.distanceFromLocation(tmpLocation)
            if distance < 500.0 { // magic number: 500 meters
                photoArray?.append(photo)
            } else {
                result[tmpPhoto!] = photoArray
                tmpPhoto = photo
                tmpLocation = CLLocation(latitude: tmpPhoto!.latitude.doubleValue, longitude: tmpPhoto!.longitude.doubleValue)
                photoArray = [photo]
            }
        }
    }
    
    if tmpPhoto != nil {
        result[tmpPhoto!] = photoArray
    }
    
    for (a,b) in result {
        println(a.url)
        for c in b {
            println(c.url)
        }
    }
    
    NSLog("\(result)")
    
    return result
}

public class PhotoUtility {
    public class func getAggregatedLocations(fetchAssetsResult: PHFetchResult) -> [CLLocation : [PHAsset]] {
        var tmpLocation : CLLocation? = nil
        var tmpAssetArray : [PHAsset]? = nil
        var result : [CLLocation : [PHAsset]] = [:]
        
        var indexSet = NSIndexSet(indexesInRange: NSMakeRange(0, fetchAssetsResult.count))
        fetchAssetsResult.enumerateObjectsAtIndexes(indexSet, options: nil, usingBlock: { object, index, stop in
            if let p = object as? PHAsset {
                var location = p.location
                if location == nil {
                    location = CLLocation(latitude: 39.908747, longitude: 116.397410)
                }
                if tmpLocation == nil {
                    tmpLocation = location
                    tmpAssetArray = [p]
                } else {
                    let distance = tmpLocation?.distanceFromLocation(location)
                    if distance < 1000.0 {
                        tmpAssetArray?.append(p)
                    } else {
                        result[tmpLocation!] = tmpAssetArray
                        tmpLocation = location
                        tmpAssetArray = [p]
                    }
                }
            }
        })
        
        if tmpLocation != nil {
            result[tmpLocation!] = tmpAssetArray
        }
        
        return result
    }
}

