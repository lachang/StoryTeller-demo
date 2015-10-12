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

    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially hide the login activity indicator.
        self.activityIndicator.hidden = true
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // Auto-login if a cached session credential exists.
        if Session.sessionCredential != nil {
            
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
                        self.signupButton.hidden = false
                        self.loginButton.hidden = false
                        self.activityIndicator.hidden = true
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
    }
}
