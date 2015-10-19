//******************************************************************************
//  MessagesViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import AVKit
import AVFoundation

import MMX

/**
 * MessagesViewController
 *
 * Displays the messages within a channel.
 */
class MessagesViewController: UITableViewController {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    var pointOfInterest: PointOfInterest!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    var _messages: [MMXMessage] = []
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Private)
    //**************************************************************************
    
    @IBAction func leaveMemory(sender: AnyObject) {
        
        let alertViewController =
        UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Add a logout button.
        let alertActionWriteStory = UIAlertAction(
            title: "Write Your Story",
            style: UIAlertActionStyle.Default,
            handler: _writeYourStory)
        alertViewController.addAction(alertActionWriteStory)
        
        // Add a logout button.
        let alertActionSayStory = UIAlertAction(
            title: "Say Your Story",
            style: UIAlertActionStyle.Default,
            handler: _sayYourStory)
        alertViewController.addAction(alertActionSayStory)
     
        // Add a logout button.
        let alertActionFilmStory = UIAlertAction(
            title: "Film Your Story",
            style: UIAlertActionStyle.Default,
            handler: _filmYourStory)
        alertViewController.addAction(alertActionFilmStory)
        
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
    
    private func _writeYourStory(sender: UIAlertAction!)
    {
        self.performSegueWithIdentifier("MessagesToWrittenSegue", sender: self)
    }
    
    private func _sayYourStory(sender: UIAlertAction!)
    {
        self.performSegueWithIdentifier("MessagesToSpokenSegue", sender: self)
    }
    
    private func _filmYourStory(sender: UIAlertAction!)
    {
        self.performSegueWithIdentifier("MessagesToFilmedSegue", sender: self)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Triggered when the user presses the back button.
     *
     * :param: sender The source that triggered this function.
     *
     * :returns: N/A
     */
    
    @IBAction func back(sender: AnyObject) {
        // Dismiss this controller.
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
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
    
    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch all the messages for the given channel.
        self.pointOfInterest.channel!.messagesBetweenStartDate(nil, endDate: nil, limit: 25, offset: 0, ascending: false, success: { (totalCount, messages) -> Void in
            
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
            }, failure: { (error) -> Void in
                print("ERROR: Failed to fetch messages!")
            })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pass the selected channel to the messages view.
        if segue.identifier == "MessagesToWrittenSegue" {
            
            let viewController =
            segue.destinationViewController as! PublishWrittenStoryViewController
            
            viewController.pointOfInterest = self.pointOfInterest
            
        } else if segue.identifier == "MessagesToSpokenSegue" {
            
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Message Cell", forIndexPath: indexPath)
        
        // Display the message content to the table cell.
        let message                = self._messages[indexPath.row]
        //let messageContent         = message.messageContent as! [String:String]
        //let messageContent = message.messageContent["message"]!
        

        if let messageContent = message.messageContent["written"] {
            cell.textLabel?.text = "\(messageContent)"
        } else if let messageContent = message.messageContent["spoken"] {
            cell.textLabel?.text = "\(messageContent)"
        } else if let messageContent = message.messageContent["filmed"] {
            cell.textLabel?.text = "\(messageContent)"
        } else {
            let messageContent = message.messageContent["message"]!
            cell.textLabel?.text = "\(messageContent)"
        }
        
        /*
        let str: NSMutableAttributedString =
        NSMutableAttributedString(string: "Clip")
        str.addAttribute(NSLinkAttributeName, value: messageContent["Clip"]!, range: NSMakeRange(0, str.length))
        cell.textLabel!.attributedText = str
        cell.detailTextLabel!.text = message.sender.displayName
        */

        return cell
    }
    
    //**************************************************************************
    // MARK: UITableViewDelegate
    //**************************************************************************
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let message = self._messages[indexPath.row]

        if let messageContent = message.messageContent["spoken"] {
            // for now grab the messageContent as url
            // TODO: clean this code up
            let url: NSURL? = NSURL(string: String(messageContent))
            let player = AVPlayer(URL: url!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.presentViewController(playerViewController, animated: true, completion: nil)
            player.play()
        } else if let _ = message.messageContent["filmed"] {
            // for now grab the video url
            // TODO: clean this code up
            let url: NSURL? = NSURL(string: String(message.messageContent["videoUrl"]!))
            let player = AVPlayer(URL: url!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.presentViewController(playerViewController, animated: true, completion: nil)
            player.play()
        }
    
        /* The dream...
        
        if let messageContent = message.messageContent["written"] {
            // do nothing
        } else if let messageContent = message.messageContent["spoken"] {
            let url: NSURL? = NSURL(string: String(messageContent))
            
            let player = AVPlayer(URL: url!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.presentViewController(playerViewController, animated: true, completion: nil)
            player.play()
            
        } else if let messageContent = message.messageContent["filmed"] {
            // do nothing
        } else {
            // do nothing
        }
        */
        
    }

}