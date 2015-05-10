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
    var managedContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var manualSyncButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func syncManually() {
        if let c = connector {
            
            
            self.manualSyncButton.setTitle("ConnectorConfigViewController.SYNCING".localized, forState: .Normal)
            self.progressBar.hidden = false
            self.progressBar.progress = 0.0

            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0)) {
                ConnectorManager.getSharedConnectorManager().storeNewPhotos(c, context: self.managedContext!, progressBar: self.progressBar) {
                    self.manualSyncButton.setTitle("ConnectorConfigViewController.SYNC".localized, forState: .Normal)
                    self.manualSyncButton.setNeedsDisplay()
                    self.progressBar.hidden = true
                    self.progressBar.setNeedsDisplay()
                }
            }
        }
    }
}