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
    @IBOutlet weak var cleanDatabaseButton: UIButton!
    @IBOutlet weak var boxCell: UITableViewCell!
    
    var photosConnector = PhotosConnector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update texts
        self.title = "settingsViewController.title".localized
        self.cleanDatabaseButton.setTitle("cleanDatabaseButton".localized, forState: .Normal)
        
        reloadStats()
        
//        var switchPhotoLibrary = UISwitch(frame: CGRectMake(227,8,79,27))
//        photoLibraryCell.textLabel!.text = "照片库"
//        photoLibraryCell.accessoryView = switchPhotoLibrary
//        photoLibraryCell.selectionStyle = .None;
//        
//        var switchDropbox = UISwitch(frame: CGRectMake(227,8,79,27))
//        dropboxCell.textLabel!.text = "Dropbox"
//        dropboxCell.accessoryView = switchDropbox
//        dropboxCell.selectionStyle = .None;
        
        // Register notifications for photo change
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:"handlePhotoChange:", name: NSManagedObjectContextDidSaveNotification, object: context)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("ViewDidAppear is called")
        reloadStats()
    }
    
    func reloadStats() {
        var context = CoreDataHelper.getSharedCoreDataHelper().managedObjectContext
        var db = NewPhotoDBManager(context: context!)
        context?.performBlock({ () -> Void in
            self.photoCount.text = "\(db.numberOfNewPhotos())"
            
            let numberOfPhotosFromPhotoLibrary = db.numberOfPhotos("Photos")
            let numberOfPhotosFromDropbox = db.numberOfPhotos("Dropbox")
            let numberOfPhotosFromBox = db.numberOfPhotos("Box")
            self.photoLibraryCell.detailTextLabel!.text = "\(numberOfPhotosFromPhotoLibrary)"
            self.dropboxCell.detailTextLabel!.text = "\(numberOfPhotosFromDropbox)"
            self.boxCell.detailTextLabel!.text = "\(numberOfPhotosFromBox)"
        })
    }
    
    func handlePhotoChange(notification: NSNotification) {
        // reload number of photos whenever there is any change to Core Data
        
        reloadStats()
    }
    
    @IBAction func cleanDatabase() {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        var deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) -> Void in
            var context = CoreDataHelper.getSharedCoreDataHelper().managedObjectContext
            var db = NewPhotoDBManager(context: context!)
            let result = db.deletePhotos()
            if result {
                NSLog("All photos are deleted successfully")
            } else {
                NSLog("Failed to delete all photos")
            }
            
            var hashDB = FolderHashCoreData(context: context!)
            let result2 = hashDB.deleteHashes()
            if result2 {
                NSLog("All hashes are deleted successfully")
            } else {
                NSLog("Failed to delete all hashes")
            }
        }
        
        var cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "connectorConfig" {
            var connectorConfigViewController = segue.destinationViewController as! ConnectorConfigViewController
            if let cell = sender as? UITableViewCell {
                let source = "Photos"
                connectorConfigViewController.connector = ConnectorManager.getSharedConnectorManager().findConnectorManager(source)
            }
        } else if segue.identifier == "connectorConfigDropbox" {
            var connectorConfigViewController = segue.destinationViewController as! ConnectorConfigViewController
            if let cell = sender as? UITableViewCell {
                let source = "Dropbox"
                connectorConfigViewController.connector = ConnectorManager.getSharedConnectorManager().findConnectorManager(source)
            }
        }
    }
}