//******************************************************************************
//  PublishFilmedStoryViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

/**
 * PublishFilmedStoryViewController
 *
 * Manages recording, playback, and creation of a video story.
 */

class PublishFilmedStoryViewController: UIViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var messageName: UITextField!
    @IBOutlet var record: UIButton!
    @IBOutlet var playback: UIButton!
    @IBOutlet var reset: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // The PointOfInterest instance to add the story to.
    var pointOfInterest: PointOfInterest!
    
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
     * Triggered when the user presses the record / publish button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func recordOrPublish(sender: AnyObject) {
        
        let text = self.record.titleLabel!.text
        
        if text == "Record" {

            // Transition the button from "Record" -> "Stop".
            self.record.setTitle("Stop", forState: .Normal)
            self.activityIndicator.hidden = false
        }
        else if text == "Stop" {
            
            // Transition the button from "Stop" -> "Publish".
            self.activityIndicator.hidden = true
            self.record.setTitle("Publish", forState: .Normal)
            
            // Show other buttons / fields related to publishing.
            self.messageName.hidden = false
            self.playback.hidden = false
            self.reset.hidden = false
        }
        else if text == "Publish" {
            
            self._publish()
        }
    }
    
    /**
     * Triggered when the user presses the playback button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func playbackOrStop(sender: AnyObject) {
        
        if self.playback.titleLabel!.text == "Playback" {
            
            // Transition the button from "Playback" -> "Stop".
            self.playback.setTitle("Stop", forState: .Normal)
        }
        else if self.playback.titleLabel!.text == "Stop" {
            
            // Transition the button from "Stop" -> "Playback".
            self.playback.setTitle("Playback", forState: .Normal)
        }
    }
    
    /**
     * Triggered when the user presses the reset button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func resetView(sender: AnyObject) {
        
        self.messageName.hidden = true
        self.playback.hidden = true
        self.reset.hidden = true
        self.record.setTitle("Record", forState: .Normal)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    /**
     * Publishes the video to the server.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    
    private func _publish() {
        if (messageName.text!.isEmpty) {
            // If an error occurred, show an alert.
            self._alertView!.showAlert(
                "Invalid Name",
                message: "Story name cannot be blank.",
                callback: nil)
        }
        else {
            self.activityIndicator.hidden = false
            self.messageName.enabled = false
            self.record.hidden = true
            self.playback.hidden = true
            self.reset.hidden = true
            
            // Create a unique string to use for the filename.
            //let filename = self._makeFilename()
            
            // TODO: Add code here...
            
            // Dismiss this controller.
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /**
     * Construct the filename for use on the server.
     *
     * - parameter N/A
     *
     * - returns: Constructed filename
     */
    
    private func _makeFilename() -> String {
        
        let time = NSDate().timeIntervalSince1970
        let filename = User.currentUser()!.username + "_" + String(time)
        return filename.stringByAppendingString(".caf")
    }
    
    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.hidden = true
        self.messageName.hidden = true
        self.playback.hidden = true
        self.reset.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        self._alertView!.showAlert(
            "Unsupported",
            message: "This feature is not yet supported.",
            callback: {() -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }
}
