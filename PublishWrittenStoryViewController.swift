//
//  PublishWrittenStoryViewController.swift
//  
//
//  Created by Anthony Alayo on 10/17/15.
//
//

import UIKit

import MMX

class PublishWrittenStoryViewController: UIViewController {
    
    
    var channel: MMXChannel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func publishWrittenMessage(sender: AnyObject) {
        //add the code to take the message from X and send to server
        let messageContent = ["message" : "Hello Channel!"]
        
        channel.publish(messageContent,
            success: {(message) -> Void in
                print("Successfully published to \(self.channel)")
            },
            failure: {(error) -> Void in
                print("Couldn't publish to \(self.channel).\nError= \(error)")
        }) // end of channel.publish()
        
        // segue back to channel screen
        performSegueWithIdentifier("WrittenToMapSegue", sender: sender)
    }
    
    
    
}
