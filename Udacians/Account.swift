//
//  Account.swift
//  Udacians
//
//  Created by Owen LaRosa on 11/1/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import Foundation

public class Account {
    
    // email address used to sign in to Udacity
    let email: String
    // basic user data
    var user: User
    // user IDs that are part of the network
    var network = [String]()
    
    init(email: String, user: User) {
        self.email = email
        self.user = user
    }
    
    func toAny() -> Any {
        return [
            "email": email,
            "network": network
        ]
    }
    
}
