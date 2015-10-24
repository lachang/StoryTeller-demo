//******************************************************************************
//  PublishSpokenStoryViewController.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import UIKit
import AVFoundation

import AWSS3

/**
 * PublishSpokenStoryViewController
 *
 * Manages recording, playback, and creation of an audio story.
 */

class PublishSpokenStoryViewController: UIViewController, AVAudioPlayerDelegate,
AVAudioRecorderDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    @IBOutlet var messageName: UITextField!
    @IBOutlet var record: UIButton!
    @IBOutlet var playback: UIButton!
    @IBOutlet var reset: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // The PointOfInterest instance to add the story to.
    var pointOfInterest: PointOfInterest!
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // Used to playback audio.
    private var _audioPlayer: AVAudioPlayer?
    
    // Used to record audio.
    private var _audioRecorder: AVAudioRecorder?
    
    // Temporary file to save the audio.
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
            
            // Transition the button from "Record" -> "Stop".
            self.record.setTitle("Stop", forState: .Normal)
            self.activityIndicator.hidden = false

            // Start recording.
            self._audioRecorder!.record()
        }
        else if text == "Stop" {
            assert(self._audioRecorder!.recording == true)

            // Stop recording.
            self._audioRecorder!.stop()

            // Transition the button from "Stop" -> "Publish".
            self.activityIndicator.hidden = true
            self.record.setTitle("Publish", forState: .Normal)
            
            // Show other buttons / fields related to publishing.
            self.messageName.hidden = false
            self.playback.hidden = false
            self.reset.hidden = false
        }
        else if text == "Publish" {
            assert(self._audioRecorder!.recording == false)
            
            // Publish the recording.
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
                    contentsOfURL: (self._audioRecorder!.url))
            }
            catch {
                // If an error occurred, show an alert.
                self._alertView!.showAlert(
                    "Error Occurred",
                    message: "Cannot play audio.",
                    callback: {() -> Void in })
                return
            }

            // Transition the button from "Playback" -> "Stop".
            self.playback.setTitle("Stop", forState: .Normal)
            
            // Play the recording.
            self._audioPlayer?.delegate = self
            self._audioPlayer?.play()
        }
        else if self.playback.titleLabel!.text == "Stop" {

            self._audioPlayer?.stop()
            self._audioPlayer?.delegate = nil
            
            // Transition the button from "Stop" -> "Playback".
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
    
    /**
     * Publishes the recording to the server.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */

    private func _publish() {

        if (messageName.text!.isEmpty) {
            // If an error occurred, show an alert.
            self._alertView!.showAlert(
                "Invalid Name",
                message: "Story name cannot be blank.",
                callback: nil)
        }
        else {
        
            self.activityIndicator.hidden = false
            self.messageName.enabled = false
            self.record.hidden = true
            self.playback.hidden = true
            self.reset.hidden = true
            
            // Create a unique string to use for the filename.
            let filename = self._makeFilename()

            // Create an upload request to AWS.
            let uploadRequest    = AWSS3TransferManagerUploadRequest()
            uploadRequest.bucket = config.S3BucketName
            uploadRequest.key    = filename
            uploadRequest.body   = self._audioFileUrl
            
            // Create a transfer manager to AWS.
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            transferManager.upload(uploadRequest).continueWithBlock(
                {(task) -> AnyObject! in
                    
                    if task.error != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            // If an error occurred, show an alert.
                            self._alertView?.showAlert(
                                "Publish Failed",
                                error: task.error,
                                callback: nil)
                            
                            self.activityIndicator.hidden = true
                            self.messageName.enabled = true
                            self.record.hidden = false
                            self.playback.hidden = false
                            self.reset.hidden = false
                        }
                    }
                    else {
                        print("Upload of \(filename) succeeded!")

                        // Now that the upload is complete, create a message
                        // associated with the recording onto the current
                        // point-of-interest.

                        let url = config.S3Domain +
                                  config.S3BucketName +
                                  "/" +
                                  filename

                        let messageContent = [
                            "spoken":url,
                            "titleName":self.messageName.text!
                        ]
                        
                        self.pointOfInterest.addMessage(messageContent,
                            callback: {(error) -> Void in
                                
                                if (error != nil) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        // If an error occurred, show an alert.
                                        self._alertView!.showAlert(
                                            "Story Failed to Add!",
                                            error: error!,
                                            callback: nil)
                                        
                                        self.activityIndicator.hidden = true
                                        self.messageName.enabled = true
                                        self.record.hidden = false
                                        self.playback.hidden = false
                                        self.reset.hidden = false
                                    }
                                }
                                else {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self._alertView!.showAlert(
                                            "Success!",
                                            message: "Story was added.",
                                            callback: {() -> Void in
                                                // Dismiss this controller.
                                                self.dismissViewControllerAnimated(true,
                                                    completion: nil)
                                        })
                                    }
                                }
                            })
                    }
                    return nil
                })
        }
    }
    
    /**
     * Construct the filename for use on the server.
     *
     * - parameter N/A
     *
     * - returns: Constructed filename
     */
    
    private func _makeFilename() -> String {
        
        let time = NSDate().timeIntervalSince1970
        let filename = User.currentUser()!.username + "_" + String(time)
        return filename.stringByAppendingString(".caf")
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
        
        // Construct the filename that will temporiarly hold the recordings.
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(
            .DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("sound.caf")
        self._audioFileUrl = fileURL
        
        // Setup the audio context.
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
                "Error Occurred",
                message: "Cannot setup audio.",
                callback: {() -> Void in
                    // Dismiss this controller.
                    self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        
        // Create the audio recorder.
        do {
            try self._audioRecorder =
                AVAudioRecorder(URL: self._audioFileUrl!,
                    settings: recordSettings)
        }
        catch {
            // If an error occurred, show an alert.
            self._alertView!.showAlert(
                "Error Occurred",
                message: "Cannot setup recording device.",
                callback: {() -> Void in
                    // Dismiss this controller.
                    self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        
        // Prepare the recorder ahead of time to create the temporary file for
        // the recording in order to start recording later more quickly.

        self._audioRecorder!.prepareToRecord()
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
    
    //**************************************************************************
    // MARK: AVAudioPlayerDelegate
    //**************************************************************************

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer,
        successfully flag: Bool) {

        player.delegate = nil
            
        // Transition the button from "Stop" -> "Playback".
        self.playback.setTitle("Playback", forState: .Normal)
    }
}
