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

    var channel: MMXChannel!
    
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
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    func didReceiveMessage(notification: NSNotification) {
        let message: MMXMessage? = (notification.userInfo as! [String:AnyObject]?)![MMXMessageKey] as? MMXMessage;
        
        // Process the message if it's for this channel.
        if (message != nil && message!.channel == self.channel) {
            
            // Append the message and reload the table view.
            self._messages.append(message!)
            self.tableView.reloadData()
        }
    }

    //**************************************************************************
    // MARK: UIViewController
    //**************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).channel = self.channel
        
        // Fetch all the messages for the given channel.
        self.channel.messagesBetweenStartDate(nil, endDate: nil, limit: 25, offset: 0, ascending: false, success: { (totalCount, messages) -> Void in
            
            self._messages = messages as! [MMXMessage]
            dispatch_async(dispatch_get_main_queue()) {
                // Reload the table view.
                self.tableView.reloadData()
                
                // Setup a notifier for receiving further messages.
                MMX.start()
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: "didReceiveMessage:",
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
            
            viewController.channel = self.channel
            
        } else if segue.identifier == "MessagesToSpokenSegue" {
            
            let viewController =
            segue.destinationViewController as! PublishSpokenStoryViewController
            
            viewController.channel = self.channel
            
        } else if segue.identifier == "MessagesToFilmedSegue" {
            
            let viewController =
            segue.destinationViewController as! PublishFilmedStoryViewController
            
            viewController.channel = self.channel
        }
        
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
        let messageContent = message.messageContent["message"]!
        cell.textLabel?.text = "\(messageContent)"
        cell
        
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
        /*
        let message                = self._messages[indexPath.row]
        let messageContent         = message.messageContent as! [String:String]
        
        //var url: NSURL? = NSURL(string: "http://anthonyalayo.com/darkknight.mp3")
        let url: NSURL? = NSURL(string: messageContent["Clip"]!)
        
        let player = AVPlayer(URL: url!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true, completion: nil)
        player.play()
        
        //UIApplication.sharedApplication().openURL(NSURL(string: messageContent["Clip"]!)!)
        */
    }

}