//******************************************************************************
//  MapSnapshot.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation
import MapKit

/**
 * MapSnapshot
 *
 * Manages common functionality to create and manage a map snapshot image.
 */

class MapSnapshot {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // The image view to use for the map snapshot.
    private var _imageView: UIImageView
    
    // The array of annotations to show on the snapshot.
    private var _annotations: [MKAnnotation]
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Private)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Initialize a new map snapshot.
     *
     * :param: imageView The image view to use for the map snapshot
     *
     * :returns: N/A
     */
    
    init (imageView: UIImageView) {
        
        // Cache off the image view to manage.
        self._imageView = imageView
        
        // Initialize the annotations array as empty.
         self._annotations = []
    }
    
    /**
     * Add the given annotations to the map snapshot.
     *
     * :param: annotations The annotations to add.
     *
     * :returns: N/A
     */
    
    func addAnnotations (annotations: [MKAnnotation]) {
        self._annotations += annotations
    }
    
    /**
     * Remove all current annotations from the map snapshot.
     *
     * :param: N/A
     *
     * :returns: N/A
     */
    
    func removeAllAnnotations() {
        self._annotations.removeAll(keepCapacity: true)
    }
    
    /**
     * Display all current annotations on the map snapshot.
     *
     * :param: N/A
     *
     * :returns: N/A
     */
    
    func showAllAnnotations() {

        // Return early if there are no annotations on the map.
        if (self._annotations.count == 0) {
            return
        }

        // Initialize to a default bounding box.
        var topLeftLongitude:CLLocationDegrees     = 180
        var topLeftLatitude:CLLocationDegrees      = -90
        var bottomRightLongitude:CLLocationDegrees = -180
        var bottomRightLatitude:CLLocationDegrees  = 90
        
        for annotation in self._annotations {
            
            let coordinate = annotation.coordinate
            
            // Update the bounding box, if necessary.
            topLeftLongitude     = fmin(topLeftLongitude, coordinate.longitude)
            topLeftLatitude      = fmax(topLeftLatitude,  coordinate.latitude)
            bottomRightLongitude = fmax(bottomRightLongitude, coordinate.longitude)
            bottomRightLatitude  = fmin(bottomRightLatitude,  coordinate.latitude)
        }
        
        // center point
        let centerLat = topLeftLatitude - (topLeftLatitude - bottomRightLatitude) * 0.5
        let centerLng = topLeftLongitude + (bottomRightLongitude - topLeftLongitude) * 0.5
        let center:CLLocationCoordinate2D =
        CLLocationCoordinate2DMake(centerLat, centerLng)
        
        // edge
        let latitudDelta   = fabs(topLeftLatitude - bottomRightLatitude) * 1.4
        let longitudeDelta = fabs(bottomRightLongitude - topLeftLongitude) * 1.4
        let mapSpan        = MKCoordinateSpan(latitudeDelta: latitudDelta,
            longitudeDelta: longitudeDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(center,
            mapSpan)

        let options = MKMapSnapshotOptions()
        options.region = region
        options.size   = self._imageView.frame.size
        options.scale  = UIScreen.mainScreen().scale
        let mapSnapshotter = MKMapSnapshotter(options: options)
        mapSnapshotter.startWithCompletionHandler({(snapshot, error) -> Void in
            
            if error != nil {
                // TODO: Set an error placeholder.
            }
            else {
                let annotationView = MKPinAnnotationView(annotation: nil,
                    reuseIdentifier: nil)
                let snapshotImage: UIImage = snapshot!.image
                
                // Composite the snapshot with the annotation.
                UIGraphicsBeginImageContextWithOptions(snapshotImage.size, true,
                    snapshotImage.scale)
                snapshotImage.drawAtPoint(CGPointZero)
                
                for annotation in self._annotations {
                    let coordinatePoint =
                    snapshot!.pointForCoordinate(annotation.coordinate)
                    annotationView.image!.drawAtPoint(coordinatePoint)
                }
                let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                dispatch_async(dispatch_get_main_queue()) {
                    self._imageView.image = compositeImage
                }
            }
        })
    }
    
    /**
     * Center the map snapshot on the given coordinate.
     *
     * :param: coordinate The coordinate upon which to center.
     *
     * :returns: N/A
     */
    
    func centerMap (coordinate: CLLocationCoordinate2D) {
        
        let regionRadius: CLLocationDistance = 100
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,
            regionRadius, regionRadius)
        
        
        let options = MKMapSnapshotOptions()
        options.region = coordinateRegion
        options.size   = self._imageView.frame.size
        options.scale  = UIScreen.mainScreen().scale
        let mapSnapshotter = MKMapSnapshotter(options: options)
        mapSnapshotter.startWithCompletionHandler({(snapshot, error) -> Void in
            
            if error != nil {
                // TODO: Set an error placeholder.
            }
            else {
                let annotationView = MKPinAnnotationView(annotation: nil,
                    reuseIdentifier: nil)
                let coordinatePoint = snapshot!.pointForCoordinate(coordinate)
                let snapshotImage: UIImage = snapshot!.image
                
                // Composite the snapshot with the annotation.
                UIGraphicsBeginImageContextWithOptions(snapshotImage.size, true,
                    snapshotImage.scale)
                snapshotImage.drawAtPoint(CGPointZero)
                annotationView.image!.drawAtPoint(coordinatePoint)
                let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                dispatch_async(dispatch_get_main_queue()) {
                    self._imageView.image = compositeImage
                }
            }
        })
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}