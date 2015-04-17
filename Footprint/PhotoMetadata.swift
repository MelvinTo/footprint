//
//  PhotoMetadata.swift
//  Footprint
//
//  Created by Melvin Tu on 4/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

public struct PhotoMetadata :  Hashable, Equatable {
    public var latitude: NSNumber
    public var longitude: NSNumber
    public var timestamp: NSDate
    public var url: String
    
    public init() {
        latitude = 0
        longitude = 0
        timestamp = NSDate()
        url = ""
    }
    
    var description : String {
        return url
    }
    
    public var hashValue: Int {
        return url.hashValue
    }
}

public func == (lhs: PhotoMetadata, rhs: PhotoMetadata) -> Bool {
    return lhs.url == rhs.url
}