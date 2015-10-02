//******************************************************************************
//  JSONApi.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation

/**
 * JSONApi
 *
 * Implements common JSON API requests / responses to a given URL.
 */

class JSONApi: NSObject {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    // Various error codes.
    static let errorIndexCode  = 1
    static let errorCreateCode = 2
    static let errorUpdateCode = 3
    static let errorDestroyCode = 4
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // The JSON connection used to manage JSON API requests / responses to and
    // from the password reset server.
    internal static var _connection: JSONConnection = JSONConnection()
    
    private static var _errorMsgConnectionFailure: String = "Connection failed."
    private static var _errorMsgErrorResponse: String     = "Connection succeeded, but an error response was received."
    
    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    /**
     * Index
     *
     * - parameter url: The URL string to make the request to.
     * - parameter parameters: The query parameters to send with the request (optional).
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    class func index (url: String, parameters: [String : String]?,
        callback: (([[String:AnyObject]], NSError?) -> Void)) {
            
        JSONApi._connection.get(
            url,
            parameters: parameters,
            callback: { (json, httpResponse, error) -> Void in
                
                var response: [[String:AnyObject]] = []
                var err: NSError?
                if (error == nil) {
                    
                    // If the connection returned an error response, pass back a
                    // corresponding NSError to the caller.
                    
                    if (httpResponse!.statusCode != 200) {
                        
                        var errDomain: String
                        if (json != nil && httpResponse!.statusCode == 422) {
                            errDomain = JSONErrors.firstError(json as! NSDictionary)
                        }
                        else {
                            errDomain = JSONApi._errorMsgErrorResponse
                        }
                        
                        err = NSError(
                            domain: errDomain,
                            code: JSONApi.errorIndexCode,
                            userInfo: nil)
                    }
                    else {
                        response = json as! [[String:AnyObject]]
                    }
                }
                else {
                    // Return a generic error.
                    err = NSError(
                        domain: JSONApi._errorMsgConnectionFailure,
                        code: JSONApi.errorIndexCode,
                        userInfo: nil)
                }
                
                // Invoke the callback.
                callback(response, err)
            })
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
     * Create
     *
     * - parameter url: The URL string to make the request to.
     * - parameter parameters: The parameters to send with the request.
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    func create (url: String, parameters: [String : AnyObject],
        callback: ((NSError?) -> Void)) {

        JSONApi._connection.post(
            url,
            parameters: parameters,
            callback: { (json, httpResponse, error) -> Void in
                
                var err: NSError?
                if (error == nil) {
                    
                    // If the connection returned an error response, pass back a
                    // corresponding NSError to the caller.
                    
                    if (httpResponse!.statusCode != 201) {
                        
                        var errDomain: String
                        if (json != nil && httpResponse!.statusCode == 422) {
                            errDomain = JSONErrors.firstError(json as! NSDictionary)
                        }
                        else {
                            errDomain = JSONApi._errorMsgErrorResponse
                        }
                        
                        err = NSError(
                            domain: errDomain,
                            code: JSONApi.errorCreateCode,
                            userInfo: nil)
                    }
                }
                else {
                    // Return a generic error.
                    err = NSError(
                        domain: JSONApi._errorMsgConnectionFailure,
                        code: JSONApi.errorCreateCode,
                        userInfo: nil)
                }
                
                // Invoke the callback.
                callback(err)
        })
    }
    
    /**
     * Update
     *
     * - parameter url: The URL string to make the request to.
     * - parameter parameters: The query parameters to send with the request (optional).
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    func update (url: String, parameters: [String : AnyObject],
        callback: ((NSError?) -> Void)) {

        JSONApi._connection.put(
            url,
            parameters: parameters,
            callback: { (json, httpResponse, error) -> Void in
                
                var err: NSError?
                if (error == nil) {
                    
                    // If the connection returned an error response, pass back a
                    // corresponding NSError to the caller.
                    
                    if (httpResponse!.statusCode != 200) {
                        
                        var errDomain: String
                        if (json != nil && httpResponse!.statusCode == 422) {
                            errDomain = JSONErrors.firstError(json as! NSDictionary)
                        }
                        else {
                            errDomain = JSONApi._errorMsgErrorResponse
                        }
                        
                        err = NSError(
                            domain: errDomain,
                            code: JSONApi.errorUpdateCode,
                            userInfo: nil)
                    }
                }
                else {
                    // Return a generic error.
                    err = NSError(
                        domain: JSONApi._errorMsgConnectionFailure,
                        code: JSONApi.errorUpdateCode,
                        userInfo: nil)
                }
                
                // Invoke the callback.
                callback(err)
        })
    }
    
    /**
     * Destroy
     *
     * - parameter url: The URL string to make the request to.
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    func destroy (url: String, callback: ((NSError?) -> Void)) {
        
        JSONApi._connection.delete(
            url,
            callback: { (json, httpResponse, error) -> Void in
                
                var err: NSError?
                if (error == nil) {
                    
                    // If the connection returned an error response, pass back a
                    // corresponding NSError to the caller.
                    
                    if (httpResponse!.statusCode != 204) {
                        err = NSError(
                            domain: JSONApi._errorMsgErrorResponse,
                            code: JSONApi.errorDestroyCode,
                            userInfo: nil)
                    }
                }
                else {
                    // Return a generic error.
                    err = NSError(
                        domain: JSONApi._errorMsgConnectionFailure,
                        code: JSONApi.errorDestroyCode,
                        userInfo: nil)
                }
                
                // Invoke the callback.
                callback(err)
        })
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}