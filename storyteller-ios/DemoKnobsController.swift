//******************************************************************************
//  DemoKnobsController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import CoreLocation

import MMX

/**
 * DemoKnobsController
 *
 * Displays knobs for demoing the app.
 */

class DemoKnobsController: UIViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var nearbyStorypoints: UIButton!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    private let _populatePoints = [
        ["title":"Alcatraz Main Cell House",
         "longitude":-122.42319,
         "latitude":37.82683],
//        ["title":"Alcatraz Island Guard House",
//         "longitude":-122.42241,
//         "latitude":37.82728],
//        ["title":"Alcatraz Apartments",
//         "longitude":-122.42170,
//         "latitude":37.82674],
    ]
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
    // The internal location manager.
//    private var _locationManager: LocationManager =
//    LocationManager.sharedLocationManager()
    
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
     * Triggered to populate initial story points.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func populateInitialStoryooints(sender: AnyObject) {
        
//        var pointsOfInterest: [PointOfInterest] = []
//
//        let userLocation = self._locationManager.getLocation()
//        for point in self._populatePoints {
//            let pointOfInterest = PointOfInterest(
//                title: point["title"] as! String,
//                numMessages: 0,
//                longitude: point["longitude"] as! CLLocationDegrees,
//                latitude: point["latitude"] as! CLLocationDegrees,
//                userLocation: userLocation!)
//
//            pointOfInterest.create(callback: {(error) -> Void in
//                pointsOfInterest.append(pointOfInterest)
//            })
//        }
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
    // MARK: UIViewController
    //**************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }

}
