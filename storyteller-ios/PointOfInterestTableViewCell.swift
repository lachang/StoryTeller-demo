//******************************************************************************
//  PointOfInterestTableViewCell.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

/**
 * PointOfInterestTableViewCell
 *
 * Custom table view cell for PointOfInterest instances.
 */

class PointOfInterestTableViewCell: UITableViewCell {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var title:    UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var distance: UILabel!

    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
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
     * Configure outlets based on a given PointOfInterest instance.
     *
     * - parameter callback: Callback invoked once the geo msg destroy attempt
     *                       completes.
     *
     * - returns: N/A
     */
    func configureCell(pointOfInterest: PointOfInterest) {

        self.title.text = pointOfInterest.title
        self.subtitle.text = String(pointOfInterest.numMessages) + " Messages"
        if self.distance != nil {
            self.distance!.text = "Distance: \(Int(pointOfInterest.distance!)) m"
        }
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}
