//
//  MiscTests.swift
//  Footprint
//
//  Created by Melvin Tu on 4/16/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import Footprint
import MapKit

class MiscTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetCentralPoint() {
//        var result = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: PHFetchOptions())
//        println(result.count)
        var options = PHFetchOptions()
        var sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        var result = PHAsset.fetchAssetsWithOptions(options)
        println(result.count)
    }
    
    func testAggregation() {
        var options = PHFetchOptions()
        var sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        var fetchAssetsResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: options)
        println(fetchAssetsResult!.count)
        
        var result = PhotoUtility.getAggregatedLocations(fetchAssetsResult)
        
        for (location, photoArray) in result {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
//            XCTAssertEqual(lat, 39.908747, "latitude \(lat) should be 39.908747")
//            XCTAssertEqual(lon, 116.39741, "longitude \(lon) should be 116.39741")
//            XCTAssertEqual(photoArray.count, 10, "number of photos should be 10")
        }
    }
    
    func testGettingAddress2() {
        var gl = CLGeocoder()
        NSLog("\(gl.geocoding)")
        gl.reverseGeocodeLocation(CLLocation(latitude: 39.908747, longitude: 116.39741), completionHandler: { (placemarks, error) -> Void in
            NSLog("aaa")
            if let pms = placemarks {
                for placemark in pms {
                    NSLog("\(placemark)")
                }
                NSLog("placemark count: \(pms.count)")
            } else {
                NSLog("Error when reverse geocode: \(error)")
            }
        })
        
        NSLog("\(gl.geocoding)")

        NSThread.sleepForTimeInterval(10.0)
        NSLog("\(gl.geocoding)")

    }
    
    
    func testGettingAddress() {
        //<+37.39244500,-121.85183667>
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: 37.3924, longitude: -121.85), completionHandler: { (placemarks, error) -> Void in
            
            if let pms = placemarks {
                for placemark in pms {
                    NSLog("\(placemark)")
                }
                NSLog("placemark count: \(pms.count)")
            } else {
                NSLog("Error when reverse geocode: \(error)")
            }
        })
        
        NSThread.sleepForTimeInterval(3.0)

    }

}