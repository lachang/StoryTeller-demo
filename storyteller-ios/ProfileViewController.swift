//******************************************************************************
//  ProfileViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

/**
 * ProfileViewController
 *
 * Manages the profile view.
 */

class ProfileViewController: UIViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
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
     * Triggered when the user presses the menu button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func showMenu(sender: AnyObject) {
        
        let alertViewController =
        UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Add a logout button.
        let alertActionLogout = UIAlertAction(
            title: "Logout",
            style: UIAlertActionStyle.Default,
            handler: _logout)
        alertViewController.addAction(alertActionLogout)
        
        // Add a cancel button.
        let alertActionCancel = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: nil)
        alertViewController.addAction(alertActionCancel)
        
        self.presentViewController(
            alertViewController,
            animated: true,
            completion: nil)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    /**
     * Triggered when the user presses the logout button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    private func _logout(sender: UIAlertAction!) {
        
        // Attempt to logout.
        let session = Session()
        session.logout(
            callback: { (error) -> Void in
                if error != nil {
                    // If an error occurred, show an alert.
                    self._alertView!.showAlert(
                        "Logout Failed",
                        message: error!.domain,
                        callback: nil)
                }
                else {
                    // Otherwise, go to the initial view.
                    dispatch_async(dispatch_get_main_queue()) {
                        let appDelegate =
                        UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.switchToInitialView()
                    }
                }
        })
    }
    
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
