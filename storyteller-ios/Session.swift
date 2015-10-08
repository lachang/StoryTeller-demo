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

class Session: JSONApi {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // The cookie associated with the session, if logged-in.
    private static var _sessionCookie: NSHTTPCookie?
    
    // The name of the session cookie to look for to determine whether one is
    // logged-in or not.
    private static let _tokenName: String = "auth_token"

    // Temporary hard-coded username for logging into Magnet Message.
    private let _username: String = "foobar"
    private let _password: String = "foobar"

    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************

    /**
     * Determine whether a valid login session already exists.
     *
     * :param: N/A
     *
     * :returns: true if logged-in, false otherwise.
     */
    
    class func isValid() -> Bool {
        
        // See if a session cookie already exists.
        //Session._findSessionCookie()
        
        if MMXUser.currentUser() != nil {
            return true
        }
        else {
            return false
        }
    }
    
    /**
     * Remove all cookies from the application's cookie storage.
     *
     * :param: N/A
     *
     * :returns: N/A
     */
    
    class func removeAllCookies() {
        
        // NOTE: Despite the wording "sharedHTTPCookieStorage" below, cookies
        // are not shared amongst applications in IOS.
        
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
        let cookies = cookieStorage.cookies 
        
        if cookies != nil {
            // Loop through and remove all cookies.
            for cookie in cookies! {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    
    //**************************************************************************
    // MARK: Class Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Class Methods (Private)
    //**************************************************************************
    
    /**
     * Find an existing session cookie, if available.
     *
     * NOTE: When running the app through a debugger, it seems like cookies may
     * be temporarily cached and not written out to a file immediately. This can
     * result in subsequent runs of the app not finding the session cookie (even
     * though the cookie had a future expiration date). This should be a
     * debugger-only issue.
     *
     * I've found that if you press the "Home" key before re-running the
     * application, this typically flushes out your cookies to the file so that
     * your next re-run can find the session cookie.
     *
     * http://stackoverflow.com/questions/5747012/nshttpcookies-refuse-to-be-deleted/15198874#15198874
     *
     * :param: N/A
     *
     * :returns: N/A
     */
    
    private class func _findSessionCookie() {
        
        // If no session cookie has been cached yet, try to find one.
        if Session._sessionCookie == nil {
            
            // Retrieve cookies.
            let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
            let cookies = cookieStorage.cookies 
            
            // Find the cookie that confirms whether a valid login session already
            // exists.
            
            if cookies != nil {
                for cookie in cookies! {
                    if cookie.name == Session._tokenName {
                        // Cookie found.
                        Session._sessionCookie = cookie
                    }
                }
                
                if Session._sessionCookie != nil {
                    
                    // If a session cookie was found, ensure that it has not
                    // expired.
                    
                    let currentDate = NSDate();
                    let comparison  = currentDate.compare(
                        Session._sessionCookie!.expiresDate!)
                    
                    if comparison == NSComparisonResult.OrderedDescending {
                        // Session has expired. Remove all cookies for good measure.
                        Session.removeAllCookies()
                        Session._sessionCookie = nil
                    }
                }
            }
        }
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Public)
    //**************************************************************************
    
    /**
     * Initialize a new session.
     *
     * :param: N/A
     *
     * :returns: N/A
     */
    
    override init () {
        super.init()
        
    }
    
    /**
     * Create a new Session instance.
     *
     * :param: email The email handle to login with.
     * :param: password The password to login with.
     * :param: callback Callback invoked once the login attempt completes.
     *
     * :returns: N/A
     */
    
    func login(username: String, password: String,
        callback: ((NSError?) -> Void)) {
        
        // Before logging-in, remove any cookies associated with this
        // application, for good measure. Also reset any previously existing
        // session cookie (though there should not be one since you must logout,
        // which resets the session cookie, before logging-in again).

        Session.removeAllCookies()
        Session._sessionCookie = nil
            
        // Login to Magnet Message (hardcoded for now).
        let credential = NSURLCredential(user: self._username,
            password: self._password, persistence: .None)

        MMXUser.logInWithCredential(credential,
            success: { (user) -> Void in
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
     * :param: callback Callback invoked once the logout attempt completes.
     *
     * :returns: N/A
     */
    
    func logout(callback callback: ((NSError?) -> Void)) {
        
        MMXUser.logOutWithSuccess( { () -> Void in
            
            // Remove the session cookie associated with the login as
            // well as any other cookies associated with this
            // application, for good measure.

            Session.removeAllCookies()
            Session._sessionCookie = nil
            
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