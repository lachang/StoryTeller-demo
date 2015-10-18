//
//  PublishFilmedStoryViewController.swift
//  storyteller-ios
//
//  Created by Anthony Alayo on 10/17/15.
//  Copyright © 2015 storyteller. All rights reserved.
//

import UIKit

import MMX

class PublishFilmedStoryViewController: UIViewController {

    var channel: MMXChannel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * Arvind to add video stuff here
    */

    @IBAction func publishFilmedMessage(sender: AnyObject) {
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
        
        // segue back to channel screen
        performSegueWithIdentifier("FilmedToMapSegue", sender: sender)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
