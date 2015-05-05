//
//  Connector.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

protocol PhotoQueue {
    func next() -> NewPhoto?
}

protocol Connector {
    func getQueue() -> PhotoQueue?
    func getRawImage(photo: NewPhoto) -> UIImage?
}