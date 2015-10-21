//******************************************************************************
//  PublishSpokenStoryViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import AVFoundation

import MMX
import AWSS3

/**
 * PublishSpokenStoryViewController
 *
 * Manages recording, playback, and creation of an audio story.
 */

class PublishSpokenStoryViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var messageName: UITextField!
    @IBOutlet var record: UIButton!
    @IBOutlet var playback: UIButton!
    @IBOutlet var reset: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var pointOfInterest: PointOfInterest!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    private var _audioPlayer: AVAudioPlayer?
    private var _audioRecorder: AVAudioRecorder?
    private var _audioFileUrl: NSURL?
    
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
            assert(self._audioRecorder!.recording == false)
            
            self.record.setTitle("Stop", forState: .Normal)
            self.activityIndicator.hidden = false
            
            self._audioRecorder!.record()
        }
        else if text == "Stop" {
            assert(self._audioRecorder!.recording == true)
            
            self._audioRecorder!.stop()

            self.activityIndicator.hidden = true
            self.record.setTitle("Publish", forState: .Normal)
            
            self.messageName.hidden = false
            self.playback.hidden = false
            self.reset.hidden = false
        }
        else if text == "Publish" {
            assert(self._audioRecorder!.recording == false)
            
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

        assert(self._audioRecorder!.recording == false)
        
        if self.playback.titleLabel!.text == "Playback" {

            do {
                try self._audioPlayer = AVAudioPlayer(
                    contentsOfURL: (self._audioRecorder?.url)!)
            }
            catch {
                // If an error occurred, show an alert.
                self._alertView!.showAlert(
                    "Error occurred",
                    message: "Cannot play audio.",
                    callback: {() -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            self.playback.setTitle("Playback", forState: .Normal)
                        }
                    })
            }

            self.playback.setTitle("Stop", forState: .Normal)
            
            self._audioPlayer?.delegate = self
            self._audioPlayer?.play()
        }
        else if self.playback.titleLabel!.text == "Stop" {

            self._audioPlayer?.stop()
            
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
        
        assert(self._audioRecorder!.recording == false)
        
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
     * Arvind to add audio stuff here
     */
    
    func _publish() {
        
        
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        let filename = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".caf")
        
        uploadRequest1.bucket = config.S3BucketName
        uploadRequest1.key = filename
        uploadRequest1.body = self._audioFileUrl
        
        transferManager.upload(uploadRequest1).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        default:
                            print("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                    }
                } else {
                    print("upload() failed: [\(error)]")
                }
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
            }
        return nil
        }
        let awsLink = "https://s3.amazonaws.com/storyteler/"
        let fulllink = awsLink + filename
        let messageContent = ["spoken" : fulllink]

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
        
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        let docsDir = dirPaths[0]
        let soundFilePath = (docsDir as NSString) .stringByAppendingPathComponent("sound.caf")
        self._audioFileUrl = NSURL(fileURLWithPath: soundFilePath)
        //let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let recordSettings: [String: AnyObject] =
        [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        catch {
            // If an error occurred, show an alert.
            self._alertView!.showAlert(
                "Error occurred",
                message: "Cannot setup audio.",
                callback: {() -> Void in
                    // Dismiss this controller.
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
        }
        
        do {
            try self._audioRecorder =
                AVAudioRecorder(URL: self._audioFileUrl!, settings: recordSettings)
            
        }
        catch {
            // If an error occurred, show an alert.
            self._alertView!.showAlert(
                "Error occurred",
                message: "Cannot setup recording device.",
                callback: {() -> Void in
                    // Dismiss this controller.
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
        }
        
        self._audioRecorder!.prepareToRecord()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Release the alert view's reference to this view controller.
        self._alertView = nil
    }
}
