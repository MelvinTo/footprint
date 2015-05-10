//
//  PhotoMapViewController.swift
//  Footprint
//
//  Created by Melvin Tu on 4/16/15.
//  Copyright (c) 2015 Melvin Tu. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Array {
    func find(includedElement: T -> Bool) -> Int? {
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}

class PhotoMapViewController : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    var allPhotosMapView: MKMapView = MKMapView(frame: CGRectZero)
    var fetchRequest: NSFetchRequest = NSFetchRequest(entityName:"NewPhoto")
    var managedContext = CoreDataHelper().managedObjectContext

    let reuseIdentifier = "photoCell"
    var userLocation : CLLocation? = nil
    var locationManager : CLLocationManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // request to get user location
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()

        self.title = "PhotoMapViewController".localized
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        dispatch_async(dispatch_get_main_queue(), {
            self.loadExistingPhotos()
            self.updateVisibleAnnotations()
        })
    }
    
    func loadExistingPhotos() {
        // load all existing photos
        if let mc = managedContext {
            var error: NSError? = nil
            let fetchedResults = mc.executeFetchRequest(fetchRequest, error: &error) as? [NewPhoto]
            
            if let e = error {
                NSLog("Got error when loading all photos from Core Data database: \(e)")
            } else {
                var annotations : [PhotoAnnotation] = []

                for newPhoto in fetchedResults! {
                    let photoObject = PhotoObject.fromNewPhoto(newPhoto)
                    let pa = PhotoAnnotation(photo: photoObject)
                    annotations.append(pa)
                }
                
                allPhotosMapView.addAnnotations(annotations)
            }
        }
    }
    
    @IBAction func locationButtonTapped() {
        NSLog("zoom back to user current location")
        if let l = userLocation {
            mapView.setRegion(MKCoordinateRegionMake(l.coordinate, MKCoordinateSpanMake(0.5, 0.5)), animated: true)
        } else {
            NSLog("user location is not available")
        }
    }
    
    func updateVisibleAnnotations() {
        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor = 2.0
        
        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize = 60.0

        // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
        let visibleMapRect = self.mapView.visibleMapRect
        let adjustedVisibleMapRect = MKMapRectInset(visibleMapRect,
                                                    -marginFactor * visibleMapRect.size.width,
                                                    -marginFactor * visibleMapRect.size.height)

        // determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = self.mapView.convertPoint(CGPointZero, toCoordinateFromView: self.view)
        let rightCoorindate = self.mapView.convertPoint(CGPointMake(CGFloat(bucketSize), 0), toCoordinateFromView: self.view)
        let gridSize = MKMapPointForCoordinate(rightCoorindate).x - MKMapPointForCoordinate(leftCoordinate).x
        
        if gridSize < 0 { // it's a bug if gridSize is less than zero
            return
        }
        
        var gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize)
        
        // condense annotations, with a padding of two squares, around the visibleMapRect
        let startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize
        let startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize
        let endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize
        let endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize
        
        // for each square in our grid, pick one annotation to show
        gridMapRect.origin.y = startY
        while (MKMapRectGetMinY(gridMapRect) <= endY) {
            gridMapRect.origin.x = startX
            while (MKMapRectGetMinX(gridMapRect) <= endX) {
                clusterAnnotations(gridMapRect)
                gridMapRect.origin.x += gridSize
            }
            gridMapRect.origin.y += gridSize
        }
        
    }
    
    // for each square, pick one annotation to show
    func clusterAnnotations(rect: MKMapRect) {
//        NSLog("call clusterAnnotations")
        
        let allAnnotationsInRect = self.allPhotosMapView.annotationsInMapRect(rect)
        if allAnnotationsInRect == nil {
            return
        }
        
        let photoAnnotations = Array(allAnnotationsInRect).filter() { $0 is PhotoAnnotation } as! [PhotoAnnotation]
        let visibleAnnotationsInRect = self.mapView.annotationsInMapRect(rect)
        let visiblePhotoAnnotations = Array(visibleAnnotationsInRect).filter() { $0 is PhotoAnnotation } as! [PhotoAnnotation]
        
//        for visibleAnnotation in visiblePhotoAnnotations {
//            NSLog("visible: \(visibleAnnotation)")
//        }
        
        if photoAnnotations.count > 0 {
            let annotation = createClusteredAnnotation(rect, annotations: photoAnnotations)
            
            let findResult = mapView.annotations.find { $0 as! NSObject === annotation }
            
            if findResult == nil {
//                NSLog("Add annotation to map: \(annotation)")
                self.mapView.addAnnotation(annotation)
            }
            
            // give the annotationForGrid a reference to all the annotations it will represent
            let otherAnnotations = photoAnnotations.filter { $0 !== annotation }
            
            annotation.containedAnnotations = otherAnnotations
            
            for eachAnnotation in otherAnnotations {
                eachAnnotation.clusterAnnocation = annotation
                eachAnnotation.containedAnnotations = nil
                
                // remove annotations which we've decided to cluster
                if visibleAnnotationsInRect.contains(eachAnnotation) {
//                    NSLog("Remove annotation from map: \(annotation)")
//                    self.mapView.removeAnnotation(eachAnnotation)
                    
                    let actualCoordinate = eachAnnotation.coordinate
//                    NSLog("animating removing annotation: \(eachAnnotation)")
                    UIView.animateWithDuration(0.3, animations: {
                        eachAnnotation.coordinate = eachAnnotation.clusterAnnocation!.coordinate
                        }, completion: { finished in
                            eachAnnotation.coordinate = actualCoordinate
//                            NSLog("Remove annotation from map: \(annotation)")
                            self.mapView.removeAnnotation(eachAnnotation)
                    })
                }

            }
        }
    }
    
    func createClusteredAnnotation(rect: MKMapRect, annotations: [PhotoAnnotation]) -> PhotoAnnotation {
        let visibleAnnotationsInRect = self.mapView.annotationsInMapRect(rect)
        let matchedAnnotations = annotations.filter() { visibleAnnotationsInRect.contains($0) }
        
        if matchedAnnotations.count > 0 {
//            NSLog("annotation \(matchedAnnotations[0]) is already visible")
            return matchedAnnotations[0]
        }
        
        // otherwise, sort the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPointMake(MKMapRectGetMidX(rect), MKMapRectGetMidY(rect))
        
        let sortedAnnotations = annotations.sorted {
            let point0 = MKMapPointForCoordinate($0.coordinate)
            let point1 = MKMapPointForCoordinate($1.coordinate)
            let distance0 = MKMetersBetweenMapPoints(point0, centerMapPoint)
            let distance1 = MKMetersBetweenMapPoints(point1, centerMapPoint)
            return distance0 < distance1
        }
        
//        NSLog("annotation \(sortedAnnotations[0]) is selected to represent this cluster")
        return sortedAnnotations[0]
    }
    
    func loadImage(cell: PhotoCollectionCell, indexPath: NSIndexPath) {
//        var imageView = cell.imageView
//        let retinaMultiplier = UIScreen.mainScreen().scale
//        let index = indexPath.indexAtPosition(1)
//        var photo = fetchAssetsResult?.objectAtIndex(index) as! PHAsset
//        
//        var retinaSquare = CGSizeMake(imageView.bounds.size.width * retinaMultiplier, imageView.bounds.size.height * retinaMultiplier)
//        
//        var requestOptions = PHImageRequestOptions()
//        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.Exact
//        
//        imageManager?.requestImageForAsset(photo,
//                                                targetSize: retinaSquare,
//                                                contentMode: PHImageContentMode.AspectFill,
//                                                options: requestOptions,
//                                                resultHandler: { (image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
//            imageView.image = image
//        })
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        NSLog("regionDidChangeAnimated is called")
        dispatch_async(dispatch_get_main_queue()) {
            self.updateVisibleAnnotations()
//            self.mapView.setRegion(self.mapView.region, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        for annotationView in views {
            if annotationView.annotation is PhotoAnnotation {
                let annotation = annotationView.annotation as! PhotoAnnotation
                
                // animate the annotation from it's old container's coordinate, to its actual coordinate

                if let ca = annotation.clusterAnnocation {
                    let actual = annotation.coordinate
                    let cluster = ca.coordinate
                    
                    // since it's displayed on the map, it is no longer contained by another annotation,
                    // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
                    // to get the containerCoordinate)
                    
                    annotation.clusterAnnocation = nil
                    annotation.coordinate = cluster

                    NSLog("Animated adding annotations: \(annotation)")
                    UIView.animateWithDuration(0.3, animations: {
                        annotation.coordinate = actual
                    })
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        NSLog("viewForAnnotation is called")
        
        let annotationIdentifier = "PhotoAnnotation"
        
        if mapView != self.mapView {
            return nil
        }
        
        if annotation is PhotoAnnotation {
            var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            annotationView!.canShowCallout = true
//            annotationView!.animatesDrop = true
            
            let button: AnyObject = UIButton.buttonWithType(.DetailDisclosure)
            annotationView!.rightCalloutAccessoryView = button as! UIView
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? PhotoAnnotation {
            let photos = [annotation.photo!] + annotation.containedAnnotations!.map { $0.photo! }
            let sortedPhotos = photos.sorted { $0.timestamp.isLessThanDate($1.timestamp) }
            let photoViewController = PhotoViewController()
            photoViewController.photos = sortedPhotos
            photoViewController.theStoryboard = self.storyboard
            self.showDetailViewController(photoViewController, sender: self)
//            self.showViewController(photoViewController, sender: self)
//            self.navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        NSLog("annotation \(view.annotation) selected")
        if view.annotation is PhotoAnnotation {
            let annotation = view.annotation as! PhotoAnnotation
            annotation.updateTitleIfNeeded()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let oldUserLocation = userLocation
        userLocation = (locations[0] as! CLLocation)
        if oldUserLocation == nil {
            let newRegion = MKCoordinateRegionMake(userLocation!.coordinate, MKCoordinateSpanMake(1.0, 1.0))
            self.mapView.region = newRegion
        }
    }
}

