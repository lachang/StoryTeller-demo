//******************************************************************************
//  AlertView.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

/**
 * AlertView
 *
 * Helper functions for alert views.
 */

class AlertView {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    /// The view controller to manage the alert view for.
    private var _viewController: UIViewController
    
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
     * Initialize a new alert view.
     *
     * - parameter viewController: The view controller to manage the alert view for
     *
     * - returns: N/A
     */
    
    init (viewController: UIViewController) {
        
        // Cache off the view controller to manage the alert view for.
        self._viewController = viewController
    }
    
    /**
     * Create and present a simple alert view with the given title / message. An
     * optional callback can be given that is called once the alert view is
     * dismissed.
     *
     * - parameter title: The title to show in the alert view.
     * - parameter message: The message to show in the alert view.
     * - parameter callback: Callback invoked once the alert view is dismissed.
     *
     * - returns: N/A
     */
    
    func showAlert(title: String, message: String,
        callback: ((Void) -> Void)?) {
            
        let alertViewController =
        UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: { (alert) -> Void in
                // Invoke the callback, if any.
                if callback != nil {
                    callback!()
                }
            })
        
        alertViewController.addAction(alertAction)
        
        self._viewController.presentViewController(
            alertViewController,
            animated: true,
            completion: nil)
    }
    
    /**
     * Create and present a simple alert view with the given title. The message
     * to show is extracted from the given error. An optional callback can be
     * given that is called once the alert view is dismissed.
     *
     * - parameter title: The title to show in the alert view.
     * - parameter error: The error to extract a message from.
     * - parameter callback: Callback invoked once the alert view is dismissed.
     *
     * - returns: N/A
     */
    
    func showAlert(title: String, error: NSError, callback: ((Void) -> Void)?) {
            
        var message = error.localizedDescription
        if error.localizedFailureReason != nil {
            message = error.localizedFailureReason!
        }
        self.showAlert(title, message: message, callback: callback)
    }

    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}