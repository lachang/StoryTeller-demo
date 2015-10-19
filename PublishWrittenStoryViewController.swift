//******************************************************************************
//  PublishWrittenStoryViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

import MMX

class PublishWrittenStoryViewController: UIViewController {
    
    var pointOfInterest: PointOfInterest!

    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancel(sender: AnyObject) {
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func publishWrittenStory(sender: AnyObject) {
        //add the code to take the message from X and send to server
        let messageContent = ["written" : "Hello Channel!"]
        
        self.pointOfInterest.channel!.publish(messageContent,
            success: {(message) -> Void in
                print("Successfully published to \(self.pointOfInterest.channel!)")
            },
            failure: {(error) -> Void in
                print("Couldn't publish to \(self.pointOfInterest.channel!).\nError= \(error)")
        }) // end of channel.publish()
        
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func publishSpokenStory(sender: AnyObject) {
        //add the code to take the message from X and send to server
        let messageContent = ["spoken" : "http://anthonyalayo.com/haunted.wav"]
        
        self.pointOfInterest.channel!.publish(messageContent,
            success: {(message) -> Void in
                print("Successfully published to \(self.pointOfInterest.channel!)")
            },
            failure: {(error) -> Void in
                print("Couldn't publish to \(self.pointOfInterest.channel!).\nError= \(error)")
        }) // end of channel.publish()
        
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func publishFilmedStory(sender: AnyObject) {
        //add the code to take the message from X and send to server
        let messageContent = ["filmed" : "Kawasaki",
            "videoUrl" : "http://anthonyalayo.com/kawasaki.mp4",
            "imageUrl" : "http://anthonyalayo.com/kawasaki.jpg"]
        
        self.pointOfInterest.channel!.publish(messageContent,
            success: {(message) -> Void in
                print("Successfully published to \(self.pointOfInterest.channel!)")
            },
            failure: {(error) -> Void in
                print("Couldn't publish to \(self.pointOfInterest.channel!).\nError= \(error)")
        }) // end of channel.publish()
        
        // Dismiss this controller.
        self.dismissViewControllerAnimated(true, completion: nil)
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
