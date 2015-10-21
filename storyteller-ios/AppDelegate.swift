//
//  AppDelegate.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//

import UIKit

// Magnet Message
import MMX
import AWSS3
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    var window: UIWindow?

    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
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

    func switchToInitialView() {
        
        // Determine whether the user needs to login.
        //
        // http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou?lq=1
        
        var viewController: UIViewController
        
        /*
         * Add Arvind's Authentication for AWS here
           Create a model for AWSSession
           Call your validation function here
           example : class func isValid() -> Bool
         */
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: config.CognitoRegionType, identityPoolId: config.CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: config.DefaultServiceRegionType, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        if Session.isValid() {
            viewController =
                UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        }
        else {
            viewController =
                UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WelcomeView")
        }
        
        // http://stackoverflow.com/questions/7703806/rootviewcontroller-switch-transition-animation
        UIView.transitionWithView(self.window!,
            duration: 0.5,
            options: .TransitionFlipFromRight,
            animations: { () -> Void in

                // This fixes some odd animation artifacts that occur when
                // switching to the new view.
                //
                // http://stackoverflow.com/questions/8053832/rootviewcontroller-animation-transition-initial-orientation-is-wrong

                let oldState = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                self.window?.rootViewController = viewController
                UIView.setAnimationsEnabled(oldState)
            },
            completion: nil)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************

    //**************************************************************************
    // MARK: UIApplicationDelegate
    //**************************************************************************
    
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            
        // Override point for customization after application launch.

        // Initialize Magnet Message
        MMX.setupWithConfiguration("default")

        // Switch to the initial view.
        self.switchToInitialView()
            
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        //
        // Sent when the application is about to move from active to inactive
        // state. This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user
        // quits the application and it begins the transition to the background
        // state.
        //
        // Use this method to pause ongoing tasks, disable timers, and throttle
        // down OpenGL ES frame rates. Games should use this method to pause the
        // game.
        //
    }

    func applicationDidEnterBackground(application: UIApplication) {
        //
        // Use this method to release shared resources, save user data,
        // invalidate timers, and store enough application state information to
        // restore your application to its current state in case it is
        // terminated later.
        //
        // If your application supports background execution, this method is
        // called instead of applicationWillTerminate: when the user quits.
        //
    }

    func applicationWillEnterForeground(application: UIApplication) {
        //
        // Called as part of the transition from the background to the inactive
        // state; here you can undo many of the changes made on entering the
        // background.
        //
    }

    func applicationDidBecomeActive(application: UIApplication) {
        //
        // Restart any tasks that were paused (or not yet started) while the
        // application was inactive. If the application was previously in the
        // background, optionally refresh the user interface.
        //
    }

    func applicationWillTerminate(application: UIApplication) {
        //
        // Called when the application is about to terminate. Save data if
        // appropriate. See also applicationDidEnterBackground:.
        //
    }
}
