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
     * - parameter pointOfInterest: The PointOfInterest instance used to
     *                              configure with.
     *
     * - returns: N/A
     */
    func configureCell(pointOfInterest: PointOfInterest) {

        let distance = Int(pointOfInterest.distance!)
        if pointOfInterest.locked {
            self.title.textColor    = UIColor.lightGrayColor()
            self.subtitle.textColor = UIColor.lightGrayColor()
            self.distance.textColor = UIColor.lightGrayColor()

            self.subtitle.text = "(Locked)"
        }
        else {
            self.title.textColor    = UIColor.blackColor()
            self.subtitle.textColor = UIColor.blackColor()
            self.distance.textColor = UIColor.darkGrayColor()
            
            self.subtitle.text = String(pointOfInterest.numMessages) + " Messages"
        }
        
        self.title.text = pointOfInterest.title
        if self.distance != nil {
            self.distance!.text = "Distance: \(distance) m"
        }
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}
