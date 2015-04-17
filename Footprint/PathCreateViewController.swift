//
//  PathCreateViewController.swift
//  Footprint
//
//  Created by Melvin Tu on 4/6/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class PathCreateViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var name: UITextField!
    var fp : Footprint? = nil
    var path: Path? = nil
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifier = "PhotoCollectionCell"
    
    typealias DidCancelDelegate = (PathCreateViewController) -> ()
    typealias DidFinishDelegate = (PathCreateViewController) -> ()
    var didCancel: DidCancelDelegate?
    var didFinish: DidFinishDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "创建足迹"
        map.scrollEnabled = false
        map.zoomEnabled = false
        map.rotateEnabled = false
        scrollView.scrollEnabled = true

//        self.scrollView.contentSize = CGSize(width:500,height:1000)
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.contentSize = self.scrollView.frame.size
        println("scrollView contentSize: \(self.scrollView.contentSize)")

        
//        map.mapType = MKMapType.Satellite

        if let fp2 = fp {
            fp2.updateMap(map)
            self.name.text = fp2.name
        }
        
        self.collectionView.registerNib(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true
        
        println("nav frame height: \(self.navigationController?.navigationBar.frame.size.height)")
        
        let photos = fp?.photos
        if photos!.count > 0 {
            let p = photos![0]
            getPlaceMark(CLLocation(latitude: p.latitude.doubleValue, longitude: p.longitude.doubleValue))
        }
        
        aggregatePhotos(photos!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBar.translucent = false;
    }
    
    @IBAction func cancel() {
        // hide keyboard
        name.resignFirstResponder()
        
        /* delete model
        only _marks_ it for deletion */
        let path = self.path!
        let managedObjectContext = path.managedObjectContext!
        managedObjectContext.deleteObject(path)
        
        /* save `NSManagedObjectContext`
        deletes model from the persistent store (SQLite DB) */
        var e: NSError?
        if !managedObjectContext.save(&e) {
            println("cancel error: \(e!.localizedDescription)")
            abort()
        }
        
        // notify delegate (master list scene view controller)
        self.didCancel!(self)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return self.fp!.photos.count
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        NSLog("calling numberOfSectionsInCollectionView")
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionCell
        //cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        let index = indexPath.indexAtPosition(1)
        loadImage(cell, fp!.photos[index])

        return cell
    }
    
    func getPlaceMark(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            println(location)
            
            if error != nil {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            for placemark in placemarks {
                let pm = placemarks[0] as! CLPlacemark
                println(pm.locality)
                println(pm.subLocality)
                println(pm.region)
                println(pm.thoroughfare)
            }
        })
    }
    
    @IBAction func save() {
        // hide keyboard
        name.resignFirstResponder()
        
        // set `Item` `name`
        let path = self.path!
        path.name = name.text
        path.timestamp = NSDate()
        let managedObjectContext = path.managedObjectContext!
        
        for metadata in fp!.photos {
            var photo: Photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: managedObjectContext) as! Photo
            photo.copyFrom(metadata)
            photo.path = path
        }
        
        // save `NSManagedObjectContext`
        var e: NSError?
        if !managedObjectContext.save(&e) {
            println("finish error: \(e!.localizedDescription)")
            abort()
        }
        
        // notify delegate (master list scene view controller)
        self.didFinish!(self)
    }
}