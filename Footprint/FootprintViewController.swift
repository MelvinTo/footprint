//
//  FirstViewController.swift
//  Footprint
//
//  Created by Melvin Tu on 4/3/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import UIKit
import MapKit
import GMImagePicker
import CoreData

class FootprintViewController: UITableViewController, GMImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    var imagePicker = UIImagePickerController()
    var fp : Footprint? = nil
    let reuseIdentifier: String = "footprintCell"
    var managedObjectContext = CoreDataHelper().managedObjectContext
    var _fetchedResultsController: NSFetchedResultsController?

    
    var fetchedResultsController: NSFetchedResultsController {
        // return if already initialized
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        let managedObjectContext = self.managedObjectContext!

        let entity = NSEntityDescription.entityForName("Path", inManagedObjectContext: managedObjectContext)
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        let req = NSFetchRequest()
        req.entity = entity
        req.sortDescriptors = [sort]
        
        /* NSFetchedResultsController initialization
        a `nil` `sectionNameKeyPath` generates a single section */
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        self._fetchedResultsController = aFetchedResultsController
        
        // perform initial model fetch
        var e: NSError?
        if !self._fetchedResultsController!.performFetch(&e) {
            println("fetch error: \(e!.localizedDescription)")
            abort();
        }
        
        return self._fetchedResultsController!
    }
    
//    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.tableView.allowsSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addBtnClicked(){
        var picker = GMImagePickerController()
        picker.delegate = self
        picker.colsInPortrait = 5
        picker.title = "选择照片来创建足迹"
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func assetsPickerController(picker: GMImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
//        self.dismissViewControllerAnimated(true, completion: { () -> Void in
//            var photos : [PhotoMetadata] = []
//            for asset in assets as! [PhotoObject] {
//                NSLog("image is \(asset), created at \(asset.timestamp), location: \(asset.location)")
//                var metadata = PhotoMetadata()
//                
//                if let location = asset.location {
//                    metadata.latitude = location.coordinate.latitude
//                    metadata.longitude = location.coordinate.longitude
//                } else {
//                    metadata.latitude = 39.908747
//                    metadata.longitude = 116.397410
//                }
//                
//                metadata.timestamp = asset.creationDate
//                metadata.url = "\(asset.localIdentifier)"
//                photos.append(metadata)
//            }
//            var footprint = Footprint(name: "test")
//            footprint.photos = photos
//            
//            NSLog("A new footprint is created: \(footprint)")
//            self.fp = footprint
//            self.performSegueWithIdentifier("PathCreate", sender: self)
//        })
    }
    
    func assetsPickerControllerDidCancel(picker: GMImagePickerController!) {
        NSLog("Image picker is cancelled")
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in

        })
        
        NSLog("image is \(image.description)")
//        imageView.image = image
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PathCreate" {
            
            let managedObjectContext = self.fetchedResultsController.managedObjectContext
            let path = NSEntityDescription.insertNewObjectForEntityForName("Path", inManagedObjectContext: managedObjectContext) as! Path
            
            let nav = segue.destinationViewController as! UINavigationController
            let add = nav.topViewController as! PathCreateViewController
            add.path = path
            let fpVC = sender as! FootprintViewController
            add.fp = fpVC.fp
            fpVC.fp = nil
            
            add.didCancel = { cont in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            add.didFinish = { cont in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else if segue.identifier == "viewPath" {
            if let fpVC = sender as? FootprintViewController {
                let fp = fpVC.fp
                
                let pathViewController = segue.destinationViewController as! PathViewController
                pathViewController.fp = fp
            }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        NSLog("number of rows: \(info.numberOfObjects)")
        return info.numberOfObjects
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! FootprintCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: FootprintCell, indexPath: NSIndexPath) {
        let path = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Path
        let footprint = path.toFootprint()
        cell.footprint = footprint
        cell.footprint?.updateMap(cell.mapView)
        cell.label.text = path.name
        cell.cellDidLoad()
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
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? FootprintCell {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let path = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Path
        let footprint = path.toFootprint()
        self.fp = footprint
        self.performSegueWithIdentifier("viewPath", sender: self)
    }
}

