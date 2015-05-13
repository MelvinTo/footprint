//
//  DropboxConfigViewController.swift
//  足迹地图
//
//  Created by Melvin Tu on 5/13/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation

class DropboxConfigViewController : UIViewController {
    
    @IBOutlet weak var linkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var connector = DropboxConnector.getSharedDropboxConnector()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"dropboxLinked:", name: DropboxConnector.linkNotification, object: nil)
        
        if DBSession.sharedSession().isLinked() {
            self.linkButton.setTitle("DROPBOX.UNLINK".localized, forState: .Normal)
        } else {
            self.linkButton.setTitle("DROPBOX.LINK".localized, forState: .Normal)
        }
    }
    
    func dropboxLinked(notification: NSNotification) {
        self.linkButton.setTitle("DROPBOX.UNLINK".localized, forState: .Normal)
    }
    
    @IBAction func linkButtonClicked(sender: AnyObject) {
        if !DBSession.sharedSession().isLinked() {
            // to link
            DBSession.sharedSession().linkFromController(self)
        } else {
            // to unlink
            var alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            var deleteAction = UIAlertAction(title: "DROPBOX.UNLINK".localized, style: .Destructive) { (action) -> Void in
                DBSession.sharedSession().unlinkAll()
                self.linkButton.setTitle("DROPBOX.LINK".localized, forState: .Normal)
            }
            
            var cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            self.presentViewController(alert, animated: true, completion: nil)

        }
    }
}