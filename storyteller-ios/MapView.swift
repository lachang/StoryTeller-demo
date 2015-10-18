//******************************************************************************
//  MapView.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation
import MapKit

/**
 * MapView
 *
 * Manages common map functionality for a given map view.
 */

class MapView {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // The map view to manage.
    private var _mapView: MKMapView
    private var _mapSpan: MKCoordinateSpan? = nil
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    /**
     * Create new coordinates from a given coordinate, distance, and bearing.
     *
     * http://stackoverflow.com/questions/6633850/calculate-new-coordinate-x-meters-and-y-degree-away-from-one-coordinate
     *
     * - parameter fromCoord: The coordinate to base the new coordinate off of
     * - parameter distanceInMeters: The distance from the given coordinate
     * - parameter atBearingDegrees: The bearing degrees from the given
     *                                coordinate
     *
     * - returns: The new coordinates
     */
    
    class func coordinateFromCoord(fromCoord: CLLocationCoordinate2D,
        distanceInMeters: Double,
        atBearingDegrees: Double) -> CLLocationCoordinate2D {
            
        //6,371,000 = Earth's radius in meters
        let distanceRadians = distanceInMeters / 6371000.0
        
        let bearingRadians = self._radiansFromDegrees(atBearingDegrees)
        let fromLatRadians = self._radiansFromDegrees(fromCoord.latitude)
        let fromLonRadians = self._radiansFromDegrees(fromCoord.longitude)
        
        let toLatRadians = asin( sin(fromLatRadians) * cos(distanceRadians) +
            cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) )
        
        var toLonRadians = fromLonRadians + atan2(sin(bearingRadians) *
            sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians) -
                sin(fromLatRadians) * sin(toLatRadians))
        
        // adjust toLonRadians to be in the range -180 to +180...
        toLonRadians = fmod((toLonRadians + 3*M_PI), (2*M_PI)) - M_PI
        
        let result = CLLocationCoordinate2DMake(
            self._degreesFromRadians(toLatRadians),
            self._degreesFromRadians(toLonRadians))
        
        return result
    }
    
    //**************************************************************************
    // MARK: Class Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Private)
    //**************************************************************************
    
    class private func _radiansFromDegrees(degrees: Double) -> Double {
        return degrees * (M_PI/180.0)
    }
    
    class private func _degreesFromRadians(radians: Double) -> Double {
        return radians * (180.0/M_PI)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Initialize a new map.
     *
     * - parameter mapView: The map view to manage
     *
     * - returns: N/A
     */
    
    init (mapView: MKMapView) {
        
        // Cache off the map view to manage.
        self._mapView = mapView

        // Enable user location.
        self._mapView.showsUserLocation = true
    }

    /**
     * Add a single annotation to the map.
     *
     * - parameter annotation: The annotation to add.
     *
     * - returns: N/A
     */
    func addAnnotation (annotation: MKAnnotation) {
        self._mapView.addAnnotation(annotation)
    }
    
    /**
     * Add the given annotations to the map.
     *
     * - parameter annotations: The annotations to add.
     *
     * - returns: N/A
     */
    
    func addAnnotations (annotations: [MKAnnotation]) {
        self._mapView.addAnnotations(annotations)
    }
    
    /**
     * Remove all current annotations from the map.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    
    func removeAllAnnotations() {
        self._mapView.removeAnnotations(self._mapView.annotations)
    }

    /**
     * Display all current annotations on the map.
     *
     * - returns: N/A
     */
    
    func showAllAnnotations(showUserLocation showUserLocation: Bool) {
        
        // Return early if there are no annotations on the map.
        if (self._mapView.annotations.count == 0) {
            return
        }
        
//        self._mapView.showAnnotations(self._mapView.annotations, animated: true)
        // Initialize to a default bounding box.
        var topLeftLongitude:CLLocationDegrees     = 180
        var topLeftLatitude:CLLocationDegrees      = -90
        var bottomRightLongitude:CLLocationDegrees = -180
        var bottomRightLatitude:CLLocationDegrees  = 90

        var annotationsToShow: [MKAnnotation] = []
        if !showUserLocation {
            annotationsToShow = self._mapView.annotations.filter {
                $0 !== self._mapView.userLocation
            }
        }
        else {
            annotationsToShow = self._mapView.annotations
        }
        
        if annotationsToShow.count > 0 {
            for annotation in annotationsToShow {
                
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
            let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(centerLat, centerLng)
            
            // edge
            let latitudDelta   = fabs(topLeftLatitude - bottomRightLatitude) * 1.4
            let longitudeDelta = fabs(bottomRightLongitude - topLeftLongitude) * 1.4
            
            self._mapSpan = MKCoordinateSpan(latitudeDelta: latitudDelta, longitudeDelta: longitudeDelta)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(center, self._mapSpan!)
            self._mapView.setRegion(region, animated: false)
        }
    }
    
    /**
     * Center the map on the given coordinate.
     *
     * - parameter coordinate: The coordinate upon which to center.
     *
     * - returns: N/A
     */
    
    func centerMap (coordinate: CLLocationCoordinate2D) {
        
        let regionRadius: CLLocationDistance = 5
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,
            regionRadius, regionRadius)
        
        self._mapView.setRegion(coordinateRegion, animated: true)
//        assert(self._mapSpan != nil)
//        var span = MKCoordinateSpan(latitudeDelta: fmin(self._mapSpan!.latitudeDelta,0.01),
//            longitudeDelta: fmin(self._mapSpan!.longitudeDelta,0.01))
//        // TODO we probaly want to zoom-in a little bit
//        var region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
//        self._mapView.setRegion(region, animated: true)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}