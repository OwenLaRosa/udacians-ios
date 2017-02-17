//
//  Article.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/16/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import Foundation

class Article {
    
    public let id: String
    public let title: String
    public let url: String
    public let longitude: Double?
    public let latitude: Double?
    
    init(id: String, data: [String: Any]) {
        self.id = id
        title = data["title"] as? String ?? ""
        url = data["url"] as? String ?? ""
        longitude = data["longitude"] as? Double
        latitude = data["latitude"] as? Double
    }
    
}
