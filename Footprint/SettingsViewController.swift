//
//  SettingsViewController.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/7/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import CoreData

class SettingsViewController : UITableViewController {
    @IBOutlet weak var photoCount: UILabel!
    @IBOutlet weak var photoLibraryCell: UITableViewCell!
    @IBOutlet weak var dropboxCell: UITableViewCell!
    
    var context : NSManagedObjectContext? = nil
    var store : PhotoStore? = nil
    var photosConnector = PhotosConnector()
    
    override func viewDidLoad() {
        self.title = "Settings"
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let cdstore = CoreDataStore()
        let cdh = CoreDataHelper(store: cdstore)
        context = cdh.managedObjectContext
        
        var db = NewPhotoDBManager(context: context!)
        self.photoCount.text = "\(db.numberOfNewPhotos())"
        
        var switchPhotoLibrary = UISwitch(frame: CGRectMake(227,8,79,27))
        photoLibraryCell.textLabel!.text = "照片库"
        photoLibraryCell.accessoryView = switchPhotoLibrary
        photoLibraryCell.selectionStyle = .None;
        
        var switchDropbox = UISwitch(frame: CGRectMake(227,8,79,27))
        dropboxCell.textLabel!.text = "Dropbox"
        dropboxCell.accessoryView = switchDropbox
        dropboxCell.selectionStyle = .None;
    }
}