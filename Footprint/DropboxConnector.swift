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
    
    func loadDirURL(dirURL: String) {
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
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error2: NSError!) -> Void in
            if let e = error2 {
                let url = request.URL
                NSLog("Got error \(e) when accessing url: \(url)")
                return
            }
            
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                // process jsonResult
//                NSLog("\(jsonResult)")
                self.parseJSONResult(jsonResult)
            } else {
                // couldn't load JSON, look at error
                NSLog("Error: \(error)")
            }
        })
    }
    
    func parseJSONResult(jsonResult: NSDictionary) {
        let isDir = jsonResult["is_dir"] as! Int?
        
        if isDir == nil || isDir == 0 {
            return
        }
        
        let folderHash = jsonResult["hash"] as! String
        let folderPath = jsonResult["path"] as! String
        NSLog("\(folderPath) : \(folderHash)")
        
        if let contents = jsonResult["contents"] as? Array<NSDictionary> {
            for element in contents {
                parseElement(element)
            }
        }
    }
    
    func parseElement(element: NSDictionary) {
        if let isDirectory = element["is_dir"] as? Int {
            if isDirectory == 0 {
                // file
                parseFileMetadata(element)
            } else {
                // dir
                if let dirPath = element["path"] as? String {
                    loadDirURL(dirPath)
                }
            }
        }
    }
    
    func parseFileMetadata(metadata: NSDictionary) {
        if let path = metadata["path"] as? String {
            if let photo_info = metadata["photo_info"] as? NSDictionary {
                if let latlon = photo_info["lat_long"] as? Array<String> {
                    let latitude = latlon[0]
                    let longitude = latlon[1]
                    NSLog("\(latitude), \(longitude)")
                } else {
                    NSLog("NO GPS info on photo: \(path)")
                }
            }
        }
    }
    
    public func loadPhotos(blockForEachPhoto: (PhotoObject, Int) -> Void, completed: (Void -> Void)?) {
        NSLog("Load photo called!!")
        
        if self.isLinked() {
            
            loadDirURL("/photos/国外/")
        
        } else {
            NSLog("Dropbox is not linked")
        }
        
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