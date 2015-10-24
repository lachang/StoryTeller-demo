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

class User: NSObject {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    // Various error codes.
    static let errorShowCode = 1
    
    // First and last name of the user.
    var fullname: String
    
    // User handle.
    var username: String
    
    // Email address for the user.
    var email:    String?
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // Currently logged-in user, if any. "static" since there can only be one
    // user logged-in at a time.
    private static var _currentUser: User? = nil
    
    // Denotes whether a call to the server is needed later to retrieve user
    // details.
    private var _needsDetails = false
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    /**
     * Get the currently logged-in user, if any.
     *
     * - parameter N/A
     *
     * - returns: The logged-in User instance.
     */
    
    class func currentUser() -> User? {
        return User._currentUser
    }

    /**
     * Set the currently logged-in user, if any.
     *
     * - parameter user The logged-in User instance.
     *
     * - returns: N/A
     */
    
    class func currentUser(user: User?) {
        User._currentUser = user
    }
    
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
     * - parameter fullname: The user's full name.
     * - parameter username: The user's handle.
     * - parameter email: The user's email.
     *
     * - returns: N/A
     */
    
    init (fullname: String, username: String, email: String?) {

        self.fullname = fullname
        self.username = username
        
        if email != nil {
            self.email = email!
        }
        
        super.init()
    }
    
    /**
     * Initialize a new user given a first and last name as well as their
     * username and email.
     *
     * - parameter firstname: The user's first name.
     * - parameter lastname: The user's last name.
     * - parameter username: The user's handle.
     * - parameter email: The user's email.
     *
     * - returns: N/A
     */
    
    convenience init (firstname: String, lastname: String, username: String, email: String) {
        
        // Note this is a "convenience" initializer since it calls a different
        // "designated" initializer.
        //
        // http://www.codingricky.com/construtor-chaining-in-swift/

        self.init(fullname: firstname + " " + lastname, username: username,
            email: email)
    }
    
    convenience init (mmxUser: MMXUser) {
        
        // Note this is a "convenience" initializer since it calls a different
        // "designated" initializer.
        //
        // http://www.codingricky.com/construtor-chaining-in-swift/
        
        self.init(fullname: mmxUser.displayName, username: mmxUser.username,
            email: nil)
        
        // Set the "needs details" flag since an MMXUser instance does not
        // include all details such as the user's email address.

        self._needsDetails = true
    }

    /**
     * Create a new User instance.
     *
     * - parameter password: The password for the user to create.
     * - parameter callback: Callback invoked once the user creation attempt
     *                       completes.
     *
     * - returns: N/A
     */
    
    func signup(password password: String, callback: ((NSError?) -> Void)) {
        
        // Signup for Magnet Message.
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
    
    /**
     * Retrieve details of a User instance.
     *
     * - parameter callback: Callback invoked once the details retrieval attempt
     *                       completes.
     *
     * - returns: N/A
     */
    func show(callback callback: ((NSError?) -> Void)) {
        
        if User.currentUser() != nil && User.currentUser()! == self {
            
            // Get the shared MMX Account Manager.
            let mmxAccountManager = MMXClient.sharedClient().accountManager
            
            // For the currently logged-in user, retrieve deatils via the
            // MMXAccountManager if necessary.
            
            if self._needsDetails {
                mmxAccountManager.userProfileWithSuccess(
                    {(profile) -> Void in
                        
                        // Cache off the retrieved email address and invoke the
                        // callback.
                        
                        self.email = profile.email
                        callback(nil)
                        
                    }, failure: {(error) -> Void in

                        // Invoke the callback.
                        print("ERROR: Failed to retrieve user info!")
                        callback(error)
                    })
            }
            else {
                // Invoke the callback with no error since no additional details
                // need to be retrieved.
                
                callback(nil)
            }
        }
        else {
            
            // For other users, the show method is not currently allowed.
            
            let userInfo = [
                NSLocalizedDescriptionKey: "Invalid User",
                NSLocalizedFailureReasonErrorKey: "Cannot get details for the given user."
            ]
            let error = NSError(domain: "User",
                code: User.errorShowCode,
                userInfo: userInfo)
            
            // Invoke the callback.
            print("ERROR: Failed to retrieve user info!")
            callback(error)
        }
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}