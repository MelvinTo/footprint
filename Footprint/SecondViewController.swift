//
//  SecondViewController.swift
//  Footprint
//
//  Created by Melvin Tu on 4/3/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, PhotoLoaderDelegate {

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func scanPhotos(sender: UIButton) {
        NSLog("scanning photos")
        button.setTitle("Scanning", forState: UIControlState.Normal)
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            println("This is run on the background queue")
        
            var loader : PhotoLoader = PhotoLoader()
            loader.delegate = self
            loader.loadPhotos()
        })
    }
    
    @IBAction func countPhotos(sender: UIButton) {
        var store = PhotoStore()
        NSLog("Photo count: \(store.countPhotos())")
        NSLog("Path count: \(store.countPaths())")
    }
    
    @IBAction func resetPhotos(sender: UIButton) {
        var store = PhotoStore()
        store.resetPhotos()
    }
    
    func loadPhotoComplete(loader: PhotoLoader) {
        button.setTitle("Complete", forState: UIControlState.Normal)
        NSLog("Scanning is complete")
    }
}

