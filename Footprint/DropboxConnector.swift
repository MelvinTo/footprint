//
//  DropboxConnector.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/4/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

public class DropboxConnector : NSObject, Connector, DBRestClientDelegate {
    
    static let appKey = "z12bfkfdcbeut6r"
    static let appSecret = "rsxhwckihmalq5s"
    static let linkNotification = "dropboxLinked"
    
    static var sharedDropboxConnector: DropboxConnector? = nil
    
    var dbRestClient: DBRestClient? = nil
    var activeConnectionCnt: Int = 0
    var semaphore: dispatch_semaphore_t? = nil

//    var queue = dispatch_queue_create("dropboxLoadPhotos", DISPATCH_QUEUE_SERIAL)
    
    public class func getSharedDropboxConnector() -> DropboxConnector {
        
        if let s = sharedDropboxConnector {
            return s
        } else {
            sharedDropboxConnector = DropboxConnector()
            return sharedDropboxConnector!
        }
    }
    
    override init() {
        super.init()
        var dbSession = DBSession(appKey: DropboxConnector.appKey, appSecret: DropboxConnector.appSecret, root: kDBRootDropbox)
        DBSession.setSharedSession(dbSession)
    }
    
    public func numberOfPhotos() -> Int {
        return 0
    }
    
    public func getRawImage(photo: PhotoObject, width: CGFloat, height: CGFloat, block: (UIImage?, NSError?) -> Void) {
    }
    
    func prepareHTTPRequestHeader() -> String? {
        let users = DBSession.sharedSession().userIds
        // users.length should always be 1
        
        if users.count == 0 {
            return nil
        }
        
        let user = users[0] as! String
        
        let credential = DBSession.sharedSession().credentialStoreForUserId(user)
        let accessToken = credential.accessToken
        let accessTokenSecret = credential.accessTokenSecret
        
        let header = "OAuth oauth_version=\"1.0\", "
                            + "oauth_signature_method=\"PLAINTEXT\", "
                            + "oauth_consumer_key=\"\(DropboxConnector.appKey)\", "
                            + "oauth_token=\"\(accessToken)\", "
                            + "oauth_signature=\"\(DropboxConnector.appSecret)&\(accessTokenSecret)\""
        
        return header
        
    }
    
    func loadDirURL(dirURL: String, blockForEachPhoto: (PhotoObject, Int?) -> Void) {
        var urlString = "https://api.dropbox.com/1/metadata/auto\(dirURL)?include_media_info=true&list=true".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        if urlString == nil {
            NSLog("Invalid URL: \(dirURL)")
            return
        }
        
        let url = NSURL(string: urlString!)
        if url == nil {
            NSLog("Failed to create NSURL based on: \(urlString)")
            return
        }
        
        var request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue(prepareHTTPRequestHeader(), forHTTPHeaderField: "Authorization")
        let headers = request.valueForHTTPHeaderField("Authorization")
        
        self.activeConnectionCnt++
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error2: NSError!) -> Void in
            if let e = error2 {
                let url = request.URL
                NSLog("Got error \(e) when accessing url: \(url!)")
                return
            }
            
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                // process jsonResult
//                NSLog("\(jsonResult)")
                self.parseJSONResult(jsonResult, blockForEachPhoto: blockForEachPhoto)
            } else {
                // couldn't load JSON, look at error
                NSLog("Error: \(error)")
            }
            self.activeConnectionCnt--
            if self.activeConnectionCnt == 0 {
                dispatch_semaphore_signal(self.semaphore!)
            }
        })
    }
    
    func parseJSONResult(jsonResult: NSDictionary, blockForEachPhoto: (PhotoObject, Int?) -> Void) {
        let isDir = jsonResult["is_dir"] as! Int?
        
        if isDir == nil || isDir == 0 {
            return
        }
        
        let folderHash = jsonResult["hash"] as! String
        let folderPath = jsonResult["path"] as! String
        NSLog("\(folderPath) : \(folderHash)")
        
        if let contents = jsonResult["contents"] as? Array<NSDictionary> {
            for element in contents {
                parseElement(element, blockForEachPhoto: blockForEachPhoto)
            }
        }
    }
    
    func parseElement(element: NSDictionary, blockForEachPhoto: (PhotoObject, Int?) -> Void) {
        if let isDirectory = element["is_dir"] as? Int {
            if isDirectory == 0 {
                // file
                parseFileMetadata(element, blockForEachPhoto: blockForEachPhoto)
            } else {
                // dir
                if let dirPath = element["path"] as? String {
                    loadDirURL(dirPath, blockForEachPhoto: blockForEachPhoto)
                }
            }
        }
    }
    
    func parseFileMetadata(metadata: NSDictionary, blockForEachPhoto: (PhotoObject, Int?) -> Void) {
        if let path = metadata["path"] as? String {
            if let photo_info = metadata["photo_info"] as? NSDictionary {
                NSLog("photo_info: \(photo_info)")
                if let latlon = photo_info["lat_long"] as? Array<NSNumber> {
                    NSLog("latlon: \(latlon)")
                    let latitude = latlon[0].doubleValue
                    let longitude = latlon[1].doubleValue
                    let source = "Dropbox"
                    let identifier = path
                    let name = path
                    let createTimeString = photo_info["time_taken"] as! String
                    var dateFormatter = NSDateFormatter()
                    
                    // "Wed, 28 Aug 2013 18:12:02 +0000"
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                    let createdDate = dateFormatter.dateFromString(createTimeString)
                    
                    var photoObject = PhotoObject(identifier: identifier, timestamp: createdDate!, latitude: latitude, longitude: longitude)
                    photoObject.source = source
                    photoObject.name = name
                    
                    blockForEachPhoto(photoObject, nil)
                    
                    
                    NSLog("\(latitude), \(longitude)")
                } else {
//                    NSLog("NO GPS info on photo: \(path)")
                }
            }
        }
    }
    
    public func loadPhotos(blockForEachPhoto: (PhotoObject, Int?) -> Void, completed: (Void -> Void)?) {
        NSLog("Load photo called!!")
        semaphore = dispatch_semaphore_create(0)
        
        if self.isLinked() {
            
            loadDirURL("/Photos/小孩/甜甜/201203第一个月/", blockForEachPhoto: blockForEachPhoto)
        
        } else {
            NSLog("Dropbox is not linked")
        }
        
        dispatch_semaphore_wait(semaphore!, dispatch_time(DISPATCH_TIME_NOW, 3600000000000))
        semaphore = nil
        
        if let x = completed {
            x()
        }
    }
    
    public var name: String {
        get {
            return "Dropbox"
        }
    }
    
    public func isLinked() -> Bool {
        return DBSession.sharedSession().isLinked()
    }
    
    public func listPhotos() {
        if !self.isLinked() {
            NSLog("Dropbox is not linked")
        }
    }
    
    public func restClient(client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        NSLog("metadata loaded for file: \(metadata.path)")
        for metadata in metadata.contents {
            
        }
        
    }
    
    public func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        NSLog("Failed to load metadata with error: \(error)")
    }
}