//
//  PhotoObject.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/6/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

func ==(left: PhotoObject, right: PhotoObject) -> Bool {
    return left.identifier == right.identifier
}

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
    
    public var location: String {
        return "'\(latitude), \(longitude)'"
    }
    
    public var cooridinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var toMarsCoordinate: CLLocationCoordinate2D {
        return self.cooridinate.toMars()
    }
    
    public var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    public var toMarsLocation: CLLocation {
        return CLLocation(latitude: toMarsCoordinate.latitude, longitude: toMarsCoordinate.longitude)
    }
}