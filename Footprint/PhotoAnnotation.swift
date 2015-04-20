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
    var title: String = "..."
    var subtitle: String = "..."
    
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
    
    dynamic var coordinate : CLLocationCoordinate2D {
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

    func updateTitleIfNeeded() {
        if self.title == "..." {
            println("getting real title for location \(self.location)")
            CLGeocoder().reverseGeocodeLocation(self.location, completionHandler: { (placemarks, error) -> Void in
                
                if placemarks.count > 0 {
                    self.placemark = placemarks[0] as? CLPlacemark
                    let identifier = self.photo!.localIdentifier
                    let shortIdentifier = identifier.substringToIndex(advance(identifier!.startIndex, 8))
                    self.title = "\(self.placemark!.toString())"
                } else {
                    self.title = "Unknown places"
                }
                
            })
        }
        
        if containedAnnotations?.count > 0 {
            self.subtitle = "\(containedAnnotations!.count + 1) photos"
        } else {
            self.subtitle = "1 photo"
        }
    }
}