//
//  DropboxConnector.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

public class DropboxConnector : Connector {
    
    static let appKey = "z12bfkfdcbeut6r"
    static let appSecret = "rsxhwckihmalq5s"
    static let linkNotification = "dropboxLinked"
    
    static var sharedDropboxConnector: DropboxConnector? = nil
    
    public class func getSharedDropboxConnector() -> DropboxConnector {
        
        if let s = sharedDropboxConnector {
            return s
        } else {
            sharedDropboxConnector = DropboxConnector()
            return sharedDropboxConnector!
        }
    }
    
    init() {
        var dbSession = DBSession(appKey: DropboxConnector.appKey, appSecret: DropboxConnector.appSecret, root: kDBRootDropbox)
        DBSession.setSharedSession(dbSession)
    }
    
    public func numberOfPhotos() -> Int {
        return 0
    }
    
    public func getRawImage(photo: PhotoObject, width: CGFloat, height: CGFloat, block: (UIImage?, NSError?) -> Void) {
    }
    
    public func loadPhotos(blockForEachPhoto: (PhotoObject, Int) -> Void, completed: (Void -> Void)?) {
        NSLog("Load photo called!!")
    }
    
    public var name: String {
        get {
            return "Dropbox"
        }
    }
}