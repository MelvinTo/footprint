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
    
    var hashCache: [String: String] = [:]
    
    var queue = dispatch_queue_create("storeHash", DISPATCH_QUEUE_SERIAL)


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
        
        // load existing hashCaches from database
        dispatch_async(dispatch_get_main_queue(), {
            if let context = CoreDataHelper.getSharedCoreDataHelper().managedObjectContext {
                let folderHashDB = FolderHashCoreData(context: context)
                if let results = folderHashDB.loadAllFolderHashes() {
                    for result in results {
                        self.hashCache[result.folderPath] = result.folderHash
                    }
                }
            }
        })

    }
    
    public func numberOfPhotos() -> Int {
        return 0
    }
    
    // setup request for use, including utf8 encoding and authentication
    func prepareHTTPRequest(url: String) -> NSMutableURLRequest? {
        let encodedURL = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        if encodedURL == nil {
            NSLog("Failed to utf8-encode \(url)")
            return nil
        }
        
        let nsURL = NSURL(string: encodedURL!)
        if nsURL == nil {
            NSLog("Failed to create NSURL based on: \(encodedURL)")
            return nil
        }
        
        var request : NSMutableURLRequest = NSMutableURLRequest(URL: nsURL!)
        request.HTTPMethod = "GET"
        request.setValue(prepareHTTPRequestHeader(), forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    public func getRawImage(photo: PhotoObject, width: CGFloat, height: CGFloat, block: (UIImage?, NSError?) -> Void) {
        let thumbnailURL = "https://api-content.dropbox.com/1/thumbnails/auto\(photo.identifier)?size=xl"
        
        var request = prepareHTTPRequest(thumbnailURL)

        if request == nil {
            NSLog("Failed to create request for url: \(thumbnailURL)")
            return
        }
        
        NSLog("encoded url: \(request!.URL?.absoluteString)")
        
        NSURLConnection.sendAsynchronousRequest(request!, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, requestError: NSError!) -> Void in
            if let e = requestError {
                let url = request!.URL
                NSLog("Got error \(e) when accessing url: \(url!.absoluteString)")
                block(nil,requestError)
            } else {
                let image = UIImage(data: data)
                block(image, nil)
            }
        })

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
    
    func loadDirURL(dirURL: String, blockForEachPhoto: (PhotoObject, Int?) -> Void) -> Bool {
        
        NSLog("Loading URL: \(dirURL)")
        
        var urlString = "https://api.dropbox.com/1/metadata/auto\(dirURL)?include_media_info=true&list=true"
        if let hash = hashCache[dirURL] {
            urlString += "&hash=\(hash)"
        }
        
        var request = prepareHTTPRequest(urlString)
        
        if request == nil {
            NSLog("Failed to create request for url: \(urlString)")
            return false
        }
        
        var error: NSErrorPointer = nil
        var response: NSURLResponse?
        
        let data = NSURLConnection.sendSynchronousRequest(request!, returningResponse: &response, error: error)
        
        if let httpResponse = response as? NSHTTPURLResponse {
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200:
                // success
                NSLog("Got content for url: \(urlString)")
            case 304:
                // not modified..
                NSLog("Folder \(urlString) is not changed")
                return true
            default:
                NSLog("Got http response code \(statusCode) when requesting url \(urlString)")
                return false // do not run further..
            }
        }

        if error != nil {
            let url = request!.URL
            NSLog("Got error \(error.memory!.domain) - \(error.memory!.code) when accessing url: \(url!)")
            return false
        }
        
        if let d = data {
            var jsonError: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(d, options:NSJSONReadingOptions.MutableContainers, error: jsonError) as? NSDictionary
            
            if (jsonResult != nil) {
                // process jsonResult
                //                NSLog("\(jsonResult)")
                
                // Successfully loaded the content of this folder
                let success = self.parseJSONResult(jsonResult, blockForEachPhoto: blockForEachPhoto)
                
                if success {
                    // update hash if all sub directories are loaded successfully.
                    if let newHash = jsonResult["hash"] as? String {
                        
                        dispatch_async(self.queue) {
                            
                            if let ctxt = CoreDataHelper.getSharedCoreDataHelper().backgroundContext {
                                let folderHashDB = FolderHashCoreData(context: ctxt)
                                folderHashDB.createOrUpdateFolderHash(dirURL, hash: newHash)
                            }
                            
                        }
                        
                        // update local cache
                        self.hashCache[dirURL] = newHash
                    }
                }
                return success
                
            } else {
                // couldn't load JSON, look at error
                NSLog("Error: \(jsonError)")
                return false
            }
        }
        
        return false
    }
    
    func parseJSONResult(jsonResult: NSDictionary, blockForEachPhoto: (PhotoObject, Int?) -> Void) -> Bool {
        let isDir = jsonResult["is_dir"] as! Int?
        
        if isDir == nil || isDir == 0 {
            return true // ignore non-directory
        }
        
        let folderHash = jsonResult["hash"] as! String
        let folderPath = jsonResult["path"] as! String
        NSLog("\(folderPath) : \(folderHash)")
        
        var success = true
        
        if let contents = jsonResult["contents"] as? Array<NSDictionary> {
            for element in contents {
                success = parseElement(element, blockForEachPhoto: blockForEachPhoto) && success
            }
        }
        
        return success
    }
    
    func parseElement(element: NSDictionary, blockForEachPhoto: (PhotoObject, Int?) -> Void) -> Bool {
        if let isDirectory = element["is_dir"] as? Int {
            if isDirectory == 0 {
                // file
                return parseFileMetadata(element, blockForEachPhoto: blockForEachPhoto)
            } else {
                // dir
                if let dirPath = element["path"] as? String {
                    return self.loadDirURL(dirPath, blockForEachPhoto: blockForEachPhoto)
                }
            }
        }
        return false
    }
    
    func parseFileMetadata(metadata: NSDictionary, blockForEachPhoto: (PhotoObject, Int?) -> Void) -> Bool {
        if let path = metadata["path"] as? String {
            if let photo_info = metadata["photo_info"] as? NSDictionary {
//                NSLog("photo_info: \(photo_info)")
                if let latlon = photo_info["lat_long"] as? Array<NSNumber> {
//                    NSLog("latlon: \(latlon)")
                    let latitude = latlon[0].doubleValue
                    let longitude = latlon[1].doubleValue
                    let source = "Dropbox"
                    let identifier = path
                    let name = path
                    var createdDate: NSDate? = nil
                    
                    if let timeTaken = photo_info["time_taken"] as? String {
                        createdDate = timeTaken.toDropboxDate
                    } else if let clientMTime = metadata["client_mtime"] as? String {
                        createdDate = clientMTime.toDropboxDate
                    } else if let modifiedDate = metadata["modified"] as? String {
                        createdDate = modifiedDate.toDropboxDate // use modified date as created date becuase created date info is missing
                    }
                    
                    var photoObject = PhotoObject(identifier: identifier, timestamp: createdDate!, latitude: latitude, longitude: longitude)
                    photoObject.source = source
                    photoObject.name = name
                    
                    blockForEachPhoto(photoObject, nil)
                    
                    
//                    NSLog("\(latitude), \(longitude)")
                } else {
//                    NSLog("NO GPS info on photo: \(path)")
                }
            }
            return true
        }
        
        return false
    }
    
    public func loadPhotos(blockForEachPhoto: (PhotoObject, Int?) -> Void, completed: (Void -> Void)?) {
        NSLog("Load photo called!!")
        
        if self.isLinked() {
            self.loadDirURL("/Photos/", blockForEachPhoto: blockForEachPhoto)
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
    
    func cleanup() {
        self.hashCache = [:]
    }
}