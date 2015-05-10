//
//  Connector.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

public protocol Connector {
    func numberOfPhotos() -> Int
    func loadPhotos(blockForEachPhoto: (PhotoObject, Int) -> Void, completed: (Void -> Void)?)
    func getRawImage(photo: PhotoObject, width: CGFloat, height: CGFloat, block: (UIImage?, NSError?) -> Void)
    var name: String {
        get
    }
}