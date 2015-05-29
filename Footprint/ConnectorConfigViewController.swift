//
//  ConnectorConfigViewController.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/10/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import CoreData

import Foundation

class ConnectorConfigViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    var connector: Connector? = nil
    var context: NSManagedObjectContext? = nil
    var syncStatusDB: SyncStatusDB? = nil
    var resultController: NSFetchedResultsController? = nil
    let reuseIdentifier = "syncStatus"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "connector.\(connector!.name)".localized
//        self.manualSyncButton.setTitle("connectorConfigViewController.manualSync".localized, forState: .Normal)
                
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "syncManually")
        
        context = CoreDataHelper.getSharedCoreDataHelper().managedObjectContext
        if let c = context {
            syncStatusDB = SyncStatusDB(context: c)
            if let s = syncStatusDB {
                resultController = s.getFetchedResultsController(self)
            }
        }
        
    }
    
    func syncManually() {
        if let c = connector {

            var queue = dispatch_queue_create("storePhotos", DISPATCH_QUEUE_SERIAL)
            dispatch_async(queue) {

                var ctxt = CoreDataHelper.getSharedCoreDataHelper().backgroundContext
                
                // Register notifications for photo change
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"handlePhotoSave:", name: NSManagedObjectContextDidSaveNotification, object: ctxt)

                self.title = "ConnectorConfigViewController.SYNCING".localized
                
                ConnectorManager.getSharedConnectorManager().storeNewPhotos(c, context: ctxt!, progress: { progress in
                    
                    }) {
                }
            }
        }
    }
    
    func handlePhotoSave(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            var mainContext = CoreDataHelper.getSharedCoreDataHelper().managedObjectContext
            mainContext?.mergeChangesFromContextDidSaveNotification(notification)
        })
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.resultController!.sections![section] as! NSFetchedResultsSectionInfo
        NSLog("number of rows: \(info.numberOfObjects)")
        return info.numberOfObjects
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! SyncStatusCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func getDateString(date: NSDate) -> String {
        var df = NSDateFormatter()
        df.dateStyle = .ShortStyle
        df.doesRelativeDateFormatting = true
        var dateString = df.stringFromDate(date)
        
        df.timeStyle = .MediumStyle
        df.dateStyle = .NoStyle
        var timeString = df.stringFromDate(date)
        
        var string = "added \(dateString) at: \(timeString)"
        return string
    }
    
    func configureCell(cell: SyncStatusCell, indexPath: NSIndexPath) {
        let item = self.resultController!.objectAtIndexPath(indexPath) as! SyncStatus
        cell.selected = false
        cell.userInteractionEnabled = false
        cell.textLabel?.text = item.identifier
        cell.detailTextLabel?.text = getDateString(item.createdDate)
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject object: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            case .Update:
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? SyncStatusCell {
                    self.configureCell(cell, indexPath: indexPath!)
                    self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            case .Move:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 350
    }
}