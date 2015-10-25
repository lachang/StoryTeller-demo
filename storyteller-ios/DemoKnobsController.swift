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
    
    private static let _initialPointsSanFrancisco = [
        ["title":"Alcatraz Main Cell House",
            "longitude":-122.42319,
            "latitude":37.82683,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Sean Connery was here!"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Tight quarters"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445750386.37246.caf",
                    "titleName":"George \"Machine Gun\" Kelly was a storyteller"],
            ]],
        ["title":"Alcatraz Island Guard House",
            "longitude":-122.42241,
            "latitude":37.82728,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Inmates used to be kept in the basement of the guardhouse"],
            ]],
        ["title":"Alcatraz Apartments",
            "longitude":-122.42170,
            "latitude":37.82674,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Grew up on the rock"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"First building constructed on the island of Alcatraz"],
            ]],
        ["title":"Lochness Monster",
            "longitude":-122.408227,
            "latitude":37.8269,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Went whale-watching, saw something else..."],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"I saw it!"],
            ]],
        ["title":"Treasure Island",
            "longitude":-122.370648,
            "latitude":37.823552,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Awesome view of San Francisco from here"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Proposed to my wife right here 50 years ago..."],
            ]],
        ["title":"Pier 39",
            "longitude":-122.417743,
            "latitude":37.808,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Mmmm... clam chowder!"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445751651.76006.caf",
                    "titleName":"Can you hear the sea lions?"],
            ]],
    ]
    
    private static let _initialPointsPaloAlto = [
        ["title":"Magnet Systems",
            "longitude":-122.158983,
            "latitude":37.449434,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"StoryTeller team met the CEO of Magnet today!"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Add real-time user communication to your app with just a few lines of code"],
            ]],
        ["title":"Paris Baguette",
            "longitude":-122.160749,
            "latitude":37.447173,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Morning coffee and pastry"],
            ]],
        ["title":"Stanford",
            "longitude":-122.1697189,
            "latitude":37.4274745,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Time to study..."],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Go Cardinals!"],
            ]],
        ["title":"Blue Bottle Coffee",
            "longitude":-122.1596170,
            "latitude":37.447578,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Awesome coffee \"plus\" a place to code in the back!"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"There used to be a Borders here..."],
            ]],
        ["title":"Stanford Dish",
            "longitude":-122.179599,
            "latitude":37.408564,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"If you see this... we walked the Dish on this day"],
            ]],
    ]
    
    private static let _nearbyPoints = [
        ["title":"Demo - Best Coffee Ever",
            "distance":5,
            "bearing":45,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"In the breakroom"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Pumpkin Spice Latte!"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"No cream, no sugar please!"],
            ]],
        ["title":"Demo - Something Happened Here",
            "distance":25,
            "bearing":135,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Found a note, it reads..."],
            ]],
        ["title":"Demo - Secret Door",
            "distance":150,
            "bearing":270,
            "messages":[
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"A door behind the wall"],
                ["spoken":"https://s3.amazonaws.com/storyteler/admin_1445748132.1478.caf",
                    "titleName":"Tilt the third book"],
            ]],
    ]
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
    // The internal location manager.
    private var _locationManager: LocationManager =
    LocationManager.sharedLocationManager()

    // Serial queue to serialize entry into critical sections.
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
        
        // Construct the initial points array from separate arrays. Apparently
        // XCode does not like it if one static array is too long. THus, need
        // to split into multiple arrays and re-combine.

        var _initialPoints = DemoKnobsController._initialPointsSanFrancisco
        for point in DemoKnobsController._initialPointsPaloAlto {
            _initialPoints.append(point)
        }
        
        let numTotal = _initialPoints.count
        
        let userLocation = self._locationManager.getLocation()
        
        // Hide the buttons and start the activity indicator.
        self.initialStorypoints.hidden = true
        self.nearbyStorypoints.hidden = true
        self.deleteAll.hidden = true
        self.activityIndicatorView.hidden = false
        
        for point in _initialPoints {
            
            let pointOfInterest = PointOfInterest(
                title: point["title"] as! String,
                numMessages: 0,
                longitude: point["longitude"] as! CLLocationDegrees,
                latitude: point["latitude"] as! CLLocationDegrees,
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
                                message: "Press refresh on the Nearby and Map tabs.",
                                callback: {() -> Void in
                                    self.dismissViewControllerAnimated(true,
                                        completion: nil)
                                })

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
                                "Storypoints Created!",
                                message: "Press refresh on the Nearby and Map tabs.",
                                callback: {() -> Void in
                                    self.dismissViewControllerAnimated(true,
                                        completion: nil)
                                })

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
        
        // Hide the buttons and start the activity indicator.
        self.initialStorypoints.hidden = true
        self.nearbyStorypoints.hidden = true
        self.deleteAll.hidden = true
        self.activityIndicatorView.hidden = false
        
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
                                        message: "\(numDeleted) deleted. Press refresh on the Nearby and Map tabs.",
                                        callback: {() -> Void in
                                            self.dismissViewControllerAnimated(true,
                                                completion: nil)
                                        })

                                    // Hide the activity indicator and
                                    // re-display the buttons.
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

        // Only allow the "admin" user to use the button that populates the DB
        // with initial points.
        if User.currentUser()!.username != "admin" {
            self.initialStorypoints.enabled = false
            self.initialStorypoints.setTitle("(Admin Only)", forState: .Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // Register with the LocationManager for location updates.
        self._locationManager.delegate = self
        
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
                // but no locations have yet been received. Register with the
                // LocationManager for location updates and wait for the
                // location...
                
                self.activityIndicatorView.hidden = false
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
