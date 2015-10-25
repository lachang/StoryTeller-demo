//******************************************************************************
//  StoriesViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import AVKit
import AVFoundation
import QuartzCore

import MMX

/**
 * StoriesViewController
 *
 * Displays the messages within a channel.
 */
class StoriesViewController: UITableViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    // The PointOfInterest instance to retrieve stories from.
    var pointOfInterest: PointOfInterest!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // An array of messages to display.
    private var _messages: [MMXMessage] = []
    
    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
    // Table cell identifiers.
    private let _audioStoryCellIdentifier = "AudioStoryTableViewCell"
    private let _videoStoryCellIdentifier = "VideoStoryTableViewCell"
    
    // Determines whether the view attempts to retrieve messages.
    private var _attemptMessageRetrieval = false
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Private)
    //**************************************************************************

    /**
     * Initial configuration for the table view.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    
    private func _configureTableView() {
        // Setup the table view for dynamic row heights.
        tableView.estimatedRowHeight = self.tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Triggered when the user presses the button to leave a memory.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func leaveMemory(sender: AnyObject) {
        
        let alertViewController =
        UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Add an option to "say" a story.
        let alertActionSayStory = UIAlertAction(
            title: "Say Your Story",
            style: UIAlertActionStyle.Default,
            handler: {(alert) -> Void in
                self.performSegueWithIdentifier("MessagesToSpokenSegue",
                    sender: self)
            })
        alertViewController.addAction(alertActionSayStory)
        
        // Add an option to "film" a story.
        let alertActionFilmStory = UIAlertAction(
            title: "Film Your Story",
            style: UIAlertActionStyle.Default,
            handler: {(alert) -> Void in
                self.performSegueWithIdentifier("MessagesToFilmedSegue",
                    sender: self)
            })
        alertViewController.addAction(alertActionFilmStory)
        
        // Add a cancel button.
        let alertActionCancel = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: nil)
        alertViewController.addAction(alertActionCancel)
        
        // Show the alert view.
        self.presentViewController(
            alertViewController,
            animated: true,
            completion: nil)
    }
    
    /**
     * Triggered when the user presses the back button.
     *
     * - parameter sender: The source that triggered this function.
     *
     * - returns: N/A
     */
    
    @IBAction func back(sender: AnyObject) {
        // Dismiss this controller.
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    /**
     * Invoked when a new message is received.
     *
     * - parameter sender: The notification that triggered this function.
     *
     * - returns: N/A
     */
    
    internal func _didReceiveMessage(notification: NSNotification) {

        let userInfo : [NSObject : AnyObject] = notification.userInfo!
        let message = userInfo[MMXMessageKey] as! MMXMessage
        
        // Process the message if it's for this channel.
        if message.channel == self.pointOfInterest.channel! {
            
            // Insert the new message at the top (since newer messages come
            // first) and then reload the table view.
            self._messages.insert(message, atIndex: 0)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    /**
     * Configures an AudioStoryTaleViewCell instance.
     *
     * - parameter tableView; The table view that will display the cell.
     * - parameter message: The message to configure the cell with.
     *
     * - returns: A table cell.
     */
    
    private func _audioStoryCellAtIndexPath(tableView: UITableView,
        message: MMXMessage) -> StoryTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(
            self._audioStoryCellIdentifier) as! AudioStoryTableViewCell
        
        cell.titleLabel.text = (message.messageContent["titleName"] as? String) ?? "[No Title]"
        cell.usernameLabel.text = "\(message.sender.username)"
        var timestampArray = message.timestamp.description.componentsSeparatedByString(" ")
        cell.timestampLabel.text = "\(timestampArray[0])"
        
        return cell
    }
    
    /**
     * Configures a VideoStoryTableViewCell instance.
     *
     * - parameter tableView; The table view that will display the cell.
     * - parameter message: The message to configure the cell with.
     *
     * - returns: A table cell.
     */
    
    private func _videoStoryCellAtIndexPath(tableView: UITableView,
        message: MMXMessage) -> StoryTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(
            self._videoStoryCellIdentifier) as! VideoStoryTableViewCell
        
        cell.titleLabel.text = (message.messageContent["titleName"] as? String) ?? "[No Title]"
        cell.usernameLabel.text = "\(message.sender.username)"
        var timestampArray = message.timestamp.description.componentsSeparatedByString(" ")
        cell.timestampLabel.text = "\(timestampArray[0])"
        
//        if let url  = NSURL(string: message.messageContent["imageUrl"] as! String),
//               data = NSData(contentsOfURL: url)
//        {
//            cell.customImageView.image = UIImage(data: data)
//        }

//        cell.thumbnail.image = UIImage(named: "catdog.jpg")
//        cell.thumbnail.image = UIImage(named: "kitty.jpg")
//        cell.thumbnail.layer.cornerRadius = 5
//        cell.thumbnail.layer.masksToBounds = true
        
        return cell
    }
    
    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self._configureTableView()
        
        // Attempt message retrieval when the controller initially loads.
        self._attemptMessageRetrieval = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Manages functionality of the alert view.
        self._alertView = AlertView(viewController: self)
        
        // If requested, attempt to retrieve messages.
        if self._attemptMessageRetrieval {
            
            self._attemptMessageRetrieval = false

            // Fetch all the messages for the given channel.
            self.pointOfInterest.channel!.messagesBetweenStartDate(nil,
                endDate: nil, limit: 100, offset: 0, ascending: false,
                success: { (totalCount, messages) -> Void in
                    
                    // Cache off all the messages.
                    self._messages = messages as! [MMXMessage]
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Reload the table view.
                        self.tableView.reloadData()
                        
                        // Setup a notifier for receiving further messages.
                        MMX.start()
                        NSNotificationCenter.defaultCenter().addObserver(self,
                            selector: "_didReceiveMessage:",
                            name: MMXDidReceiveMessageNotification, object: nil)
                    }
                },
                failure: { (error) -> Void in

                    // If an error occurred, show an alert.
                    print("ERROR: Failed to fetch messages!")
                    self._alertView!.showAlert(
                        "Message Retrieval Failed",
                        error: error,
                        callback: {() -> Void in })
                })
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pass the selected point-of-interest to the next view.
        if segue.identifier == "MessagesToSpokenSegue" {
            
            let viewController =
            segue.destinationViewController as! PublishSpokenStoryViewController
            
            viewController.pointOfInterest = self.pointOfInterest
            
        } else if segue.identifier == "MessagesToFilmedSegue" {
            
            let viewController =
            segue.destinationViewController as! PublishFilmedStoryViewController
            
            viewController.pointOfInterest = self.pointOfInterest
        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //**************************************************************************
    // MARK: UITableViewDataSource
    //**************************************************************************
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            
        return self._messages.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let message = self._messages[indexPath.row]
        
        if let _ = message.messageContent["spoken"] {
            return _audioStoryCellAtIndexPath(tableView, message: message)
            
        } else if let _ = message.messageContent["filmed"] {
            return _videoStoryCellAtIndexPath(tableView, message: message)
            
        } else {
            // Return a default audio cell for all other cases. Ideally, this
            // case should not happen.
            return _audioStoryCellAtIndexPath(tableView, message: message)
        }
    }
    
    //**************************************************************************
    // MARK: UITableViewDelegate
    //**************************************************************************
    
    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var url: NSURL? = nil
        let message = self._messages[indexPath.row]

        // Retrieve the URL of the story.
        if let messageContent = message.messageContent["spoken"] {
            url = NSURL(string: String(messageContent))
        } else if let _ = message.messageContent["filmed"] {
            url = NSURL(string: String(message.messageContent["videoUrl"]!))
        }
        
        // Play the story, if available.
        if url != nil {
            let player = AVPlayer(URL: url!)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.presentViewController(playerViewController, animated: true,
                completion: nil)
            
            player.play()
        }
    }
}
