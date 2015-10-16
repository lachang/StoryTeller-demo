//******************************************************************************
//  PointOfInterest.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation
import CoreLocation
import MapKit

import MMX

/**
 * PointOfInterest
 *
 * Encapsulates a point-of-interest. Also conforms to the MKAnnotation protocol
 * so that instances can be shown on a map.
 */

class PointOfInterest: NSObject, MKAnnotation {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    var title: String?
    var longitude: CLLocationDegrees
    var latitude: CLLocationDegrees
    var location: CLLocation
    var coordinate: CLLocationCoordinate2D
    var channel: MMXChannel
    var numMessages: Int
    var distance: CLLocationDistance?
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
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
     * Initialize a new point-of-interest.
     *
     * - parameter title: Name of the point-of-interest.
     * - parameter numMessages: Number of messages at this point-of-interest.
     * - parameter channel: MMXChannel associated with this point of interest.
     * - parameter longitude: The point-of-interest longitude.
     * - parameter latitude: The point-of-interest latitude.
     * - parameter userLocation: The user's location used to calculate distance
     *                           to this point-of-interest.
     *
     * - returns: Void
     */
    
    init (title: String, numMessages: Int, channel: MMXChannel,
        longitude: CLLocationDegrees, latitude: CLLocationDegrees,
        userLocation: CLLocation) {

        self.title       = title
        self.numMessages = numMessages
        self.channel     = channel
        self.longitude   = longitude
        self.latitude    = latitude

        self.location  = CLLocation(latitude: self.latitude,
            longitude: self.longitude)
        self.coordinate = CLLocationCoordinate2DMake(self.latitude,
            self.longitude)

        self.distance = self.location.distanceFromLocation(userLocation)
    }

    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}