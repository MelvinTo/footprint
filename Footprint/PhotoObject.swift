//
//  PhotoObject.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/6/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

public class PhotoObject : Printable {
    var name: String = ""
    public var identifier: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var source: String = ""
    var timestamp: NSDate = NSDate()
    var thumb: NSData? = nil
    
    public init(identifier: String, timestamp: NSDate, latitude: Double, longitude: Double) {
        self.identifier = identifier
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }

    public var description: String {
        return identifier
    }
}