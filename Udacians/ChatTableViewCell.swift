//
//  ChatTableViewCell.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/10/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var photoImageTask: URLSessionDataTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}
