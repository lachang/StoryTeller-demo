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

    @IBOutlet var fullname: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var email:    UILabel!
    
    @IBOutlet var activityIndicatorView: UIView!
    
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
                    var message = error!.localizedDescription
                    if error!.localizedFailureReason != nil {
                        message = error!.localizedFailureReason!
                    }
                    self._alertView!.showAlert(
                        "Logout Failed",
                        message: message,
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
    
    private func _show(user: User?) {
        
        if user != nil {
            user!.show(
                callback: { (error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicatorView.hidden = true
                    }
                    
                    if error != nil {
                        // If an error occurred, show an alert.
                        var message = error!.localizedDescription
                        if error!.localizedFailureReason != nil {
                            message = error!.localizedFailureReason!
                        }
                        self._alertView!.showAlert(
                            "Profile Retrieval Failed",
                            message: message,
                            callback: nil)
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.fullname.text = user!.fullname
                            self.username.text = user!.username
                            
                            if user!.email != nil {
                                self.email.text = user!.email!
                            }
                        }
                    }
                })
        }
        else {
            self.activityIndicatorView.hidden = true
            self._alertView!.showAlert(
                "Profile Retrieval Failed",
                message: "No logged-in user.",
                callback: nil)
        }
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // Setup the view labels.
        self.activityIndicatorView.hidden = false
        self._show(User.currentUser())
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }
}
