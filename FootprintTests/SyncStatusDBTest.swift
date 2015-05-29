//
//  SyncStatusDBTest.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/30/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import XCTest
import Footprint
import CoreData

class TestSyncStatusDB: XCTestCase {
    func testAddItem() {
        let source = "Dropbox"
        let identifier1 = "/x/b/c"
        let identifier2 = "/y/d/e"
        let ctxt = CoreDataHelper.getSharedCoreDataHelper().managedObjectContext
        var statusDB = SyncStatusDB(context: ctxt!)
        statusDB.addSyncItem(identifier1, source: source)
        statusDB.addSyncItem(identifier2, source: source)

    }
}