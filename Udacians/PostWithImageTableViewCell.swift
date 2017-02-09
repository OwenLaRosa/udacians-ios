//
//  PostWithImageTableViewCell.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/9/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class PostWithImageTableViewCell: PostTableViewCell {
    
    @IBOutlet var contentImageView: UIImageView!
    
    var contentImageTask: URLSessionDataTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}
