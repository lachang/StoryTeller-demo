//******************************************************************************
//  DemoKnobsController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import CoreLocation

/**
 * DemoKnobsController
 *
 * Displays knobs for demoing the app.
 */

class DemoKnobsController: UIViewController, LocationManagerDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var nearbyStorypoints: UIButton!

    @IBOutlet var activityIndicatorView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
    // The internal location manager.
    private var _locationManager: LocationManager =
    LocationManager.sharedLocationManager()
    
    private var _serialQueue: dispatch_queue_t =
        dispatch_queue_create("DemoKnobsController", DISPATCH_QUEUE_SERIAL)
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Private)
    //**************************************************************************
    
    private static let _initialPoints = [
        //        ["title":"Alcatraz Main Cell House",
        //             "longitude":-122.42319,
        //             "latitude":37.82683],
        //
        //        ["title":"Alcatraz Island Guard House",
        //             "longitude":-122.42241,
        //             "latitude":37.82728],
        //
        //        ["title":"Alcatraz Apartments",
        //             "longitude":-122.42170,
        //             "latitude":37.82674],
        //
        //        ["title":"Lochness Monster",
        //             "longitude":-122.408227,
        //             "latitude":37.8269],
        
        ["title":"Treasure Island",
            "longitude":-122.370648,
            "latitude":37.823552],
        
        //        ["title":"Magnet Systems",
        //            "longitude":-122.158983,
        //            "latitude":37.449434],
        
        ["title":"Pier 39",
            "longitude":-122.417743,
            "latitude":37.808],
    ]
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Triggered to populate initial story points.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func populateInitialStorypoints(sender: AnyObject) {
        
        var pointsOfInterest: [PointOfInterest] = []
        var numCallbacks = 0

        let userLocation = self._locationManager.getLocation()
        let numInitial = DemoKnobsController._initialPoints.count
        
        // Hide the nearby-storypoints button and start the activity indicator.
        self.nearbyStorypoints.hidden = true
        self.activityIndicator.hidden = false
        
        for point in DemoKnobsController._initialPoints {
            let pointOfInterest = PointOfInterest(
                title: point["title"] as! String,
                numMessages: 0,
                longitude: point["longitude"] as! CLLocationDegrees,
                latitude: point["latitude"] as! CLLocationDegrees,
                userLocation: userLocation!)

            pointOfInterest.create(callback: {(error) -> Void in
                if error == nil {
                    pointsOfInterest.append(pointOfInterest)
                }
                
                dispatch_async(self._serialQueue) {
                    numCallbacks++
                    
                    // Wait till callbacks for every channel have been invoked.
                    if numCallbacks == numInitial {
                        let numCreated = pointsOfInterest.count
                        if numCreated < numInitial {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                // If an error occurred, show an alert.
                                self._alertView!.showAlert(
                                    "Not All Storypoints Were Created",
                                    message: "\(numCreated) were created.",
                                    callback: nil)
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self._alertView!.showAlert(
                                    "Storypoints Created",
                                    message: "\(numCreated) were created.",
                                    callback: nil)
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            // Hide the activity indicator and re-display the
                            // nearby-storypoints button.
                            self.nearbyStorypoints.hidden = false
                            self.activityIndicator.hidden = true
                        }
                    }
                }
            })
        }
        
    }
    
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
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************

    //**************************************************************************
    // MARK: LocationManagerDelegate
    //**************************************************************************
    
    func updateLocation(manager: LocationManager, location: CLLocation) {
        
        // Now that at least one location is available, stop receiving location
        // updates.
        self._locationManager.delegate = nil
        self.activityIndicatorView.hidden = true
    }
    
    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially hide the signup activity indicator.
        self.activityIndicator.hidden = true
        
        // Beautify and setup the activity indicator.
        self.activityIndicatorView.layer.cornerRadius = 10
        self.activityIndicatorView.hidden = true

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // Retrieve at least one location.
        if self._locationManager.getLocation() == nil {
            
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
                // The application has authorization to receive location data
                // but no locations have yet been received. Request a location.
                
                self.activityIndicatorView.hidden = false
                
                // Register with the LocationManager for location updates.
                self._locationManager.delegate = self
                self._locationManager.requestLocation()

            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the location manager's reference to this view controller.
        self._locationManager.delegate = nil
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }

}
