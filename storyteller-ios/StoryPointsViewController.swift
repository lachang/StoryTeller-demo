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
 * Displays the index of nearby points-of-interests (aka storypoints) as pins on
 * a map.
 */

class StoryPointsViewController: UIViewController, UITableViewDataSource,
    UITableViewDelegate, MKMapViewDelegate, LocationManagerDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var reload: UIBarButtonItem!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // An array of points-of-interest to display.
    private var _pointsOfInterest: [PointOfInterest] = []
    
    // Manages the map view.
    private var _mapView: MapView? = nil
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil

    // The internal location manager.
    private var _locationManager: LocationManager =
    LocationManager.sharedLocationManager()
    
    // Determines whether the view attempts to retrieve points-of-interest.
    private var _attemptPointRetrieval = false
    
    // Determines whether the view attempts to show all annotations on the map
    // at once.
    private var _showAllAnnotations = false

    // Activity indicator to denote processing with a remote server.
    private var _activityIndicatorBarButton: UIBarButtonItem?
    
    // Fields shown in an alertview when adding a new point-of-interest.
    private var _storyPointNameTextField: UITextField?
    private var _storyPointTagsTextField: UITextField?
    
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
     * Triggered when the user presses the create button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */

    @IBAction func create(sender: AnyObject) {
        
        let alertController = UIAlertController(
            title: "Add New StoryPoint",
            message: "Please enter a name and at least 3 tags that help identify it.",
            preferredStyle: .Alert)
        
        // Create the OK action.
        let okAction = UIAlertAction(
            title: "OK",
            style: .Default,
            handler: { (action) -> Void in

                // Create the point-of-interest.
                self._create(self._storyPointNameTextField!.text!,
                    tags: self._storyPointTagsTextField!.text!,
                    userLocation: self._locationManager.getLocation()!)
            })
        
        // Create the cancel action.
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Cancel,
            handler: { (action) -> Void in
            })
        
        // Add the actions to the alert view.
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Add text fields to the alert view.
        alertController.addTextFieldWithConfigurationHandler(
            { (UITextField) -> Void in
                UITextField.placeholder = "Enter Storypoint Name"
                self._storyPointNameTextField = UITextField
            })
        
        alertController.addTextFieldWithConfigurationHandler(
            { (UITextField) -> Void in
                UITextField.placeholder = "Enter Tags Separated By Spaces"
                self._storyPointTagsTextField = UITextField
            })
        
        // Show the alert view.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * Triggered when the user presses the reload button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func reload(sender: AnyObject) {
        self._showAllAnnotations = true
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
    
    private func _index(userLocation: CLLocation?) {

        dispatch_async(dispatch_get_main_queue()) {
            self.navigationItem.rightBarButtonItem =
                self._activityIndicatorBarButton
        }
        
        if userLocation == nil {

            if !self._locationManager.isAuthorized() {

                // Show an alert stating that the application does not have the
                // authorization to receive location data.

                self._alertView!.showAlert(
                    "No Location Available",
                    message: "Please enable location services.",
                    callback: nil)
                
                // Hide the activity indicator and re-display the reload button.
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationItem.rightBarButtonItem = self.reload
                }
            }

            
            // The application has authorization to receive location data but no
            // locations have yet been received. Wait for the location ...
        }
        else {

            PointOfInterest.index(100, offset: 0,
                userLocation: userLocation,
                callback: { (pointsOfInterest, error) -> Void in
                    
                    if error != nil {
                        // If an error occurred, show an alert.
                        self._alertView!.showAlert(
                            "Storypoint Retrieval Failed",
                            error: error!,
                            callback: nil)
                    }
                    else {
                        self._pointsOfInterest = []
                        var annotations: [MKAnnotation] = []
                        
                        for pointOfInterest in pointsOfInterest {
                            
                            // Save off the point-of-interest if its within a
                            // preset distance.
                            if Int(pointOfInterest.distance!) <
                               config.StoryPointLockedDistance {

                                annotations.append(pointOfInterest)
                                self._pointsOfInterest.append(pointOfInterest)
                                
                                // Subscribe or unsubscribe to the
                                // point-of-interest based on distance.
                                pointOfInterest.subscribeOrUnsubscribe(
                                    callback: {(error) -> Void in
                                        
                                    self._alertView!.showAlert(
                                        "StoryPoint Creation Failed",
                                        error: error!,
                                        callback: nil)
                                })
                            }
                        }
                        
                        // Sort the collected points-of-interest in descending
                        // order.
                        self._pointsOfInterest.sortInPlace({
                            $0.distance! < $1.distance!
                        })
                        
                        dispatch_async(dispatch_get_main_queue()) {

                            // Show all the points of interest on the map, if
                            // available.
                            if self._mapView != nil {
                                self._mapView!.removeAllAnnotations()
                                self._mapView!.addAnnotations(annotations)

                                if self._showAllAnnotations {
                                    self._showAllAnnotations = false
                                    self._mapView!.showAllAnnotations(
                                        showUserLocation: true)
                                }
                            }
                            
                            // Reload the table view.
                            self.tableView.reloadData()
                        }
                    }
                    
                    // Hide the activity indicator and re-display the reload button.
                    dispatch_async(dispatch_get_main_queue()) {
                        self.navigationItem.rightBarButtonItem = self.reload
                    }
                })
        }
    }
    
    private func _create(name: String, tags: String, userLocation: CLLocation) {
        
        // Initialize a new point-of-interest.
        let pointOfInterest = PointOfInterest(
            title: name,
            numMessages: 0,
            longitude: userLocation.coordinate.longitude,
            latitude: userLocation.coordinate.latitude,
            userLocation: userLocation)
        
        // Create the point-of-interest.
        pointOfInterest.create(callback: {(error) -> Void in
            
            if error != nil {
                self._alertView!.showAlert(
                    "StoryPoint Creation Failed",
                    error: error!,
                    callback: nil)
            }
            else {
                // Subscribe or unsubscribe to the point-of-interest based on
                // distance.
                pointOfInterest.subscribeOrUnsubscribe(callback: {(error) -> Void in
                    self._alertView!.showAlert(
                        "StoryPoint Creation Failed",
                        error: error!,
                        callback: nil)
                })
                
                // Set the tags to associate with the point-of-interest.
                if !tags.isEmpty {
                    pointOfInterest.setTags(tags,
                        callback: {(error) -> Void in })
                }
                
                // Add the point-of-interest to the view.
                dispatch_async(dispatch_get_main_queue()) {
                    self._mapView!.addAnnotation(pointOfInterest)
                    self._pointsOfInterest.insert(pointOfInterest, atIndex: 0)
                    self.tableView.reloadData()
                }
            }
        })
    }

    //**************************************************************************
    // MARK: LocationManagerDelegate
    //**************************************************************************

    func updateLocation(manager: LocationManager, location: CLLocation) {

        // Now that at least one location is available, retrieve nearby points-
        // of-interest.
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

        // Create an activity indictor which can be temporarily shown on the
        // navigation bar when activity occurs with the server.
        let activityIndicator = UIActivityIndicatorView(
            activityIndicatorStyle: .White)
        activityIndicator.startAnimating()
        self._activityIndicatorBarButton = UIBarButtonItem(
            customView: activityIndicator)
        
        // Make the table view row height dynamic.
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Attempt point-of-interest retrieval when the controller initially
        // loads.
        self._attemptPointRetrieval = true
        
        // Initially show all annotations when the view loads.
        self._showAllAnnotations = true

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
        
        // If requested, attempt to retrieve points-of-interest.
        if self._attemptPointRetrieval {

            self._attemptPointRetrieval = false

            // Retrieve at least one location.
            if !self._locationManager.isAuthorized() {

                // Show an alert stating that the application does not have
                // the authorization to receive location data.

                self._alertView!.showAlert(
                    "No Location Available",
                    message: "Please enable location services.",
                    callback: {() -> Void in
                        // Dismiss this controller.
                        self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            else {
                // The application has authorization to receive location data.
                // Start the activity indicator and request a location.

                self.navigationItem.rightBarButtonItem =
                    self._activityIndicatorBarButton
                
                let userLocation = self._locationManager.getLocation()
                self._index(userLocation)
            }
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
                segue.destinationViewController as! StoriesViewController
            
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
