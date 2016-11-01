//
//  Profile.swift
//  Udacians
//
//  Created by Owen LaRosa on 11/1/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Profile {
    
    var profilePicture = ""
    var about = ""
    var website = ""
    var blog = ""
    var linkedIn = ""
    var twitter = ""
    var enrollments = [String]()
    
    init(snapshot: FIRDataSnapshot) {
        let root = snapshot.value as! [String: Any]
        
        let profile = root["profile"] as! [String: Any]
        profilePicture = profile["profilePicture"] as? String ?? ""
        about = profile["about"] as? String ?? ""
        website = profile["website"] as? String ?? ""
        blog = profile["blog"] as? String ?? ""
        linkedIn = profile["linkedIn"] as? String ?? ""
        twitter = profile["twitter"] as? String ?? ""
        enrollments = profile["enrollments"] as? [String] ?? [String]()
    }
    
    
}
