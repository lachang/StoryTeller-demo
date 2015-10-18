//
//  PublishSpokenStoryViewController.swift
//  storyteller-ios
//
//  Created by Anthony Alayo on 10/17/15.
//  Copyright © 2015 storyteller. All rights reserved.
//

import UIKit
import AVFoundation

import MMX

class PublishSpokenStoryViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var channel: MMXChannel!

    @IBOutlet weak var recordButton: UIButton!
    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var playButton: UIButton!
    var audioRecorder: AVAudioRecorder?
    @IBOutlet weak var stopButton: UIButton!
    
    @IBAction func record(sender: AnyObject) {
        if audioRecorder?.recording == false {
            playButton.enabled = false
            stopButton.enabled = true
            audioRecorder?.record()
        }
    }
    
    @IBAction func play(sender: AnyObject) {
        if audioRecorder?.recording == false {
            stopButton.enabled = true
            recordButton.enabled = false
            
            var error: NSError?
            
            do{
                try audioPlayer = AVAudioPlayer(contentsOfURL: (audioRecorder?.url)!)
            }
            catch{
                print("cant play")
            }
            audioPlayer?.delegate = self
            audioPlayer?.play()
    
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        stopButton.enabled = false
        playButton.enabled = true
        recordButton.enabled = true
        
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //playButton.enabled = false
        //stopButton.enabled = false
        
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let soundFilePath = (docsDir as NSString) .stringByAppendingPathComponent("sound.caf")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let recordSettings: [String: AnyObject] =
        [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
         try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        catch
        {
            print("Cant setup audio");
        }
        
        do{
            try audioRecorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings)

        }
        catch
        {
            print("Cannot setup recording object");
        }
        
        audioRecorder?.prepareToRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Arvind to add audio stuff here
     */

    @IBAction func publishSpokenMessage(sender: AnyObject) {
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
        performSegueWithIdentifier("SpokenToMapSegue", sender: sender)
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
