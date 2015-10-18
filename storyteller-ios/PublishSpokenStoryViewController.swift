//
//  PublishSpokenStoryViewController.swift
//  storyteller-ios
//
//  Created by Anthony Alayo on 10/17/15.
//  Copyright © 2015 storyteller. All rights reserved.
//

import UIKit

class PublishSpokenStoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func publishSpokenMessage(sender: AnyObject) {
        //add the code to take the message from X and send to server
        
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
