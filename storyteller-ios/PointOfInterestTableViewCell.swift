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
 * Custom table view cell for GeoMsg instances.
 */

class PointOfInterestTableViewCell: UITableViewCell {

    @IBOutlet var title:    UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var distance: UILabel!

    func configureCell(pointOfInterest: PointOfInterest) {

        self.title.text = pointOfInterest.title
        self.subtitle.text = String(pointOfInterest.numMessages) + " Messages"
        if self.distance != nil {
            self.distance!.text = "Distance: \(Int(pointOfInterest.distance!)) m"
        }
    }
}
