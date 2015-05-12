//
//  TestConnectorManager.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/6/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import XCTest
import Footprint
import CoreData

class TestConnectorManager: XCTestCase {
    var context : NSManagedObjectContext? = nil
    var store : PhotoStore? = nil
    var photosConnector = PhotosConnector()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let cdstore = CoreDataStore()
        let cdh = CoreDataHelper(store: cdstore)
        context = cdh.managedObjectContext
        
        store = PhotoStore()
    }
    
    func testLoadPhotos() {
        photosConnector.loadPhotos({ (photo, index) -> Void in
            NSLog("photo: \(photo.identifier)")
        }, completed: nil)
    }
    
    func testGetRawImage() {
        let photo = PhotoObject(identifier: "A7DAF218-8F98-4E0A-96B3-96D7781BEB10/L0/001", timestamp: NSDate(), latitude: 0.0, longitude: 0.0)
        photosConnector.getRawImage(photo, width: 100.0, height: 100.0) { (image, error) -> Void in
            XCTAssert(image != nil, "Raw image for \(photo.identifier) should be fetched")
        }
    }
    
    func addPhoto(photo: PhotoObject) {
        NSLog("photo \(photo) is added")
    }
    
    func testGetPhotoObjectCoreData() {
        var manager = NewPhotoDBManager(context: context!)

        let countBefortInsert = manager.numberOfNewPhotos()

        let photo = PhotoObject(identifier: "A7DAF218-8F98-4E0A-96B3-96D7781BEB10/L0/001", timestamp: NSDate(), latitude: 0.0, longitude: 0.0)
        var newPhoto = photo.toNewPhoto(context!)
        context?.save(nil)
        NSLog("\(newPhoto)")
        
        let countAfterInsert = manager.numberOfNewPhotos()
        NSLog("New added photos: \(countAfterInsert-countBefortInsert)")
        XCTAssertEqual(countAfterInsert - countBefortInsert
            , 1, "Only one photo should be added")
    }
    
    func testPhotosConnector() {
        let manager = ConnectorManager.getSharedConnectorManager()
        manager.storeNewPhotos(PhotosConnector(), context: context!, progress: nil, completed: nil)
    }
}    