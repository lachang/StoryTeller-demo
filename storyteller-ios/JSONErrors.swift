//******************************************************************************
//  JSONErrors.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation

/**
 * JSONErrors
 *
 * Manages conversion of JSON API responses to readable errors.
 */

class JSONErrors {

    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************

    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************

    //**************************************************************************
    // MARK: Class Methods (Public)
    //**************************************************************************
    
    /**
     * Get the first error in the given JSON dictionary.
     *
     * - parameter json: JSON dictionary from which to extract the first error
     *
     * - returns: The first error message
     */
    
    class func firstError(json: NSDictionary) -> String {
        
        // First, get all the keys and values from the JSON response.
        let allKeys: [AnyObject]? = json.allKeys as [AnyObject]?
        let allValues: [AnyObject]? = json.allValues as [AnyObject]?
        
        // Next, extract the first key from "keys" and the first array of errors
        // from "values" (each value is actually an array of errors for its
        // corresponding key).
        
        var firstErrorKey: NSString = allKeys?[0] as! NSString
        let firstErrorArray: NSArray = allValues?[0] as! NSArray
        
        // Then retrieve the first error from the array of errors.
        var firstError: String = firstErrorArray[0] as! String
        
        if (firstErrorKey != "base") {
            
            // If the first error key is not "base", then the error is
            // interpreted to be a string that must be concatenated to its key
            // value to make sense.
            //
            // Do this concatentation now.
            
            // Remove any "_" from the first key.
            firstErrorKey =
                firstErrorKey.stringByReplacingOccurrencesOfString("_",
                    withString: " ")
            
            // Capitalize the first letter of the key.
            firstErrorKey = firstErrorKey.substringToIndex(1).uppercaseString +
                firstErrorKey.substringFromIndex(1)
            
            // Concatentate the key and error string.
            firstError = (firstErrorKey as String) + " " + firstError
        }
        
        return firstError
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
    
    //**************************************************************************
    // MARK: Instance Methods (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Instance Methods (Private)
    //**************************************************************************
}