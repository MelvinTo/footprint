//
//  FootprintCell.swift
//  Footprint
//
//  Created by Melvin Tu on 4/10/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

class FootprintCell : UITableViewCell {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var when: UILabel!
    var footprint: Footprint? = nil
    
    func cellDidLoad() {
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.rotateEnabled = false
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        if let fp = footprint {
            if fp.photos.count > 0 {
                let timestamp = footprint?.photos[0].timestamp
                if let ts = timestamp {
                    when.text = dateFormatter.stringFromDate(ts)
                }
            }
        }
    }
}