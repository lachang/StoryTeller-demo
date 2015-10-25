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
    
    @IBOutlet var initialStorypoints: UIButton!
    @IBOutlet var nearbyStorypoints: UIButton!
    @IBOutlet var deleteAll: UIButton!
    @IBOutlet var activityIndicatorView: UIView!
    
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
    
    private static let _nearbyPoints = [
        ["title":"Demo - Best Coffee Ever",
            "distance":5,
            "bearing":45,
            "messages":[
                ["written":"Pumpkin spice latte"],
                ["written":"In the breakroom"],
                ["written":"No cream, no sugar please!"],
            ]],
        ["title":"Demo - What Happened Here",
            "distance":25,
            "bearing":135,
            "messages":[
                ["written":"Found a note, it reads..."],
            ]],
        ["title":"Demo - Secret Door",
            "distance":150,
            "bearing":270,
            "messages":[
                ["written":"A door behind the wall"],
                ["written":"Tilt the third book"],
            ]],
    ]
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Triggered to populate initial storypoints.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func populateInitialStorypoints(sender: AnyObject) {
        
        var numCallbacks = 0
        let numTotal = DemoKnobsController._initialPoints.count
        
        let userLocation = self._locationManager.getLocation()
        
        // Hide the buttons and start the activity indicator.
        self.initialStorypoints.hidden = true
        self.nearbyStorypoints.hidden = true
        self.deleteAll.hidden = true
        self.activityIndicatorView.hidden = false
        
        for point in DemoKnobsController._initialPoints {
            let pointOfInterest = PointOfInterest(
                title: point["title"] as! String,
                numMessages: 0,
                longitude: point["longitude"] as! CLLocationDegrees,
                latitude: point["latitude"] as! CLLocationDegrees,
                userLocation: userLocation!)

            pointOfInterest.create(callback: {(error) -> Void in
                
                dispatch_async(self._serialQueue) {
                    numCallbacks++
                    
                    // Wait till callbacks for every channel have been invoked.
                    if numCallbacks == numTotal {
                        dispatch_async(dispatch_get_main_queue()) {
                            self._alertView!.showAlert(
                                "Storypoints Created",
                                message: "\(numCallbacks) were processed.",
                                callback: nil)

                            // Hide the activity indicator and re-display the
                            // buttons.
                            self.initialStorypoints.hidden = false
                            self.nearbyStorypoints.hidden = false
                            self.deleteAll.hidden = false
                            self.activityIndicatorView.hidden = true
                        }
                    }
                }
            })
        }
    }
    
    /**
     * Triggered to create nearby storypoints.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func createNearbyStorypoints(sender: AnyObject) {
        
        var numCallbacks = 0
        let numTotal = DemoKnobsController._nearbyPoints.count
        
        let userLocation = self._locationManager.getLocation()
        
        // Hide the buttons and start the activity indicator.
        self.initialStorypoints.hidden = true
        self.nearbyStorypoints.hidden = true
        self.deleteAll.hidden = true
        self.activityIndicatorView.hidden = false
        
        for point in DemoKnobsController._nearbyPoints {
            
            let coordinate = MapView.coordinateFromCoord(userLocation!.coordinate,
                distanceInMeters: point["distance"] as! Double,
                atBearingDegrees: point["bearing"] as! Double)
            
            let pointOfInterest = PointOfInterest(
                title: point["title"] as! String,
                numMessages: 0,
                longitude: coordinate.longitude,
                latitude: coordinate.latitude,
                userLocation: userLocation!)
            
            pointOfInterest.create(callback: {(error) -> Void in
                
                if error == nil {
                    // Once the channel is created, add the sample messages.
                    // This is an asynchronous function but ignoring this for
                    // now as this is a debug / development code path.
                    
                    let messages = point["messages"] as! [[String:String]]
                    for message in messages {
                        pointOfInterest.addMessage(message,
                            callback: {(error) -> Void in
                                // Ignore errors for now since this is a debug /
                                // development function.
                        })
                    }
                }
                
                dispatch_async(self._serialQueue) {
                    numCallbacks++
                    
                    // Wait till callbacks for every channel have been invoked.
                    if numCallbacks == numTotal {
                        dispatch_async(dispatch_get_main_queue()) {
                            self._alertView!.showAlert(
                                "Storypoints Created",
                                message: "\(numCallbacks) were processed.",
                                callback: nil)

                            // Hide the activity indicator and re-display the
                            // buttons.
                            self.initialStorypoints.hidden = false
                            self.nearbyStorypoints.hidden = false
                            self.deleteAll.hidden = false
                            self.activityIndicatorView.hidden = true
                        }
                    }
                }
            })
        }
    }
    
    /**
     * Triggered to delete all the current user's storypoints.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func deleteAll(sender: AnyObject) {
        
        PointOfInterest.index(100, offset: 0, userLocation: nil,
            callback: {(pointsOfInterest, error) -> Void in

                var numCallbacks = 0
                var numDeleted = 0
                let numTotal = pointsOfInterest.count
                
                for pointOfInterest in pointsOfInterest {

                    pointOfInterest.delete( callback: {(error) -> Void in
                        
                        // Only those channels owned by the logged-in user can
                        // be deleted.
                        if (error == nil) {
                            numDeleted++
                        }
                        
                        dispatch_async(self._serialQueue) {
                            numCallbacks++
                            
                            // Wait till callbacks for every channel have been
                            // invoked.
                            if numCallbacks == numTotal {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self._alertView!.showAlert(
                                        "Storypoints Deleted",
                                        message: "\(numDeleted) processed.",
                                        callback: nil)

                                    // Hide the activity indicator and re-display the
                                    // buttons.
                                    self.initialStorypoints.hidden = false
                                    self.nearbyStorypoints.hidden = false
                                    self.deleteAll.hidden = false
                                    self.activityIndicatorView.hidden = true
                                }
                            }
                        }
                    })
                }
            })
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
    
    /**
     * Receives the current location.
     *
     * - parameter manager: Instance of the location manager.
     * - parameter location: The current location.
     *
     * - returns: N/A
     */
    
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
