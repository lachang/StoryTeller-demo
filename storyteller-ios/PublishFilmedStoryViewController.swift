//******************************************************************************
//  PublishSpokenStoryViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

import MMX

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
    
    var channel: MMXChannel!
    
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
    * Triggered when the user presses the record / publish button.
    *
    * - parameter sender: The source that triggered this function.
    *
    * - returns: N/A
    */
    
    @IBAction func recordOrPublish(sender: AnyObject) {
        
        let text = self.record.titleLabel!.text
        
        if text == "Record" {

            self.record.setTitle("Stop", forState: .Normal)
            self.activityIndicator.hidden = false
        }
        else if text == "Stop" {
            
            self.activityIndicator.hidden = true
            self.record.setTitle("Publish", forState: .Normal)
            
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
            self.playback.setTitle("Stop", forState: .Normal)
        }
        else if self.playback.titleLabel!.text == "Stop" {
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
    
    /*
    * Arvind to add video stuff here
    */
    
    private func _publish() {
        //add the code to take the message from X and send to server
        
        /*
        Method to publish to a channel.
        
        - (void)publish:(NSDictionary *)messageContent success:(void ( ^ ) ( MMXMessage *message ))success failure:(void ( ^ ) ( NSError *error ))failure
        Parameters
        messageContent
        The content you want to publish
        success
        Block with the published message
        failure
        Block with an NSError with details about the call failure.
        Discussion
        Method to publish to a channel.
        
        Declared In
        MMXChannel.h
        */
        
        if (messageName.text!.isEmpty) {
            // If an error occurred, show an alert.
            self._alertView!.showAlert(
                "Invalid Name",
                message: "Story name cannot be blank.",
                callback: nil)
        }
        else {
            // Dismiss this controller.
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }
}
