//
//  PhotoMapViewController.swift
//  Footprint
//
//  Created by Melvin Tu on 4/16/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

class PhotoMapViewController : UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifier = "photoCell"
    var fetchAssetsResult: PHFetchResult? = nil
    var imageManager: PHCachingImageManager? = nil
    
    deinit {
        resetCachedAssets()
    }
    
    func resetCachedAssets() {
        if let i = imageManager {
            i.stopCachingImagesForAllAssets()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.registerNib(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceVertical = true

        
        var options = PHFetchOptions()
        var sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchAssetsResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: options)
        println(fetchAssetsResult!.count)
        
        imageManager = PHCachingImageManager()
    }
    
    func loadImage(cell: PhotoCollectionCell, indexPath: NSIndexPath) {
        var imageView = cell.imageView
        let retinaMultiplier = UIScreen.mainScreen().scale
        let index = indexPath.indexAtPosition(1)
        var photo = fetchAssetsResult?.objectAtIndex(index) as! PHAsset
        
        var retinaSquare = CGSizeMake(imageView.bounds.size.width * retinaMultiplier, imageView.bounds.size.height * retinaMultiplier)
        
        var requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.Exact
        
        imageManager?.requestImageForAsset(photo,
                                                targetSize: retinaSquare,
                                                contentMode: PHImageContentMode.AspectFill,
                                                options: requestOptions,
                                                resultHandler: { (image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
            imageView.image = image
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            println(fetchAssetsResult!.count)
            return fetchAssetsResult!.count
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
        loadImage(cell, indexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.indexAtPosition(1)
    }
}

