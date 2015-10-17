//******************************************************************************
//  StoryPointsViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import MapKit
import CoreLocation

import MMX

/**
 * StoryPointsViewController
 *
 * Displays the index of nearby messages as pins on a map.
 */

class StoryPointsViewController: UIViewController, UITableViewDataSource,
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

    // Determines whether the view attempts to retrieve channels.
    private var _attemptChannelRetrieval = false
    
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

    // make a properly formatted string for magnet message's standard
    func makeTitleString(title: String) -> String {
        let titleString = title.stringByReplacingOccurrencesOfString(" ", withString: "_").lowercaseString
        
        print(titleString)
        
        return titleString
    }
    
    // make a properly formatted summary for us to parse later
    //eg. longitude -122.42241 latitude 37.82728 title Alcatraz Island - Guard House
    func makeSummaryString(latitude: String, longitude: String, title: String) -> String {
        var summaryString = "longitude "
        summaryString += longitude
        summaryString += " latitude "
        summaryString += latitude
        summaryString += " title "
        summaryString += title
        
        print(summaryString)
        
        return summaryString
    }
    
    // add a new story point
    @IBAction func addNewStoryPoint(sender: AnyObject) {
        
        let alertController = UIAlertController(
            title: "Add New Storypoint",
            message: "Please enter a name",
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .Default)
            { (action) -> Void in
                
                if let nameField = alertController.textFields?.first {
                    if nameField.text == "" {
                        // TODO: handle this case
                    } else {
                        // get the channel necessities
                        let currentLocation = self._locationManager.getLocation()
                        let latitude = currentLocation!.coordinate.latitude
                        let longitude = currentLocation!.coordinate.longitude
                        let title = nameField.text!
                        
                        // make strings that are friendly for the magnet API
                        let magnetTitleString = self.makeTitleString(title)
                        let magnetSummaryString = self.makeSummaryString(String(latitude),
                            longitude: String(longitude),
                            title: title)
                        
                        // create a new channel
                        MMXChannel.createWithName(
                            magnetTitleString,
                            summary: magnetSummaryString,
                            isPublic: true,
                            success: {(channel) -> Void in

                                print("Added channel " + channel!.name)
                                var annotation:MKAnnotation?

                                // create the point of interest
                                let pointOfInterest = PointOfInterest(
                                    title: title,
                                    numMessages: Int(channel.numberOfMessages),
                                    channel: channel,
                                    longitude: longitude,
                                    latitude: latitude,
                                    userLocation: currentLocation!)
                                
                                // add the point of interest
                                self.addPointOfInterestAndSubscribe(pointOfInterest,
                                    channel: channel)
                                annotation = pointOfInterest
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    self._mapView!.addAnnotation(annotation!)
                                    self.tableView.reloadData()
                                }
                            },
                            failure: {(error) -> Void in
                                print(error.code)
                        }) // end of MMXChannel.createWithName
                        
                    }
                }
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Cancel)
            { (action) -> Void in
                // do nothing
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextFieldWithConfigurationHandler { (UITextField) -> Void in
            UITextField.placeholder = "Storypoint name"
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // helper function to add a point of interest to the list and subscribe to the channel
    private func addPointOfInterestAndSubscribe(pointOfInterest: PointOfInterest, channel: MMXChannel) -> Void {
        
        // Only show points-of-interest within 10000 m for the
        // table view.
        if Int(pointOfInterest.distance!) < 10000 {
            self._pointsOfInterest.append(pointOfInterest)
            
            // Auto-subscribe to channels in view.
            channel.subscribeWithSuccess({ () -> Void in
                }, failure: { (error) -> Void in
                    print("ERROR: Failed to subscribe!")
            })
        }
        else {
            channel.unSubscribeWithSuccess({ () -> Void in
                }, failure: { (error) -> Void in
                    //print("ERROR: Failed to unsubscribe for " + channel.name)
            })
        }
        
    }
    
    private func _index(userLocation: CLLocation?) {

        if userLocation == nil {

            if !self._locationManager.isAuthorized() {

                if self._locationManager.isAuthorizationDetermined() {

                    // Show an alert stating that the application does not have
                    // the authorization to receive location data.

                    self._alertView!.showAlert(
                        "No Location Available",
                        message: "Please enable location services.",
                        callback: nil)
                }
            }
            else {
                // The application has authorization to receive location data
                // but no locations have yet been received. Request a location.

                self._locationManager.requestLocation()
            }
        }
        else {

            // Fetch all the channels for now.
            MMXChannel.allPublicChannelsWithLimit(100, offset: 0, success:
                { (totalCount, channels) -> Void in
                    
                    self._pointsOfInterest = []
                    var annotations: [MKAnnotation] = []
                    
                    let channelList = channels as! [MMXChannel]
                    channelLoop: for channel in channelList {
                        
                        // pull out the channel info to create a point of interest
                        var channelInfo = channel.summary.componentsSeparatedByString(" ")
                        var longitude = 0.0
                        var latitude = 0.0
                        var title = ""
                        for var i = 0; i < channelInfo.count; i++ {
                            if channelInfo[i] == "longitude" {
                                i++
                                longitude = Double(channelInfo[i])!
                            } else if channelInfo[i] == "latitude" {
                                i++
                                latitude = Double(channelInfo[i])!
                            } else if channelInfo[i] == "title" {
                                // title is special. it is currently always at the end
                                // because it could have spaces and this makes parsing
                                // much easier... read until end of array
                                i++
                                while i < channelInfo.count {
                                    title += channelInfo[i]
                                    title += " "
                                    i++
                                }
                                title = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            } else {
                                print(channel.name + " not following proper format!")
                                print("skipping over this channel...")
                                continue channelLoop
                            }
                        }
                        
                        // create the point of interest
                        let pointOfInterest = PointOfInterest(
                            title: title,
                            numMessages: Int(channel.numberOfMessages),
                            channel: channel,
                            longitude: longitude,
                            latitude: latitude,
                            userLocation: userLocation!)
                        
                        // Consider adding the point-of-interest if its within 100000 m.
                        if Int(pointOfInterest.distance!) < 100000 {
                            self.addPointOfInterestAndSubscribe(pointOfInterest, channel: channel)
                            annotations.append(pointOfInterest)
                        }
                    } // end of for channel in channelList

                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if self._mapView != nil {
                            self._mapView!.removeAllAnnotations()
                            self._mapView!.addAnnotations(annotations)
                            self._mapView!.showAllAnnotations()
                        }

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

        // Set the background image for the navigation bar.
        //
        // http://stackoverflow.com/questions/26052454/ios-8-navigationbar-backgroundimage
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(named: "blue-background")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0),
                resizingMode: .Stretch), forBarMetrics: .Default)

        // Make the table view row height dynamic.
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Attempt channel retrieval when the controller initially loads.
        self._attemptChannelRetrieval = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the map view.
        self._mapView = MapView(mapView: self.mapView)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)

        // Register with the LocationManager for location updates.
        self._locationManager.delegate = self

        // If requested, attempt to retrieve channels.
        if self._attemptChannelRetrieval {
            
            self._attemptChannelRetrieval = false
            
            let location: CLLocation? = self._locationManager.getLocation()
            self._index(location)
        }
        
        // Clear the selected index path, if any.
        if self._selectedIndexPath != nil {
            self.tableView.deselectRowAtIndexPath(self._selectedIndexPath!,
                animated: false)
            self._selectedIndexPath = nil
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the location manager's reference to this view controller.
        self._locationManager.delegate = nil
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
        
        // Release the map view's reference to the UI map view element.
        self._mapView = nil
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