//
//  PhotoViewController.swift
//  Footprint
//
//  Created by Melvin Tu on 4/19/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit

class PhotoModelController : NSObject, UIPageViewControllerDataSource {
    var pageData : [PHAsset] = []
    var currentIndex: Int = 0
    
    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> PhotoDataViewController? {
        if pageData.count == 0 || index >= pageData.count {
            return nil
        }
        
        var photoDataViewController = storyboard.instantiateViewControllerWithIdentifier("PhotoDataViewController") as! PhotoDataViewController
        photoDataViewController.dataObject = pageData[index]
        return photoDataViewController
    }
    
    func indexOfViewController(viewController : PhotoDataViewController) -> Int {
        return pageData.find { $0 == viewController.dataObject! }!
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let photoViewController = pageViewController.delegate as! PhotoViewController
        
        // we are still animating don't return a previous view controller too soon
        if photoViewController.pageAnimationFinished == false {
            return nil
        }
        
        var index = self.indexOfViewController(viewController as! PhotoDataViewController)
        if index == 0 || index == NSNotFound {
            // we are at the first page, don't go back any further
            NSLog("we are at the first page, don't go back any further")
            return nil
        }
        
        index--
        currentIndex = index
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let photoViewController = pageViewController.delegate as! PhotoViewController
        
        // we are still animating don't return a previous view controller too soon
        if photoViewController.pageAnimationFinished == false {
            return nil
        }
        
        var index = self.indexOfViewController(viewController as! PhotoDataViewController)
        if index == NSNotFound {
            // we are at the last page, don't go any further
            NSLog("we are at the last page, don't go back any further")
            return nil
        }
        
        index++
        currentIndex = index
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
}

class PhotoDataViewController : UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var location: UILabel!

    var dataObject : PHAsset? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = dataObject?.localIdentifier
        self.loadImage()
        self.updateLocation()
    }
    
    func loadImage() {
        let retinaMultiplier = UIScreen.mainScreen().scale
        
        var retinaSquare = CGSizeMake(imageView.bounds.size.width * retinaMultiplier, imageView.bounds.size.height * retinaMultiplier)
        
        dispatch_async(dispatch_get_main_queue(), {
            println("Getting image \(self.dataObject!.localIdentifier) with background queue")
            
            var manager = PHImageManager.defaultManager()
            manager.requestImageForAsset(self.dataObject, targetSize: retinaSquare, contentMode: PHImageContentMode.AspectFit, options: nil, resultHandler: { (image : UIImage!, info:[NSObject : AnyObject]!) -> Void in
                    self.imageView.image = image
                    self.imageView.clipsToBounds = true

            })
        })
    }
    
    func updateLocation() {
        if let l = dataObject?.location {
            CLGeocoder().reverseGeocodeLocation(l, completionHandler: { (placemarks, error) -> Void in
                if placemarks.count > 0 {
                    let placemark = placemarks[0] as! CLPlacemark
//                    let aoi = placemark!.areasOfInterest
                    
                    self.location.text = placemark.toString()
                    self.location.hidden = false
                }
            })
        }
    }
    
//    func applyBlurOnLabel() {
//        if !UIAccessibilityIsReduceTransparencyEnabled() {
//            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//            let blurEffectView = UIVisualEffectView(effect: blurEffect)
//            self.location.frame
//            blurEffectView.frame = self.location.bounds //view is self.view in a UIViewController
//            NSLog("blurEffectView size: \(blurEffectView.frame)")
//            self.view.addSubview(blurEffectView)
//            //if you have more UIViews on screen, use insertSubview:belowSubview: to place it underneath the lowest view
//            
////            //add auto layout constraints so that the blur fills the screen upon rotating device
////            blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
////            view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
////            view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
////            view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
////            view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
//        } else {
//            view.backgroundColor = UIColor.blackColor()
//        }
//    }

}

class PhotoViewController : UIViewController, UIPageViewControllerDelegate {
    
    var pageViewController : UIPageViewController? = nil
    var theStoryboard : UIStoryboard? = nil
    lazy var modelController : PhotoModelController = PhotoModelController()
    var pageAnimationFinished : Bool = true
    var photos: [PHAsset]? = nil
    
    override func viewDidLoad() {
        NSLog("viewDidLoad is called with \(photos!.count) photos")
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        self.modelController.pageData = self.photos!
        
        let startingViewController = self.modelController.viewControllerAtIndex(0, storyboard: theStoryboard!)! as UIViewController
        var viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        self.updateNavBarTitle()
        
        self.pageViewController?.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController?.didMoveToParentViewController(self)
        
        // add the page view controller's gesture recognizers to the book view controller's view
        // so that the gestures are started more easily
        self.view.gestureRecognizers = self.pageViewController?.gestureRecognizers
        
        // add tap gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func respondToTapGesture(tr: UITapGestureRecognizer) {
//        let curPhoto = self.modelController.pageData[modelController.currentIndex]
//        NSLog("Tap on photo \(curPhoto.localIdentifier)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateNavBarTitle() {
        if modelController.pageData.count > 1 {
            self.title = "Photos (\(modelController.currentIndex + 1) of \(modelController.pageData.count))"
        } else {
            let photo = self.modelController.pageData[modelController.currentIndex]
            self.title = photo.localIdentifier
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        
        // update the nav bar title showing which index we are displaying
        self.updateNavBarTitle()
        
        self.pageAnimationFinished = true
    }
    
    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    
        let curViewController = pageViewController.viewControllers[0] as! UIViewController
        let viewControllers = [curViewController]
        pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.pageViewController?.doubleSided = false
        return UIPageViewControllerSpineLocation.Min
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        self.pageAnimationFinished = false
    }
    
}