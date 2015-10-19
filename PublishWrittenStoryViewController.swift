//******************************************************************************
//  PublishWrittenStoryViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit

class PublishWrittenStoryViewController: UIViewController {
    
    var pointOfInterest: PointOfInterest!

    // Manages the alert view.
    private var _alertView: AlertView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func getTags(sender: AnyObject) {
        self.pointOfInterest.getTags()
    }
    
    @IBAction func setTags(sender: AnyObject) {
        
        let alertController = UIAlertController(
            title: "Add tags",
            message: "Please enter space separated tags",
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .Default)
            { (action) -> Void in
                
                if let nameField = alertController.textFields?.first {
                    if nameField.text == "" {
                        // TODO: handle this case
                    } else {
                        self.pointOfInterest.setTags("hello")
                    }
                }
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Cancel)
            { (action) -> Void in
                // do nothing
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextFieldWithConfigurationHandler { (UITextField) -> Void in
            UITextField.placeholder = "Storypoint name"
        }
        
        presentViewController(alertController, animated: true, completion: nil)
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
        
        self.pointOfInterest.addMessage(messageContent,
            callback: {(error) -> Void in
                
                if (error != nil) {
                    // If an error occurred, show an alert.
                    var message = error!.localizedDescription
                    if error!.localizedFailureReason != nil {
                        message = error!.localizedFailureReason!
                    }
                    self._alertView!.showAlert(
                        "Story Failed to Add!",
                        message: message,
                        callback: nil)
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self._alertView!.showAlert(
                            "Success!",
                            message: "Story was added.",
                            callback: {() -> Void in
                                // Dismiss this controller.
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                    }
                }
            })
    }
    
    @IBAction func publishSpokenStory(sender: AnyObject) {
        //add the code to take the message from X and send to server
        let messageContent = ["spoken" : "http://anthonyalayo.com/haunted.wav"]
        
        self.pointOfInterest.addMessage(messageContent,
            callback: {(error) -> Void in
                
                if (error != nil) {
                    // If an error occurred, show an alert.
                    var message = error!.localizedDescription
                    if error!.localizedFailureReason != nil {
                        message = error!.localizedFailureReason!
                    }
                    self._alertView!.showAlert(
                        "Story Failed to Add!",
                        message: message,
                        callback: nil)
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self._alertView!.showAlert(
                            "Success!",
                            message: "Story was added.",
                            callback: {() -> Void in
                                // Dismiss this controller.
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                }
            })
    }
    
    
    @IBAction func publishFilmedStory(sender: AnyObject) {
        //add the code to take the message from X and send to server
        let messageContent = ["filmed" : "Kawasaki",
            "videoUrl" : "http://anthonyalayo.com/kawasaki.mp4",
            "imageUrl" : "http://anthonyalayo.com/kawasaki.jpg"]
        
        self.pointOfInterest.addMessage(messageContent,
            callback: {(error) -> Void in
                
                if (error != nil) {
                    // If an error occurred, show an alert.
                    var message = error!.localizedDescription
                    if error!.localizedFailureReason != nil {
                        message = error!.localizedFailureReason!
                    }
                    self._alertView!.showAlert(
                        "Story Failed to Add!",
                        message: message,
                        callback: nil)
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self._alertView!.showAlert(
                            "Success!",
                            message: "Story was added.",
                            callback: {() -> Void in
                                // Dismiss this controller.
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                }
            })
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
