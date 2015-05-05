//
//  ConnectorManager.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

class ConnectorManager {
    class func getAvailableConnectors() -> [Connector] {
        return [PhotosConnector()]
    }
    
    class func syncWithConnectors() {
        
    }
}