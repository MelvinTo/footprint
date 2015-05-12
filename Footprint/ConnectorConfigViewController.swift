//
//  ConnectorConfigViewController.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/10/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import CoreData

import Foundation

class ConnectorConfigViewController : UITableViewController {
    var connector: Connector? = nil
    
    @IBOutlet weak var manualSyncButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "connector.\(connector!.name)".localized
        self.manualSyncButton.setTitle("connectorConfigViewController.manualSync".localized, forState: .Normal)
    }
    
    @IBAction func syncManually() {
        if let c = connector {
            
            
            self.manualSyncButton.setTitle("ConnectorConfigViewController.SYNCING".localized, forState: .Normal)
            self.progressBar.hidden = false
            self.progressBar.progress = 0.0

            var queue = dispatch_queue_create("storePhotos", DISPATCH_QUEUE_SERIAL)
            dispatch_async(queue) {

                var ctxt = CoreDataHelper.getSharedCoreDataHelper().backgroundContext
                
                // Register notifications for photo change
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"handlePhotoSave:", name: NSManagedObjectContextDidSaveNotification, object: ctxt)

                
                ConnectorManager.getSharedConnectorManager().storeNewPhotos(c, context: ctxt!, progress: { progress in
                        self.progressBar.setProgress(progress, animated: true)
                    }) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.manualSyncButton.setTitle("ConnectorConfigViewController.SYNC".localized, forState: .Normal)
                        self.manualSyncButton.setNeedsDisplay()
                        self.progressBar.setProgress(1.0, animated: true)
                        self.progressBar.hidden = true
                        self.progressBar.setNeedsDisplay()
                    }
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
}