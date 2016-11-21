//
//  User.swift
//  Udacians
//
//  Created by Owen LaRosa on 11/1/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import Foundation
import FirebaseDatabase

public class User {
    
    let userId: String
    let name: String
    var longitude: Double?
    var latitude: Double?
    
    // detailed profile info
    var profile: Profile?
    
    init(userId: String, firstName: String, lastName: String) {
        self.userId = userId
        self.name = "\(firstName) \(lastName)"
    }
    
    init(snapshot: FIRDataSnapshot) {
        let root = snapshot.value as! [String: Any]
        
        userId = snapshot.key
        
        let basic = root["basic"] as! [String: Any]
        name = basic["name"] as? String ?? ""
        longitude = basic["longitude"] as? Double
        latitude = basic["latitude"] as? Double
    }
    
    func toAny() -> Any? {
        var data: [String: Any] = ["name": name]
        if longitude != nil && latitude != nil {
            // only upload lon and lat if user has provided location
            data["longitude"] = longitude!
            data["latitude"] = latitude!
        }
        return data
    }
    
}
