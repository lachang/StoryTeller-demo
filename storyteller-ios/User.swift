//******************************************************************************
//  User.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation
import MMX

/**
 * User
 *
 * Manages user creation and maintenance with the user server.
 */

class User: JSONApi {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    var fullname: String
    var username: String
    var email: String
    
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
    
    /**
     * Initialize a new user.
     *
     * :param: firstname The user's first name.
     * :param: lastname The user's last name.
     * :param: username The user's handle.
     * :param: email The user's email.
     *
     * :returns: N/A
     */
    
    init (firstname: String, lastname: String, username: String, email: String) {
            
        self.fullname = firstname + " " + lastname
        self.username = username
        self.email    = email

        super.init()
    }
    
//    /**
//     * Initialize a new user given a JSON hash.
//     *
//     * :param: json JSON hash from which to initialize the user.
//     *
//     * :returns: N/A
//     */
//
//    convenience init (json: [String:AnyObject]) {
//
//        // Note this is a "convenience" initializer since it calls a different
//        // "designated" initializer.
//        //
//        // http://www.codingricky.com/construtor-chaining-in-swift/
//
//        self.init(firstname: json["first_name"] as! String,
//            lastname: json["last_name"] as! String,
//            username: json["user_name"] as! String,
//            email: json["email"] as! String)
//    }

    /**
     * Create a new User instance.
     *
     * :param: firstName The first name of the user to create.
     * :param: lastname The last name of the user to create.
     * :param: email The email handle for the user to create.
     * :param: password The password for the user to create.
     * :param: callback Callback invoked once the user creation attempt
     *                  completes.
     *
     * :returns: N/A
     */
    
    func signup(password password: String, callback: ((NSError?) -> Void)) {
        
        // Signup for Magnet Message (hardcoded for now).
        MMXClient.sharedClient().accountManager.createAccountForUsername(
            self.username, displayName: self.fullname,
            email: self.email, password: password,
            success: { (profile) -> Void in
                callback(nil)
            },
            failure: { (error) -> Void in
                print("ERROR: Failed to signup!")
                callback(error)
            })        
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}