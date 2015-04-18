//
//  PathViewController.swift
//  Footprint
//
//  Created by Melvin Tu on 4/13/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

class PathViewController : UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "PhotoCollectionCell"

    var fp : Footprint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = fp!.name
        map.scrollEnabled = false
        map.zoomEnabled = false
        map.rotateEnabled = false

        fp!.updateMap(map)
        self.name.text = fp!.name
        
        self.collectionView.registerNib(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true
        
        println("nav frame height: \(self.navigationController?.navigationBar.frame.size.height)")
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
        // Configure the cell
        let index = indexPath.indexAtPosition(1)
        loadImage(cell, fp!.photos[index])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.indexAtPosition(1)
    }

}