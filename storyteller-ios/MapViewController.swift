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
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    private func _index() {
        
//            // Fetch all the channels for now.
//            MMXChannel.allPublicChannelsWithLimit(100, offset: 0, success:
//                { (totalCount, channels) -> Void in
//                    
//                    self._pointsOfInterest = []
//                    var annotations: [MKAnnotation] = []
//                    
//                    let channelList = channels as! [MMXChannel]
//                    channelLoop: for channel in channelList {
//                        
//                        // pull out the channel info to create a point of interest
//                        var channelInfo = channel.summary.componentsSeparatedByString(" ")
//                        var longitude = 0.0
//                        var latitude = 0.0
//                        var title = ""
//                        for var i = 0; i < channelInfo.count; i++ {
//                            if channelInfo[i] == "longitude" {
//                                i++
//                                longitude = Double(channelInfo[i])!
//                            } else if channelInfo[i] == "latitude" {
//                                i++
//                                latitude = Double(channelInfo[i])!
//                            } else if channelInfo[i] == "title" {
//                                // title is special. it is currently always at the end
//                                // because it could have spaces and this makes parsing
//                                // much easier... read until end of array
//                                i++
//                                while i < channelInfo.count {
//                                    title += channelInfo[i]
//                                    title += " "
//                                    i++
//                                }
//                                title = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
//                            } else {
//                                print(channel.name + " not following proper format!")
//                                print("skipping over this channel...")
//                                continue channelLoop
//                            }
//                        }
//                        
//                        // create the point of interest
//                        let pointOfInterest = PointOfInterest(
//                            title: title,
//                            numMessages: Int(channel.numberOfMessages),
//                            channel: channel,
//                            longitude: longitude,
//                            latitude: latitude,
//                            userLocation: userLocation!)
//                        
//                        // Consider adding the point-of-interest if its within 100000 m.
//                        if Int(pointOfInterest.distance!) < 100000 {
//                            self.addPointOfInterestAndSubscribe(pointOfInterest, channel: channel)
//                            annotations.append(pointOfInterest)
//                        }
//                    } // end of for channel in channelList
//                    
//                    dispatch_async(dispatch_get_main_queue()) {
//                        
//                        if self._mapView != nil {
//                            self._mapView!.removeAllAnnotations()
//                            self._mapView!.addAnnotations(annotations)
//                            self._mapView!.showAllAnnotations()
//                        }
//                        
//                        // Reload the table view.
//                        self.tableView.reloadData()
//                    }
//                }, failure: { (error) -> Void in
//                    print("ERROR: Failed to fetch channels!")
//            })
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
