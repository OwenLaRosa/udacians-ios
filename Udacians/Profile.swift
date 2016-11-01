//
//  Profile.swift
//  Udacians
//
//  Created by Owen LaRosa on 11/1/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import Foundation
import FirebaseDatabase

public class Profile {
    
    var profilePicture = ""
    var about = ""
    var website = ""
    var blog = ""
    var linkedIn = ""
    var twitter = ""
    var enrollments = [String]()
    
    init(enrollments: [String]) {
        self.enrollments = enrollments
    }
    
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
    
    func toAny() -> Any {
        var data: [String: Any] = [
            "profilePicture": profilePicture,
            "about": about,
            "webstie": website,
            "blog": blog,
            "linkedIn": linkedIn,
            "twitter": twitter
        ]
        for i in enrollments {
            data[i] = true
        }
        return data
    }
    
    
}
