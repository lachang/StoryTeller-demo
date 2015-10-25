//******************************************************************************
//  AddStoryPointViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

/**
 * AddStoryPointViewController
 *
 * View to add a new story point.
 */

class AddStoryPointViewController: UIViewController, UITextFieldDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var name: UITextField!
    @IBOutlet var tags: UITextField!
    @IBOutlet var coordinates: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var add: UIButton!
    @IBOutlet var cancel: UIButton!
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
     * Triggered when the user presses the add button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func add(sender: AnyObject) {
        
        // Show the activity indicator and hide the buttons.
        self.activityIndicator.hidden = false
        self.add.hidden = true
        self.cancel.hidden = true

        // Hide the activity indicator and show the buttons.
        self.activityIndicator.hidden = true
        self.add.hidden = false
        self.cancel.hidden = false
        
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
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
        
        if (textField == self.name) {
            self.tags.becomeFirstResponder()
        }
        else if (textField == self.tags) {
            self.add(self)
        }
        
        return true;
    }
}
