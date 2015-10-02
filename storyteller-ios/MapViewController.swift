//******************************************************************************
//  MapViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import MapKit
import CoreLocation

import MMX

/**
 * MapViewController
 *
 * Displays the index of nearby messages as pins on a map.
 */

class MapViewController: UIViewController, UITableViewDataSource,
    UITableViewDelegate, MKMapViewDelegate,
LocationManagerDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // Messages to display.
    private var _pointsOfInterest: [PointOfInterest] = []
    
    // Manages the map view.
    private var _mapView: MapView? = nil
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil

    // The internal location manager.
    private var _locationManager: LocationManager =
    LocationManager.sharedLocationManager()
    
    // The selected table row, if any.
    private var _selectedIndexPath: NSIndexPath? = nil

    // Hard-coded username for logging into Magnet Message.
    private let _username: String = "foobar"
    private let _password: String = "foobar"
    
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
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************

    private func _index(location: CLLocation?) {

        if location == nil {

            if !self._locationManager.isAuthorized() {

                // Show an alert stating that the application does not have the
                // authorization to receive location data.

                self._alertView!.showAlert(
                    "No Location Available",
                    message: "Please enable location services.",
                    callback: nil)
            }
            else {
                // The application has authorization to receive location data
                // but no locations have yet been received.
                //
                // Register with the LocationManager for location updates.

                self._locationManager.delegate = self
            }
        }
        else {

            // Fetch all the channels for now.
            MMXChannel.allPublicChannelsWithLimit(100, offset: 0, success:
                { (totalCount, channels) -> Void in
                    
                    self._pointsOfInterest = []
                    var annotations: [MKAnnotation] = []
                    
                    let channelList = channels as! [MMXChannel]
                    for channel in channelList {
                        var pointOfInterest: PointOfInterest? = nil

                        // Hardcoded points-of-interest, for now...
                        if channel.summary == "Alcatraz Main Cell House" {
                            pointOfInterest = PointOfInterest(
                                title: channel.summary,
                                numMessages: Int(channel.numberOfMessages),
                                channel: channel,
                                longitude: -122.42319, latitude: 37.82683)
                        }
                        else if channel.summary == "Alcatraz Island - Guard House" {
                            pointOfInterest = PointOfInterest(
                                title: channel.summary,
                                numMessages: Int(channel.numberOfMessages),
                                channel: channel,
                                longitude: -122.42241, latitude: 37.82728)
                        }
                        else if channel.summary == "Alcatraz - Apartments" {
                            pointOfInterest = PointOfInterest(
                                title: channel.summary,
                                numMessages: Int(channel.numberOfMessages),
                                channel: channel,
                                longitude: -122.42170, latitude: 37.82674)
                        }
                        
                        if pointOfInterest != nil {
                            pointOfInterest!.distance =
                                pointOfInterest!.location.distanceFromLocation(location!)
                            
                            // Show all points-of-interests as annotations.
                            annotations.append(pointOfInterest!)
                            
                            // Only show points-of-interest within 50 m for the
                            // table view.
                            if Int(pointOfInterest!.distance!) < 100 {
                                self._pointsOfInterest.append(pointOfInterest!)
                                
                                // Auto-subscribe to channels in view.
                                channel.subscribeWithSuccess({ () -> Void in
                                }, failure: { (error) -> Void in
                                    print("ERROR: Failed to subscribe!")
                                })
                            }
                            else {
                                channel.unSubscribeWithSuccess({ () -> Void in
                                }, failure: { (error) -> Void in
                                    //println("ERROR: Failed to unsubscribe for " + channel.name)
                                })
                            }
                        }
                    }

                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self._mapView!.removeAllAnnotations()
                        self._mapView!.addAnnotations(annotations)
                        self._mapView!.showAllAnnotations(true)
                        
                        // Reload the table view.
                        self.tableView.reloadData()
                    }
                }, failure: { (error) -> Void in
                    print("ERROR: Failed to fetch channels!")
                })
        }
    }

    //**************************************************************************
    // MARK: LocationManagerDelegate
    //**************************************************************************

    func updateLocation(manager: LocationManager, location: CLLocation) {

        // Now that at least one location is available, retrieve nearby geo
        // messages.
        self._index(location)
    }

    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Manages functionality of the map view.
        self._mapView = MapView(mapView: self.mapView)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)

        // Make the table view row height dynamic.
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Attempt to retrieve messages.
        let location: CLLocation? = self._locationManager.getLocation()
        
        // Login to Magnet Message (hardcoded for now).
        let credential = NSURLCredential(user: self._username,
            password: self._password, persistence: .None)
        MMXUser.logInWithCredential(credential,
            success: { (user) -> Void in
                
                // Retrieve the points-of-interest once logged-in.
                self._index(location)
            },
            failure: { (error) -> Void in
                print("ERROR: Failed to login!")
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear the selected index path, if any.
        if self._selectedIndexPath != nil {
            self.tableView.deselectRowAtIndexPath(self._selectedIndexPath!,
                animated: false)
            self._selectedIndexPath = nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showMessagesView" {

            // Pass the selected channel to the messages view.
            let messagesViewController =
                segue.destinationViewController as! MessagesViewController
            
            let selectedRow = self.tableView.indexPathForSelectedRow!.row
            messagesViewController.channel =
                self._pointsOfInterest[selectedRow].channel
        }
    }
    
    //**************************************************************************
    // MARK: UITableViewDataSource
    //**************************************************************************
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._pointsOfInterest.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PointOfInterest Cell", forIndexPath: indexPath) as! PointOfInterestTableViewCell
        
        // Display the point-of-interest to the table cell.
        let pointOfInterest = self._pointsOfInterest[indexPath.row]
        cell.configureCell(pointOfInterest)

        return cell
    }
    
    //**************************************************************************
    // MARK: UITableViewDelegate
    //**************************************************************************
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // Cache off the selected index path.
        self._selectedIndexPath = indexPath
    }
}
