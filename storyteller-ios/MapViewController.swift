//******************************************************************************
//  MapViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import MapKit

/**
 * MapViewController
 *
 * Displays a map of various storypoints.
 */

class MapViewController: UIViewController, MKMapViewDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var reload: UIBarButtonItem!
    @IBOutlet var activityIndicatorView: UIView!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************

    // Manages the map view.
    private var _mapView: MapView? = nil
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
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
    
    /**
     * Triggered when the user presses the reload button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func reload(sender: AnyObject) {
        self._index()
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************

    /**
     * Retrieves a list of points-of-interests.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    
    private func _index() {

        self.activityIndicatorView.hidden = false
        self.reload.enabled = false
        
        PointOfInterest.index(100, offset: 0,
            userLocation: nil,
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
                    // PointOfInterest instances conform to MKAnnotation.
                    let annotations: [MKAnnotation] = pointsOfInterest
                    
                    // Show all the points of interest on the map.
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if self._mapView != nil {
                            self._mapView!.removeAllAnnotations()
                            self._mapView!.addAnnotations(annotations)
                            self._mapView!.showAllAnnotations(
                                showUserLocation:false)
                        }
                    }
                }
                
                // Hide the activity indicator and re-display the reload button.
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.hidden = true
                    self.reload.enabled = true
                }
            })
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
        
        // Beautify and setup the activity indicator.
        self.activityIndicatorView.layer.cornerRadius = 10
        self.activityIndicatorView.hidden = true
        
        // Attempt channel retrieval when the controller initially loads.
        self._attemptChannelRetrieval = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the map view.
        self._mapView = MapView(mapView: self.mapView)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // If requested, attempt to retrieve channels.
        if self._attemptChannelRetrieval {
            
            self._attemptChannelRetrieval = false
            self._index()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
        
        // Release the map view's reference to the UI map view element.
        self._mapView = nil
    }
}
