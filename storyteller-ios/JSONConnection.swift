//******************************************************************************
//  JSONConnection.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation

/**
 * JSONConnection
 *
 * Manages JSON API requests / responses to a given URL.
 */

class JSONConnection {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    /// The session associated with the connection.
    private var _session: NSURLSession

    /// The configuration associated with the session.
    private var _configuration: NSURLSessionConfiguration
    
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
     * Initialize a new JSON connection.
     *
     * - parameter N/A
     *
     * - returns: Void
     */
    
    init () {
        
        // Start with the default session configuration and add headers that
        // denote that the session will send and receive JSON content only.
        //
        // Note that while many session tasks may share the same configuration,
        // the default configuration limits simultaneous connections to the host
        // to be 4 at a time.
        
        self._configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Create a new session with the newly, created configuration. Clients
        // of this JSON connection will share this session.
        //
        // Note that the session creates a serial NSOperationQueue object on
        // which all delegate method calls and completion handler calls are
        // performed.
        
        self._session = NSURLSession(configuration: self._configuration)
    }
    
    /**
     * HTTP GET
     *
     * - parameter url: The URL string to make the request to.
     * - parameter parameters: The query parameters to send with the request (optional).
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    func get (url: String, parameters: [String : String]?,
        callback: ((AnyObject?, NSHTTPURLResponse?, NSError?) -> Void)) {

        var query = ""
        if parameters != nil {
        
            // Create query parameters.
            query += "?"
            var index = 0
            let count = parameters!.count
            for (key, value) in parameters! {
                query += "\(key)=\(value)"
                
                index++
                if (index < count) {
                    query += "&"
                }
            }
        }
        
        // Create the GET request.
        let escapedUrl =
        (url + query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrl)!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Invoke the common data task function.
        self._dataTaskWithRequest(request, callback: callback)
    }
    
    /**
     * HTTP POST
     *
     * - parameter url: The URL string to make the request to.
     * - parameter parameters: The parameters to send with the request.
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    func post (url: String, parameters: [String : AnyObject],
        callback: ((AnyObject?, NSHTTPURLResponse?, NSError?) -> Void)) {
            
        // Invoke the common data preparation function.
        let data = self._dataWithJSONObject(parameters)
        
        // Create the POST request.
        let escapedUrl = url
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrl)!)
        request.HTTPMethod = "POST"
        request.HTTPBody   = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Invoke the common data task function.
        self._dataTaskWithRequest(request, callback: callback)
    }
    
    /**
     * HTTP PUT
     *
     * - parameter url: The URL string to make the request to.
     * - parameter parameters: The parameters to send with the request.
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    func put (url: String, parameters: [String : AnyObject],
        callback: ((AnyObject?, NSHTTPURLResponse?, NSError?) -> Void)) {
            
        // Invoke the common data preparation function.
        let data = self._dataWithJSONObject(parameters)
        
        // Create the PUT request.
        let escapedUrl = url
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrl)!)
        request.HTTPMethod = "PUT"
        request.HTTPBody   = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Invoke the common data task function.
        self._dataTaskWithRequest(request, callback: callback)
    }
    
    /**
     * HTTP DELETE
     *
     * - parameter url: The URL string to make the request to.
     * - parameter callback: Callback invoked once the request completes.
     *
     * - returns: Void
     */
    
    func delete (url: String,
        callback: ((AnyObject?, NSHTTPURLResponse?, NSError?) -> Void)) {
            
        // Create the GET request.
        let escapedUrl = url
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrl)!)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Invoke the common data task function.
        self._dataTaskWithRequest(request, callback: callback)
    }
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
    
    /**
     * Convert the given JSON parameters into request data.
     *
     * - paramater parameters: The parameters to convert.
     *
     * - returns: The data representation of the given JSON parameters.
     */
    
    private func _dataWithJSONObject(
        parameters: [String : AnyObject]) -> NSData? {
        
        // Prepare the request parameters.
        var data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(
                parameters,
                options: NSJSONWritingOptions.init(rawValue: 0))
        } catch {
            data = nil
        }
        
        return data
    }
    
    /**
     * Create a data task for the given request. The given callback is invoked
     * once the request is complete.
     *
     * - parameter request: The request to create a data task for.
     * - parameter callback: Callback invoked once the data task completes.
     *
     * - returns: Void
     */
    
    private func _dataTaskWithRequest(request: NSURLRequest,
        callback: ((AnyObject?, NSHTTPURLResponse?, NSError?) -> Void)) {
            
            // Session tasks start in the suspended state. Resume (i.e. start) the
            // task. Note that JSON requests are short and thus a data task is
            // used (data tasks are not supported in background sessions).
            
            let task = self._session.dataTaskWithRequest(
                request,
                completionHandler: { (data, response, error) -> Void in
                    
                    var err: NSError?
                    var json: AnyObject?
                    var httpResponse: NSHTTPURLResponse?
                    
                    if (error == nil) {
                        // Convert the response data into JSON.
                        do {
                            json = try NSJSONSerialization.JSONObjectWithData(
                                data!,
                                options: NSJSONReadingOptions.init(rawValue: 0))
                        } catch {
                        }
                        
                        // Typecast the response into an HTTP response.
                        httpResponse = (response as! NSHTTPURLResponse)
                    }
                    else {
                        // Propagate the error.
                        json = nil
                        httpResponse = nil
                        err = error
                    }
                    
                    // Invoke the callback.
                    callback(json, httpResponse, err)
            })
            task.resume()
    }
}