//******************************************************************************
//  SignupViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

/**
 * SignupViewController
 *
 * Manages the signup view.
 */

class SignupViewController: UIViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    @IBOutlet var firstname: UITextField!
    @IBOutlet var lastname:  UITextField!
    @IBOutlet var username:  UITextField!
    @IBOutlet var email:     UITextField!
    @IBOutlet var password:  UITextField!

    @IBOutlet var signupButton: UIButton!
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
    
    /**
     * Triggered when the user presses the cancel button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func cancel(sender: AnyObject) {
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /**
     * Triggered when the user touches the view, outside of other UI controls
     * (i.e. textfields, buttons, etc...)
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func endEditing(sender: AnyObject) {
        // Forces the view (or one of its embedded text fields) to resign the
        // first responder.
        self.view.endEditing(true)
    }
    
    /**
     * Triggered when the user presses the signup button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func signup(sender: AnyObject) {
        // Forces the view (or one of its embedded text fields) to resign the
        // first responder.
        self.view.endEditing(true)
        
        // Hide the signup button and start the activity indicator.
        self.signupButton.hidden = true
        self.activityIndicator.hidden = false
        
        // Attempt to signup.
        let user = User(firstname: self.firstname.text!,
            lastname: self.lastname.text!, username: self.username.text!,
            email: self.email.text!)

        user.signup(password: self.password.text!, callback: { (error) -> Void in

            if error != nil {
                // If an error occurred, show an alert.
                var message = error!.localizedDescription
                if error!.localizedFailureReason != nil {
                    message = error!.localizedFailureReason!
                }
                self._alertView!.showAlert(
                    "Signup Failed",
                    message: message,
                    callback: nil)

                // Hide the activity indicator and re-display the signup button.
                dispatch_async(dispatch_get_main_queue()) {
                    self.signupButton.hidden = false
                    self.activityIndicator.hidden = true
                }
            }
            else {
                
                // Attempt to login.
                let session = Session()
                session.login(
                    user.username,
                    password: self.password.text!,
                    callback: { (error) -> Void in
                        
                        if error != nil {
                            // If an error occurred, show an alert.
                            var message = error!.localizedDescription
                            if error!.localizedFailureReason != nil {
                                message = error!.localizedFailureReason!
                            }
                            self._alertView!.showAlert(
                                "Signup Succeeded But Login Failed",
                                message: message,
                                callback: nil)
                            
                            // Dismiss this controller so that the user can try
                            // to login again.
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            
                            // Alert the user upon a successful signup.
                            self._alertView!.showAlert(
                                "Signup Succeeded",
                                message: "Thanks for joining!",
                                callback: { (Void) -> Void in
                                    
                                    // Dismiss this controller and go to the
                                    // initial view.
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.dismissViewControllerAnimated(false,
                                            completion: nil)
                                        let appDelegate =
                                        UIApplication.sharedApplication().delegate as! AppDelegate
                                        appDelegate.switchToInitialView()
                                    }
                            })
                        }
                    })
            }
        })
    }
    
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

        // Initially hide the signup activity indicator.
        self.activityIndicator.hidden = true
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

    //**************************************************************************
    // MARK: UITextFieldDelegate
    //**************************************************************************
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Resign the keyboard from the textfield where "Return" was pressed.
        textField.resignFirstResponder()
        
        // Move the keyboard to the next text field. If there is no other text
        // field to move to, trigger the signup action.
        
        if (textField == self.firstname) {
            self.lastname.becomeFirstResponder()
        }
        else if (textField == self.lastname) {
            self.username.becomeFirstResponder()
        }
        else if (textField == self.username) {
            self.email.becomeFirstResponder()
        }
        else if (textField == self.email) {
            self.password.becomeFirstResponder()
        }
        else if (textField == self.password) {
            self.signup(self)
        }
        
        return true;
    }
}
