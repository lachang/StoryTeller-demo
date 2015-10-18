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
    var numMessages: Int
    var distance: CLLocationDistance?
    
    var channel: MMXChannel?
    
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
    
    init (title: String, numMessages: Int, channel: MMXChannel?,
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

    /**
     * Initialize a new point-of-interest.
     *
     * - parameter firstname: The user's first name.
     * - parameter lastname: The user's last name.
     * - parameter username: The user's handle.
     * - parameter email: The user's email.
     *
     * - returns: N/A
     */
    
    convenience init (title: String, numMessages: Int,
        longitude: CLLocationDegrees, latitude: CLLocationDegrees,
        userLocation: CLLocation) {
        
        // Note this is a "convenience" initializer since it calls a different
        // "designated" initializer.
        
        self.init(title: title,
            numMessages: numMessages,
            channel: nil,
            longitude: longitude,
            latitude: latitude,
            userLocation: userLocation)
    }
    
    /**
     * Create a new PointOfInterest on the server.
     *
     * - parameter callback: Callback invoked once the point-of-interest
     *                       creation attempt completes.
     *
     * - returns: N/A
     */
    
    func create(callback callback: ((NSError?) -> Void)) {
        
        // make strings that are friendly for the magnet API
        let magnetTitleString = self._makeTitleString()
        let magnetSummaryString = self._makeSummaryString()
        
        // Create a new channel for Magnet Message.
        MMXChannel.createWithName(
            magnetTitleString,
            summary: magnetSummaryString,
            isPublic: true,
            success: {(channel) -> Void in
                print("Added channel " + channel!.name)
                self.channel = channel
                callback(nil)
            },
            failure: {(error) -> Void in
                print("ERROR: Failed to signup!")
                callback(error)
            })
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    // make a properly formatted string for magnet message's standard
    private func _makeTitleString() -> String {
        let titleString = self.title!.stringByReplacingOccurrencesOfString(" ", withString: "_").lowercaseString
        return titleString
    }
    
    // make a properly formatted summary for us to parse later
    //eg. longitude -122.42241 latitude 37.82728 title Alcatraz Island - Guard House
    private func _makeSummaryString() -> String {
        let summaryString = "longitude " +
                            String(self.longitude) +
                            " latitude " +
                            String(self.latitude) +
                            " title " +
                            self.title!
        return summaryString
    }
}