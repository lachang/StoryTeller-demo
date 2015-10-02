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
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    @IBAction func _leaveMemory(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://2142349963")!)
    }
    
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
        let messageContent         = message.messageContent as! [String:String]
        
        let str: NSMutableAttributedString =
        NSMutableAttributedString(string: "Clip")
        str.addAttribute(NSLinkAttributeName, value: messageContent["Clip"]!, range: NSMakeRange(0, str.length))
        cell.textLabel!.attributedText = str
        cell.detailTextLabel!.text = message.sender.displayName

        return cell
    }
    
    //**************************************************************************
    // MARK: UITableViewDelegate
    //**************************************************************************
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let message                = self._messages[indexPath.row]
        let messageContent         = message.messageContent as! [String:String]
        
        //var url: NSURL? = NSURL(string: "http://anthonyalayo.com/darkknight.mp3")
        let url: NSURL? = NSURL(string: messageContent["Clip"]!)
        
        let player = AVPlayer(URL: url!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true, completion: nil)
        
        //UIApplication.sharedApplication().openURL(NSURL(string: messageContent["Clip"]!)!)
    }

}