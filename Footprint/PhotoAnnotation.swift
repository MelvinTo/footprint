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
    var photo: PHAsset? = nil
    var clusterAnnocation : PhotoAnnotation? = nil
    var containedAnnotations : [PhotoAnnotation]? = nil
    var placemark: CLPlacemark? = nil
    var title: String = "default title"
    var subtitle: String = "default subtitle"
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
    
    init(location: CLLocation, photo: PHAsset) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.photo = photo
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
    
    override var description: String {
        let identifier = self.photo?.localIdentifier
        let shortIdentifier = identifier!.substringToIndex(advance(identifier!.startIndex, 8))
        return "photo: \(shortIdentifier) title: \(title) subtitle: \(subtitle) clustered: \(clusterAnnocation != nil)"
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
        if self.title == "default title" {
            println("getting real title for location \(self.location)")
            CLGeocoder().reverseGeocodeLocation(self.location, completionHandler: { (placemarks, error) -> Void in
                
                if placemarks.count > 0 {
                    self.placemark = placemarks[0] as? CLPlacemark
                    let identifier = self.photo!.localIdentifier
                    let shortIdentifier = identifier.substringToIndex(advance(identifier!.startIndex, 8))
                    self.title = "\(self.placemarkString!)"
                }
                
            })
        }
        
        if containedAnnotations?.count > 0 {
            self.subtitle = "\(containedAnnotations!.count + 1) photos"
        } else {
            self.subtitle = "default subtitle"
        }
    }
}