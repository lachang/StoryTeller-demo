//******************************************************************************
//  LocationManager.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation
import CoreLocation

/**
 * LocationManager
 *
 * Manages location manager creation and updates.
 */

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    var delegate: LocationManagerDelegate? = nil

    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // The internal location manager instance that this class abstracts.
    private var _manager: CLLocationManager
    
    // The current location.
    private var _location: CLLocation? = nil
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    /**
     * Singleton LocationManager instance.
     *
     * - parameter N/A
     *
     * - returns: A shared LocationManager instance.
     */
    
    class func sharedLocationManager() -> LocationManager {
        struct Static {
            static let instance: LocationManager = LocationManager()
        }
        return Static.instance
    }
    
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
     * Initialize a new location manager. Also request authorization for
     * location updates if necessary.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */

    override init () {
        
        self._manager = CLLocationManager()
        super.init()
        
        self._manager.delegate = self
        self._manager.desiredAccuracy = kCLLocationAccuracyBest
        self._manager.distanceFilter = 5.0
        
        // Request the user for location updates, if not already allowed.
        self._manager.requestWhenInUseAuthorization()
    }

    /**
     * Start location updates.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    
    func startLocationUpdate() {
        self._manager.startUpdatingLocation()
    }

    /**
     * Stop location updates.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    
    func stopLocationUpdate() {
        self._manager.stopUpdatingLocation()
        self._location = nil
    }
    
    /**
     * Get the current location.
     *
     * - parameter N/A
     *
     * - returns: The current location if location updates have been authorized.
     *            Nil otherwise.
     */
    
    func getLocation() -> CLLocation? {
        return self._location
    }

    /**
     * Request the current location.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */

    func requestLocation() {
        return self._manager.requestLocation()
    }

    /**
     * Get the current authorization status for location retrieval.
     *
     * - parameter N/A
     *
     * - returns: True if location retrieval is authorized.
     *            False otherwise.
     */

    func isAuthorized() -> Bool {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        return (status == .AuthorizedWhenInUse)
    }
    
    /**
     * Get whether or not the current authorization status for location
     * retrieval has been determined.
     *
     * - parameter N/A
     *
     * - returns: True if location retrieval authorization has been determined.
     *            False otherwise.
     */
    
    func isAuthorizationDetermined() -> Bool {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        return (status != .NotDetermined)
    }

    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: CLLocationManagerDelegate
    //**************************************************************************
    
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations:[CLLocation]) {

        // Retrieve the last (most recent) location.
        let location = locations.last

        // Cache off the current location and call the delegate method, if
        // any.
        self._location = location
        if self.delegate != nil {
            self.delegate!.updateLocation(self, location: self._location!)
        }
    }
    
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError) {
        print("LocationManager: Error callback with domain: \(error.domain), code: \(error.code)");
    }

    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            
        if status == .AuthorizedWhenInUse {
            self.startLocationUpdate()
        } else {
            self.stopLocationUpdate()
        }
    }
}

/**
 * LocationManagerDelegate
 *
 * The required interface for a class conforming to LocationManagerDelegate.
 */
protocol LocationManagerDelegate {

    /**
     * Receives the current location.
     *
     * - parameter manager: Instance of the location manager.
     * - parameter location: The current location.
     *
     * - returns: N/A
     */
    
    func updateLocation(manager: LocationManager, location: CLLocation)
}
