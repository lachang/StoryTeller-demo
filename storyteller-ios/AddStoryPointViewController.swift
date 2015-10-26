//******************************************************************************
//  AddStoryPointViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import MapKit
import CoreLocation

/**
 * AddStoryPointViewController
 *
 * View to add a new story point.
 */

class AddStoryPointViewController: UIViewController, UITextFieldDelegate,
LocationManagerDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var name: UITextField!
    @IBOutlet var tags: UITextField!
    @IBOutlet var coordinates: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var add: UIButton!
    @IBOutlet var cancel: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var delegate: AddStoryPointDelegate? = nil
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
    // Manages the map snapshot view.
    private var _mapSnapshot: MapSnapshot? = nil
    
    // The internal location manager.
    private var _locationManager: LocationManager =
    LocationManager.sharedLocationManager()
    
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
     * Triggered when the user presses the cancel button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func cancel(sender: AnyObject) {
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * Triggered when the user touches the view, outside of other UI controls
     * (i.e. textfields, buttons, etc...)
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func endEditing(sender: AnyObject) {
        // Forces the view (or one of its embedded text fields) to resign the
        // first responder.
        self.view.endEditing(true)
    }
    
    /**
     * Triggered when the user presses the add button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func add(sender: AnyObject) {
        
        // Show the activity indicator and hide the buttons.
        self.activityIndicator.hidden = false
        self.add.hidden = true
        self.cancel.hidden = true

        let userLocation = self._locationManager.getLocation()!
        
        // Initialize a new point-of-interest.
        let pointOfInterest = PointOfInterest(
            title: self.name.text!,
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
                let tags = self.tags.text!
                if !tags.isEmpty {
                    pointOfInterest.setTags(tags,
                        callback: {(error) -> Void in })
                }
                
                // Add the point-of-interest to the view.
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // Send the new PointOfInterest instance to the delegate.
                    if self.delegate != nil {
                        self.delegate!.newStoryPoint(pointOfInterest)
                    }
                    
                    // Dismiss this controller.
                    self.dismissViewControllerAnimated(true, completion: nil)
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

    private func _setupMapSnapshot(userLocation: CLLocation?) {
        
        if userLocation != nil {
            
            // Now that at least one location is available, stop receiving
            // location updates.
            self._locationManager.delegate = nil
            self.activityIndicator.hidden = true
            
            let coordinates = userLocation!.coordinate
            self.coordinates.text = "Longitude: \(coordinates.longitude),\n" +
                                    "Latitude: \(coordinates.latitude)"
            
            let point = MKPointAnnotation()
            point.coordinate = coordinates
            self._mapSnapshot!.removeAllAnnotations()
            self._mapSnapshot!.addAnnotations([point])
            self._mapSnapshot!.showAllAnnotations()
        }
    }
    
    //**************************************************************************
    // MARK: LocationManagerDelegate
    //**************************************************************************
    
    /**
    * Receives the current location.
    *
    * - parameter manager: Instance of the location manager.
    * - parameter location: The current location.
    *
    * - returns: N/A
    */
    
    func updateLocation(manager: LocationManager, location: CLLocation) {
        
        // Setup the map snapshot.
        self._setupMapSnapshot(location)
    }
    
    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // Manages functionality of the map snapshot view.
        self._mapSnapshot = MapSnapshot(imageView: self.image)
        
        // Register with the LocationManager for location updates.
        self._locationManager.delegate = self
        
        // Retrieve the user location.
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
            // Attempt to setup the map snapshot.
            
            let userLocation = self._locationManager.getLocation()
            self._setupMapSnapshot(userLocation)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        // Release the map snapshot's reference to the UI image view element.
        self._mapSnapshot = nil
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }
    
    //**************************************************************************
    // MARK: UITextFieldDelegate
    //**************************************************************************
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Resign the keyboard from the textfield where "Return" was pressed.
        textField.resignFirstResponder()
        
        // Move the keyboard to the next text field. If there is no other text
        // field to move to, trigger the signup action.
        
        if (textField == self.name) {
            self.tags.becomeFirstResponder()
        }
        else if (textField == self.tags) {
            self.add(self)
        }
        
        return true;
    }
}

/**
 * AddStoryPointDelegate
 *
 * The required interface for a class conforming to AddStoryPointDelegate.
 */
protocol AddStoryPointDelegate {
    
    /**
     * Receives the new story point.
     *
     * - parameter storypoint: Instance of the PointOfInterest that was created.
     *
     * - returns: N/A
     */
    
    func newStoryPoint(storypoint: PointOfInterest)
}