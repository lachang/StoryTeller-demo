//******************************************************************************
//  WelcomeViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import MMX

/**
 * WelcomeViewController
 *
 * Displays the welcome view for the app.
 */

class WelcomeViewController: UIViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    @IBOutlet var signupButton: UIButton!
    @IBOutlet var loginButton:  UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil

    // Determines whether the view attempts to auto-login.
    private var _attemptAutoLogin: Bool = false
    
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

    /**
     * Attempts to login.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    private func _login() {
        
        // Hide the signup and login buttons and start the activity
        // indicator.
        self.signupButton.hidden = true
        self.loginButton.hidden = true
        self.activityIndicator.hidden = false
        
        // Attempt to login.
        let credential = Session.sessionCredential
        let session = Session()
        session.login(
            credential!.user!,
            password: credential!.password!,
            callback: { (error) -> Void in
                
                if error != nil {
                    // If an error occurred, show an alert.
                    var message = error!.localizedDescription
                    if error!.localizedFailureReason != nil {
                        message = error!.localizedFailureReason!
                    }
                    self._alertView!.showAlert(
                        "Auto-Login Failed",
                        message: message,
                        callback: nil)
                    
                    // Hide the activity indicator and re-display the signup
                    // and login buttons.
                    dispatch_async(dispatch_get_main_queue()) {
                        self.signupButton.hidden = false
                        self.loginButton.hidden = false
                        self.activityIndicator.hidden = true
                    }
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
        
        // Initially hide the login activity indicator.
        self.activityIndicator.hidden = true
        
        // Attempt auto-login when the controller initially loads.
        self._attemptAutoLogin = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // If requested, attempt to auto-login but only if a cached session
        // credential exists.
        if self._attemptAutoLogin && Session.sessionCredential != nil {
            self._login()
        }
        
        // Disable future auto-logins.
        self._attemptAutoLogin = false
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }
}
