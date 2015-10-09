//******************************************************************************
//  User.swift
//  GeoMsg
//
//  Copyright (c) 2015 wakaddo. All rights reserved.
//******************************************************************************

import Foundation

/**
 * User
 *
 * Manages user creation and maintenance with the user server.
 */

class User: JSONApi {
    
    //**************************************************************************
    // MARK: Attributes (Public)
    //**************************************************************************
    
    var firstName: String
    var lastName: String
    var email: String
    
    //**************************************************************************
    // MARK: Attributes (Internal)
    //**************************************************************************
    
    //**************************************************************************
    // MARK: Attributes (Private)
    //**************************************************************************
    
    // The URL of the user server.
    private static let _userUrl: String = config.domain + "api/users"
    
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
     * :param: firstName The user's first name.
     * :param: lastName The user's last name.
     * :param: email The user's email.
     *
     * :returns: N/A
     */
    
    init (firstName: String, lastName: String, email: String) {
            
        self.firstName = firstName
        self.lastName  = lastName
        self.email     = email

        super.init()
    }
    
    /**
     * Initialize a new user given a JSON hash.
     *
     * :param: json JSON hash from which to initialize the user.
     *
     * :returns: N/A
     */

    convenience init (json: [String:AnyObject]) {

        // Note this is a "convenience" initializer since it calls a different
        // "designated" initializer.
        //
        // http://www.codingricky.com/construtor-chaining-in-swift/

        self.init(firstName: json["first_name"] as! String,
            lastName: json["last_name"] as! String,
            email: json["email"] as! String)
    }

    /**
     * Retrieve the user's alias.
     *
     * :param: N/A
     *
     * :returns: The user's alias.
     */

    func alias() -> String {
        return self.firstName +
            " " +
            String(self.lastName[self.lastName.startIndex])
    }

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
    
    func signup(#password: String, callback: ((NSError?) -> Void)) {
        
        self.create(
            User._userUrl,
            parameters: ["user":["first_name":self.firstName,
                "last_name":self.lastName, "email":self.email, "password":password]],
            callback: { (error) -> Void in
    
                // Invoke the callback.
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