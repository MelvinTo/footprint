//
//  HelpersTest.swift
//  Footprint
//
//  Created by Melvin Tu on 4/13/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import Footprint
import MapKit

class HelpersTest: XCTestCase {
        override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetCentralPoint() {
        let pointA = CLLocation(latitude: 45.0, longitude: 90.0)
        let result = getCentralPoint([pointA])
        
        let location = CLLocation(latitude: pointA.coordinate.latitude, longitude: pointA.coordinate.longitude)
        let resultLocation = CLLocation(latitude: result.coordinate.latitude, longitude: result.coordinate.longitude)
        
        let distance = location.distanceFromLocation(resultLocation)
        
        XCTAssert(distance < 0.0001, "result \(result.coordinate.latitude, result.coordinate.longitude) should equal to pointA \(pointA.coordinate.latitude, pointA.coordinate.longitude)")
    }
    
    func testGetCentralPoint2() {
        let pointA = CLLocation(latitude: 30.0, longitude: 60.0)
        let pointB = CLLocation(latitude: 30.0, longitude: 120.0)
        let expected_result = CLLocation(latitude: 33.69, longitude: 90.0)
        let result = getCentralPoint([pointA, pointB])
        
        let resultLocation = CLLocation(latitude: result.coordinate.latitude, longitude: result.coordinate.longitude)
        
        let distance = expected_result.distanceFromLocation(resultLocation)
        
        XCTAssert(distance < 10, "result \(result.coordinate.latitude, result.coordinate.longitude) should equal to pointA \(expected_result.coordinate.latitude, expected_result.coordinate.longitude), but distance is \(distance)")
    }
}
