//
//  PhotoUtilTests.swift
//  Footprint
//
//  Created by Melvin Tu on 4/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import UIKit
import XCTest
import 足迹地图
import CoreData

class PhotoStoreTests: XCTestCase {
    var context : NSManagedObjectContext? = nil
    var store : PhotoStore? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let cdstore = CoreDataStore()
        let cdh = CoreDataHelper(store: cdstore)
        context = cdh.managedObjectContext
        
        store = PhotoStore()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        store!.resetPhotos()
    }
    
    func testInsertPhoto() {
        var photo = PhotoMetadata()
        photo.latitude = 30.226155
        photo.longitude = 120.126113833333
        photo.timestamp = NSDate()
        photo.url = "http://This is a test url111"
        
        XCTAssert(self.store!.storePhoto(photo), "photo has been successfully added into CoreData")
        XCTAssert(self.store!.isPhotoExists(photo), "photo should already exist")
        XCTAssert(!self.store!.storePhoto(photo), "duplicated photo will be ignored")
    }
}
