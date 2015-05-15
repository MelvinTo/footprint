//
//  Helpers.swift
//  Footprint
//
//  Created by Melvin Tu on 4/5/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    println("Time elapsed for \(title): \(timeElapsed) s")
}

func timeElapsedInSecondsWhenRunningCode(operation:()->()) -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return Double(timeElapsed)
}

func imageWithColor(color: UIColor) -> UIImage {
    var rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
    var context = UIGraphicsGetCurrentContext()
    
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, rect)
    
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}

func DegreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

func RadiansToDegrees (value:Double) -> Double {
    return value * 180.0 / M_PI
}

enum Angle {
    case Radians(Double)
    case Degrees(Double)
    
    var scalar: Double {
        switch(self) {
        case .Radians(let v):
            return v
        case .Degrees(let v):
            return v
        }
    }
    
    var radians: Angle {
        switch(self) {
        case .Radians(_):
            return self
        case .Degrees(let value):
            return .Radians(DegreesToRadians(value))
        }
    }
    
    var degrees: Angle {
        switch(self) {
        case .Radians(let value):
            return .Degrees(RadiansToDegrees(value))
        case .Degrees(_):
            return self
        }
    }
}

extension Double {
    
    init(_ angle:Angle) {
        self.init(angle.scalar)
    }
    
}

public func getCentralPoint(locations: [CLLocation]) -> CLLocation {
    var x=0.0, y=0.0, z=0.0
    
    for location in locations {
        let radian_lat = Angle.Degrees(location.coordinate.latitude).radians.scalar
        let radian_lon = Angle.Degrees(location.coordinate.longitude).radians.scalar
        x += cos(radian_lat) * cos(radian_lon)
        y += cos(radian_lat) * sin(radian_lon)
        z += sin(radian_lat)
    }
    
    let count = locations.count
    
    x = x / Double(count)
    y = y / Double(count)
    z = z / Double(count)
    
    let central_lat = atan2(z, sqrt(x * x + y * y))
    let central_lon = atan2(y, x)
    
    let central_lat_in_degrees = Double(Angle.Radians(central_lat).degrees)
    let central_lon_in_degrees = Double(Angle.Radians(central_lon).degrees)
    
    return CLLocation(latitude: central_lat_in_degrees, longitude: central_lon_in_degrees)
}

public func getSpan(locations: [CLLocation]) -> MKCoordinateSpan {
    let latitudes = locations.map { $0.coordinate.latitude }
    let longitudes = locations.map { $0.coordinate.longitude }
    
    let maxLatitude = latitudes.reduce(-90.0, combine: {max($0, $1)})
    let maxLongitude = longitudes.reduce(-180.0, combine: {max($0, $1)})
    let minLatitude = latitudes.reduce(90.0, combine: {min($0, $1)})
    let minLongitude = longitudes.reduce(180.0, combine: {min($0, $1)})
    
    let latitudeDelta = max(1.3 * (maxLatitude - minLatitude), 0.1) // at least 0.1, 1.3 is used to make sure the annotation is not very close to the map edge
    let longitudeDelta = max(1.3 * (maxLongitude - minLongitude), 0.1) // at least 0.1
    
    return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
}

extension CLPlacemark {
    
    func toString() -> String {
        var text = ""
        
        if let aois = self.areasOfInterest {
            if aois.count > 0 {
                text = aois[0] as! String
                return text
            }
        }
        
        if let x = self.administrativeArea {
            text += self.administrativeArea
        }
        if let x = self.locality {
            text += x
        }
        if let x = self.thoroughfare {
            text += x
        }
        return text
    }
    
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    var toDropboxDate: NSDate? {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")

        // "Wed, 28 Aug 2013 18:12:02 +0000"
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return dateFormatter.dateFromString(self)
    }
}

