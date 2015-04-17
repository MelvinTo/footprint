//
//  Footprint.swift
//  Footprint
//
//  Created by Melvin Tu on 4/6/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

public struct Footprint {
    var name : String
    var location : String
    var photos : [PhotoMetadata]
    var timestamp : NSDate = NSDate()
    
    init(name: String) {
        location = ""
        self.name = name
        photos = []
    }
    
    func description() -> String {
        return "Footprint '\(name)'\n\(photos)"
    }
    
    func updateMap(map: MKMapView) {
        if photos.count > 0 {
            for photo in photos {
                var annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: photo.latitude.doubleValue, longitude: photo.longitude.doubleValue)
                annotation.title = photo.timestamp.description
                annotation.subtitle = photo.url
                map.addAnnotation(annotation)
            }
            
            let locations : [CLLocation] = photos.map {CLLocation(latitude: $0.latitude.doubleValue, longitude: $0.longitude.doubleValue)}
            let centralLocation = getCentralPoint(locations)
            let span = getSpan(locations)
            
            var region = MKCoordinateRegion(center: centralLocation.coordinate, span: span)
            map.setRegion(region, animated: true)
            
        }

    }
}