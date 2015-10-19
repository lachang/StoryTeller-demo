//******************************************************************************
//  Session.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation
import MMX

/**
 * Session
 *
 * Manages login and logout to and from the session server.
 */

class Session: NSObject {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    // The credential associated with a user. This can come from either a user
    // logging-in or from the credential storage.
    static var sessionCredential: NSURLCredential?
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // The protection space associated with the session credential.
    private static var _sessionProtectionSpace: NSURLProtectionSpace?

    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************

    /**
     * Determine whether a valid login session already exists.
     *
     * - parameter N/A
     *
     * - returns: true if logged-in, false otherwise.
     */
    
    class func isValid() -> Bool {
        
        // See if a session credential already exists.
        Session._findSessionCredential()
        
        // The session is valid if previous credentials exist "and" the user has
        // authenticated with Magnet Message.
        if Session.sessionCredential != nil &&
            MMXClient.sharedClient().connectionStatus == MMXConnectionStatus.Authenticated {
            return true
        }
        else {
            return false
        }
    }

    //**************************************************************************
    // MARK: Class Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Private)
    //**************************************************************************
    
    /**
     * Find an existing session credential, if available.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    
    private class func _findSessionCredential() {
        
        // If no session credential has been cached yet, try to find one.
        if Session.sessionCredential == nil {
            
            Session._sessionProtectionSpace =
                Session._getSessionProtectionSpace()
            
            let credentialStorage = NSURLCredentialStorage.sharedCredentialStorage()
            Session.sessionCredential =
                credentialStorage.defaultCredentialForProtectionSpace(Session._sessionProtectionSpace!)
        }
    }

    /**
     * Retrieves the protection space to use for the session credential.
     *
     * - parameter N/A
     *
     * - returns: Protection space
     */
    
    class func _getSessionProtectionSpace() -> NSURLProtectionSpace {
        
        let url = MMXClient.sharedClient().configuration.baseURL
        let protectionSpace = NSURLProtectionSpace(host: url.host!,
            port: url.port!.integerValue, `protocol`: url.scheme,
            realm: nil, authenticationMethod: nil)
        
        return protectionSpace
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Initialize a new session.
     *
     * - parameter N/A
     *
     * - returns: N/A
     */
    override init () {
        super.init()
    }
    
    /**
     * Create a new Session instance.
     *
     * - parameter email: The email handle to login with.
     * - parameter password: The password to login with.
     * - parameter callback: Callback invoked once the login attempt completes.
     *
     * :returns: N/A
     */
    
    func login(username: String, password: String,
        callback: ((NSError?) -> Void)) {
        
        // Before logging-in, reset any previously existing session credential
        // (though there should not be one since you must logout, which resets
        // the session credential, before logging-in again).

        Session.sessionCredential = nil
        Session._sessionProtectionSpace = nil
            
        // Login to Magnet Message.
        let credential = NSURLCredential(user: username, password: password,
            persistence: .Permanent)

        MMXUser.logInWithCredential(credential,
            success: { (user) -> Void in
                
                // Save the Magnet Message credential into the credential
                // storage.
                //
                // http://stackoverflow.com/questions/8565087/afnetworking-and-cookies/17997943#17997943

                let credential =
                    MMXClient.sharedClient().configuration.credential
                
                Session._sessionProtectionSpace =
                    Session._getSessionProtectionSpace()
                
                // Save the credential as default. If the credential does not
                // already exist in the credential storage it will be added
                // automatically first before setting as the default. Otherwise,
                // if it does exist (i.e. in the case of auto-login), it will
                // just be set as the default... which it should technically
                // already be.

                let credentialStorage = NSURLCredentialStorage.sharedCredentialStorage()
                credentialStorage.setDefaultCredential(credential,
                    forProtectionSpace: Session._sessionProtectionSpace!)
                
                // Re-retrieve the session credential that was just stored.
                Session._findSessionCredential()
                
                // Save off the currently logged-in user.
                let loggedInUser = User(mmxUser: user)
                User.currentUser(loggedInUser)
                
                callback(nil)
            },
            failure: { (error) -> Void in
                print("ERROR: Failed to login!")
                callback(error)
            })
    }
    
    /**
     * Destroy an existing Session instance.
     *
     * - parameter callback: Callback invoked once the logout attempt completes.
     *
     * - returns: N/A
     */
    
    func logout(callback callback: ((NSError?) -> Void)) {
        
        MMXUser.logOutWithSuccess( { () -> Void in

            // Remove the Magnet Message credential from the credential storage.
            let credentialStorage = NSURLCredentialStorage.sharedCredentialStorage()
            credentialStorage.removeCredential(Session.sessionCredential!,
                forProtectionSpace: Session._sessionProtectionSpace!)
            
            // Reset the session credential associated with the login.
            Session.sessionCredential = nil
            Session._sessionProtectionSpace = nil
            
            callback(nil)
        },
        failure: { (error) -> Void in
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