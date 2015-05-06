//
//  Connector.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

public protocol ConnectorDelegate {
    func addPhoto(photo: PhotoObject)
}

public class Connector {
    public var delegate: ConnectorDelegate? = nil
    
    init() {
    }
    
    public func loadPhotos() {
    }
    
    public func getRawImage(photo: PhotoObject, width: CGFloat, height: CGFloat, block: (UIImage?, NSError?) -> Void) {
    }
}