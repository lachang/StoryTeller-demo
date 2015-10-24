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

    // Various error codes.
    static let errorIndexCode  = 1
    static let errorCreateCode = 2
    
    var title: String?
    var longitude: CLLocationDegrees
    var latitude: CLLocationDegrees
    var location: CLLocation
    var coordinate: CLLocationCoordinate2D
    var numMessages: Int
    var distance: CLLocationDistance?
    var locked: Bool
    
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
    
    /**
     * Retrieves a list of PointOfInterest instances.
     *
     * - parameter count: The number of instances to retrieve.
     * - parameter offset: The offset from which to retrieve the number of
     *                     instances (for paging purposes).
     * - parameter userLocation: The location of the user (for distance
     *                           purposes).
     * - parameter callback: Callback invoked once the retrieval attempt
     *                       completes.
     *
     * - returns: N/A
     */
    
    class func index(count: Int, offset: Int,
        userLocation: CLLocation?,
        callback: (([PointOfInterest], NSError?) -> Void)) {

        let maxCount  = Int(Int32.max)
        let maxOffset = Int(Int32.max - Int32(count))
        if (count <= maxCount && offset < maxOffset) {
            
            // Fetch the requested number of channels from the given offset.
            MMXChannel.allPublicChannelsWithLimit(Int32(count),
                offset: Int32(offset),
                success: { (totalCount, channels) -> Void in
                    
                    var pointsOfInterest: [PointOfInterest] = []

                    // Convert each MMX Channel into a PointOfInterest instance.
                    for channel in channels as! [MMXChannel] {
                        pointsOfInterest.append(
                            PointOfInterest(channel: channel,
                                userLocation: userLocation))
                    }

                    // Invoke the callback.
                    callback(pointsOfInterest, nil)
                },
                failure: { (error) -> Void in
                    print("ERROR: Failed to fetch channels!")
                    callback([], error)
                })
        }
        else {
            let userInfo = [
                NSLocalizedDescriptionKey: "Invalid Count",
                NSLocalizedFailureReasonErrorKey: "Too many channels were specified."
            ]
            let error = NSError(domain: "PointOfInterest",
                code: PointOfInterest.errorIndexCode,
                userInfo: userInfo)
            
            print("ERROR: Failed to fetch channels!")
            callback([], error)
        }
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
     * Initialize a new PointOfInterest instance.
     *
     * - parameter title: Name of the point-of-interest.
     * - parameter numMessages: Number of messages at this point-of-interest.
     * - parameter longitude: The point-of-interest longitude.
     * - parameter latitude: The point-of-interest latitude.
     * - parameter channel: MMXChannel associated with this point of interest.
     * - parameter userLocation: The user's location used to calculate distance
     *                           to this point-of-interest.
     *
     * - returns: N/A
     */
    
    init (title: String, numMessages: Int, longitude: CLLocationDegrees,
        latitude: CLLocationDegrees, channel: MMXChannel?,
        userLocation: CLLocation?) {

        self.title       = title
        self.numMessages = numMessages
        self.longitude   = longitude
        self.latitude    = latitude
        self.channel     = channel
        self.locked      = false

        self.location  = CLLocation(latitude: self.latitude,
            longitude: self.longitude)
        self.coordinate = CLLocationCoordinate2DMake(self.latitude,
            self.longitude)

        if userLocation != nil {

            // If a user location was given, calculate the distance from the
            // user to this point-of-interest.
            
            self.distance = self.location.distanceFromLocation(userLocation!)
            if Int(self.distance!) >= config.StoryPointUnlockedDistance {
                
                // Points-of-interest are "locked" if they are too far away.
                self.locked = true
            }
        }
            
        super.init()
    }

    /**
     * Initialize a new PointOfInterest instance.
     *
    * - parameter title: Name of the point-of-interest.
    * - parameter numMessages: Number of messages at this point-of-interest.
    * - parameter longitude: The point-of-interest longitude.
    * - parameter latitude: The point-of-interest latitude.
    * - parameter userLocation: The user's location used to calculate distance
    *                           to this point-of-interest.
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
            longitude: longitude,
            latitude: latitude,
            channel: nil,
            userLocation: userLocation)
    }
    
    /**
     * Initialize a new PointOfInterest instance given an MMX Channel.
     *
     * - parameter channel: The MMX Channel from which to initialize from.
     * - parameter userLocation: The location of the user (for distance
     *                           purposes).
     *
     * - returns: N/A
     */
    convenience init (channel: MMXChannel, userLocation: CLLocation?) {

        // Extract information from the channel summary.
        var channelInfo = channel.summary.componentsSeparatedByString(" ")
        
        var longitude = 0.0
        var latitude = 0.0
        var title = ""
        
        for (var i = 0; i < channelInfo.count; i++) {
            
            if channelInfo[i] == "longitude" {
                i++
                longitude = Double(channelInfo[i])!
            }
            else if channelInfo[i] == "latitude" {
                i++
                latitude = Double(channelInfo[i])!
            }
            else if channelInfo[i] == "title" {

                // "title" is special. It is currently always at the end because
                // it could have spaces and this makes parsing much easier...
                // Read until the end of array.

                i++
                while i < channelInfo.count {
                    title += channelInfo[i]
                    title += " "
                    i++
                }
                title = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        }
        
        // Note this is a "convenience" initializer since it calls a different
        // "designated" initializer.
        
        self.init(title: title,
            numMessages: Int(channel.numberOfMessages),
            longitude: longitude,
            latitude: latitude,
            channel: channel,
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
        
        if self.title!.isEmpty {
            
            // A title is required.
            let userInfo = [
                NSLocalizedDescriptionKey: "Invalid Title",
                NSLocalizedFailureReasonErrorKey: "A title is required."
            ]
            let error = NSError(domain: "PointOfInterest",
                code: PointOfInterest.errorCreateCode,
                userInfo: userInfo)
            
            print("ERROR: Failed to add channel!")
            callback(error)
        }
        else {

            // Create strings that are properly-formatted for the server.
            let formattedTitleString   = self._makeTitleString()
            let formattedSummaryString = self._makeSummaryString()
            
            // Create a new channel for Magnet Message.
            MMXChannel.createWithName(
                formattedTitleString,
                summary: formattedSummaryString,
                isPublic: true,
                success: {(channel) -> Void in
                    
                    // Save off a reference to the channel.
                    print("Added channel \(channel!.name)")
                    self.channel = channel
                    callback(nil)
                },
                failure: {(error) -> Void in
                    print("ERROR: Failed to add channel!")
                    callback(error)
                })
        }
    }
    
    /**
     * Add a message on the server for this PointOfInterest instance.
     *
     * - parameter callback: Callback invoked once the message creation attempt
     *                       completes.
     *
     * - returns: N/A
     */
    
    func addMessage(content: [String:String], callback: ((NSError?) -> Void)) {
        
        // Publish the message to Magnet Message.
        self.channel!.publish(content,
            success: {(message) -> Void in
                print("Published to \(self.channel!.name)")
                callback(nil)
            },
            failure: {(error) -> Void in
                print("ERROR: Failed to add message!")
                callback(error)
            })
    }
    
   /**
    * Set the tags on the server for this PointOfInterest instance
    *
    * - parameter callback: Callback invoked once the attempt to set tags
    *                       completes.
    *
    * - returns: N/A
    */
    
    func setTags(tagsString: String, callback: ((NSError?) -> Void)) {
        
        // Split the large string at spaces into an array of tags.
        let tagsStringArray = tagsString.componentsSeparatedByString(" ")
        
        // Transform the string into a set for Magnet Message.
        var tagsSet = Set<String>()
        for tag in tagsStringArray {
            tagsSet.insert(tag)
        }

        // Send the tags to Magnet Message to set onto the channel.
        self.channel!.setTags(tagsSet,
            success: {() -> Void in
                callback(nil)
            },
            failure: {(error) -> Void in
                print("ERROR: Failed to set tags!")
                callback(error)
            })
    }
    
    /**
     * Get the tags on the server for this PointOfInterest instance
     *
     * - parameter callback: Callback invoked once the retrieval attempt
     *                       completes.
     *
     * - returns: N/A
     */
    
    func getTags(callback callback: ((NSError?) -> Void)) {

        // Retrieve the tags from Magnet Message for the channel.
        self.channel!.tagsWithSuccess(
            { (tags) -> Void in
                callback(nil)
            },
            failure: {(error) -> Void in
                print("ERROR: Failed to get tags!")
                callback(error)
            })
    }

    /**
     * Delete this PointOfInterest instance from the server.
     *
     * - parameter callback: Callback invoked once the deletion attempt
     *                       completes.
     *
     * - returns: N/A
     */

    func delete(callback callback: ((NSError?) -> Void)) {
        
        // Delete the given channel from Magnet Message.
        self.channel!.deleteWithSuccess(
            { () -> Void in
                callback(nil)
            },
            failure: { (error) -> Void in
                print("ERROR: Failed to delete channel!")
                callback(error)
            })
    }

    /**
     * Subscribe to or unsubscribe from the PointOfInterest on the server.
     *
     * - parameter callback: Callback invoked once the subscription (or
     *                       unsubscription) attempt completes.
     *
     * - returns: N/A
     */
    
    func subscribeOrUnsubscribe(callback callback: ((NSError?) -> Void)) {
     
        // Subscribe to or unsubscribe from the channel on Magnet Message based
        // on whether the point-of-interest is locked or not.
        
        if !self.locked {
            // Only subscribe to points-of-interests within a preset discance.
            self.channel!.subscribeWithSuccess({ () -> Void in
            }, failure: { (error) -> Void in
                print("ERROR: Failed to subscribe!")
                callback(error)
            })
        }
        else {
            // Unsubscribe from a channel that is too far away.
            self.channel!.unSubscribeWithSuccess({ () -> Void in
            }, failure: { (error) -> Void in
            })
        }
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    /**
     * Construct the title string for use on the server.
     *
     * - parameter N/A
     *
     * - returns: Modified title string
     */
    
    private func _makeTitleString() -> String {

        let time = NSDate().timeIntervalSince1970
        let titleString = User.currentUser()!.username + "_" + String(time)
        return titleString
    }
 
    /**
     * Construct the summary string for use on the server. The string is
     * specially formatted to make it easy to re-parse out the information
     * later.
     *
     * i.e. longitude -122.42241 latitude 37.82728 title Alcatraz Island - Guard House
     *
     * - parameter N/A
     *
     * - returns: Modified summary string
     */

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