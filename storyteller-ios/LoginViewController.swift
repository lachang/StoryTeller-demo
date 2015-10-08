//******************************************************************************
//  LoginViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

/**
 * LoginViewController
 *
 * Manages the login view.
 */

class LoginViewController: UIViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
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
     * :param: sender The source that triggered this function.
     *
     * :returns: N/A
     */
    
    @IBAction func cancel(sender: AnyObject) {
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * Triggered when the user touches the view, outside of other UI controls
     * (i.e. textfields, buttons, etc...)
     *
     * :param: sender The source that triggered this function.
     *
     * :returns: N/A
     */
    
    @IBAction func endEditing(sender: AnyObject) {
        // Forces the view (or one of its embedded text fields) to resign the
        // first responder.
        self.view.endEditing(true)
    }
    
    /**
     * Triggered when the user presses the login button.
     *
     * :param: sender The source that triggered this function.
     *
     * :returns: N/A
     */
    
    @IBAction func login(sender: AnyObject) {
        // Forces the view (or one of its embedded text fields) to resign the
        // first responder.
        self.view.endEditing(true)
        
        // Attempt to login.
        let session = Session()
        session.login(
            self.username.text!,
            password: self.password.text!,
            callback: { (error) -> Void in
                if error != nil {
                    // If an error occurred, show an alert.
                    var message = error!.localizedDescription
                    if error!.localizedFailureReason != nil {
                        message = error!.localizedFailureReason!
                    }
                    self._alertView!.showAlert(
                        "Login Failed",
                        message: message,
                        callback: nil)
                }
                else {
                    // Otherwise, clear the password and go to the initial view.
                    dispatch_async(dispatch_get_main_queue()) {
                        self.password.text = ""
                        let appDelegate =
                        UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.switchToInitialView()
                    }
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

        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
    }

    //**************************************************************************
    // MARK: UITextFieldDelegate
    //**************************************************************************
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Resign the keyboard from the textfield where "Return" was pressed.
        textField.resignFirstResponder()
        
        // Move the keyboard to the next text field. If there is no other text
        // field to move to, trigger the signup action.
        
        if (textField == self.username) {
            self.password.becomeFirstResponder()
        }
        else if (textField == self.password) {
            self.login(self)
        }
        
        return true;
    }
}
