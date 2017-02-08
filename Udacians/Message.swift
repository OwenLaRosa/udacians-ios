//
//  Message.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/8/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    public var id: String!
    public var sender: String!
    public var content: String!
    public var imageUrl: String!
    public var date: NSDate!
    
    public init (id: String, data: [String: Any]) {
        self.id = id
        self.sender = data["sender"] as? String ?? ""
        self.content = data["content"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.date = data["date"] as? NSDate
    }
    
}
