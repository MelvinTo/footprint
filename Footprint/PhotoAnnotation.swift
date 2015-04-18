//
//  PhotoAnnotation.swift
//  Footprint
//
//  Created by Melvin Tu on 4/18/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

class PhotoAnnotation : NSObject, MKAnnotation {
    var latitude : Double
    var longitude : Double
    var photo: UIImage? = nil
    var clusterAnnocation : PhotoAnnotation? = nil
    var containedAnnotations : [PhotoAnnotation]? = nil
    var placemark: CLPlacemark? = nil
    var title: String? = nil
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    
    var coordinate : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var subtitle: String! {
        if containedAnnotations?.count > 0 {
            return "\(containedAnnotations!.count + 1) photos"
        } else {
            return "one photo"
        }
    }
    
    var placemarkString: String? {
        var str = ""
        if let l = placemark?.locality {
            str += l
        }
        
        if let a = placemark?.administrativeArea {
            if !str.isEmpty {
                str += ", "
                str += a
            }
        }
        
        if str.isEmpty && placemark!.name != nil {
            str = placemark!.name
        }
        
        return str
    }

    func updateTitleIfNeeded() {
        if self.title == nil {
            CLGeocoder().reverseGeocodeLocation(self.location, completionHandler: { (placemarks, error) -> Void in
                
                if placemarks.count > 0 {
                    self.placemark = placemarks[0] as? CLPlacemark
                    self.title = self.placemarkString
                }
                
            })
        }
    }
}