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
    @IBOutlet var reload: UIBarButtonItem!
    @IBOutlet var activityIndicatorView: UIView!
    
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
    
    // Determines whether the view attempts to retrieve channels.
    private var _attemptChannelRetrieval = false
    
    private var _StoryPointNameTextField: UITextField?
    private var _StoryPointTagsTextField: UITextField?
    
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
     * Triggered when the user presses the reload button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func reload(sender: AnyObject) {
        let location: CLLocation? = self._locationManager.getLocation()
        self._index(location)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    internal func _didReceiveMessage(notification: NSNotification) {
        
        let userInfo : [NSObject : AnyObject] = notification.userInfo!
        let message = userInfo[MMXMessageKey] as! MMXMessage
        
        // Determine if the message is for a subscribed channel.
        
        for pointOfInterest in self._pointsOfInterest {
            if message.channel == pointOfInterest.channel! {
                
                // Increment the message count for the channel and reload the
                // table view.
                pointOfInterest.numMessages++
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    // add a new story point
    @IBAction func addNewStoryPoint(sender: AnyObject) {
        
        let alertController = UIAlertController(
            title: "Add New Storypoint",
            message: "Please enter a Storypoint name and at least 3 tags that help identify it",
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .Default)
            { (action) -> Void in
                
                let nameField = self._StoryPointNameTextField
                    
                if nameField!.text == "" {
                    // TODO: handle this case
                } else {
                    // get the channel necessities
                    let userLocation = self._locationManager.getLocation()
                    
                    // initialize the point of interest
                    let pointOfInterest = PointOfInterest(
                        title: nameField!.text!,
                        numMessages: 0,
                        longitude: userLocation!.coordinate.longitude,
                        latitude: userLocation!.coordinate.latitude,
                        userLocation: userLocation!)
                    
                    // add the point of interest on the server
                    pointOfInterest.create(callback: {(error) -> Void in
                        if error != nil {
                            // If an error occurred, show an alert.
                            var message = error!.localizedDescription
                            if error!.localizedFailureReason != nil {
                                message = error!.localizedFailureReason!
                            }
                            self._alertView!.showAlert(
                                "Storypoint Creation Failed",
                                message: message,
                                callback: nil)
                        }
                        else {
                            var annotation:MKAnnotation?
                            
                            // add the point of interest
                            self.addPointOfInterestAndSubscribe(pointOfInterest)
                            annotation = pointOfInterest
                            
                            // set the tags to associate with the channel
                            let tagField = self._StoryPointTagsTextField
                            if tagField!.text == "" {
                                // TODO: handle this case
                            } else {
                                pointOfInterest.setTags(tagField!.text!)
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self._mapView!.addAnnotation(annotation!)
                                self.tableView.reloadData()
                            }
                        }
                    })
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
            UITextField.placeholder = "Enter Storypoint Name"
            self._StoryPointNameTextField = UITextField
        }
        
        alertController.addTextFieldWithConfigurationHandler { (UITextField) -> Void in
            UITextField.placeholder = "Enter Tags Separated By Spaces"
            self._StoryPointTagsTextField = UITextField
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * Helper function to add a point-of-interest to the table view and if
     * necessary, subscribe to its channel.
     *
     * - parameter pointOfInterest: The point-of-interest to process.
     *
     * - returns: N/A
     */

    private func addPointOfInterestAndSubscribe(
        pointOfInterest: PointOfInterest) -> Void {
        
        // Add the point of interest to the table view.
        self._pointsOfInterest.append(pointOfInterest)
        
        if !pointOfInterest.locked {

            // Only subscribe to points-of-interests within 100 m.
            pointOfInterest.channel!.subscribeWithSuccess({ () -> Void in
                }, failure: { (error) -> Void in
                    print("ERROR: Failed to subscribe to " +
                          pointOfInterest.channel!.name)
                })
        }
        else {
            
            pointOfInterest.channel!.unSubscribeWithSuccess({ () -> Void in
                }, failure: { (error) -> Void in
//                    print("ERROR: Failed to unsubscribe for " +
//                          pointOfInterest.channel!.name)
                })
        }
    }
    
    private func _index(userLocation: CLLocation?) {

        self.activityIndicatorView.hidden = false
        self.reload.enabled = false
        
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
            
            // Hide the activity indicator and re-display the reload button.
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicatorView.hidden = true
                self.reload.enabled = true
            }
        }
        else {

            let userLocation = self._locationManager.getLocation()
            PointOfInterest.index(100, offset: 0,
                userLocation: userLocation,
                callback: { (pointsOfInterest, error) -> Void in
                    
                    if error != nil {
                        // If an error occurred, show an alert.
                        var message = error!.localizedDescription
                        if error!.localizedFailureReason != nil {
                            message = error!.localizedFailureReason!
                        }
                        self._alertView!.showAlert(
                            "Storypoint Retrieval Failed",
                            message: message,
                            callback: nil)
                    }
                    else {
                        self._pointsOfInterest = []
                        var annotations: [MKAnnotation] = []
                        
                        for pointOfInterest in pointsOfInterest {
                            
                            // Add the point-of-interest to the map if its within
                            // 10000 m.
                            if Int(pointOfInterest.distance!) < 10000 {
                                self.addPointOfInterestAndSubscribe(pointOfInterest)
                                annotations.append(pointOfInterest)
                            }
                        }
                        
                        // Sort the collected points-of-interest in descending
                        // order.
                        self._pointsOfInterest.sortInPlace({
                            $0.distance! < $1.distance!
                        })
                        
                        // Show all the points of interest on the map.
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            if self._mapView != nil {
                                self._mapView!.removeAllAnnotations()
                                self._mapView!.addAnnotations(annotations)
                                self._mapView!.showAllAnnotations(
                                    showUserLocation: true)
                            }
                            
                            // Reload the table view.
                            self.tableView.reloadData()
                        }
                    }
                    
                    // Hide the activity indicator and re-display the reload button.
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicatorView.hidden = true
                        self.reload.enabled = true
                    }
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
        
        // Setup a notifier for receiving further messages for subscribed
        // channels.
        MMX.start()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "_didReceiveMessage:",
            name: MMXDidReceiveMessageNotification, object: nil)
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
        if self.tableView.indexPathForSelectedRow != nil {
            self.tableView.deselectRowAtIndexPath(
                self.tableView.indexPathForSelectedRow!,
                animated: false)
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
            messagesViewController.pointOfInterest =
                self._pointsOfInterest[selectedRow]
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let pointOfInterest = self._pointsOfInterest[indexPath.row]

        if pointOfInterest.locked {
            return nil
        }
        else {
            return indexPath
        }
    }
}
