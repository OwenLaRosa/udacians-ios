//
//  ConnectionTableViewCell.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/11/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class ConnectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    // code to be run when the message button is tapped
    var calloutAction = {}
    
    var connection = ""
    
    var photoImageTask: URLSessionDataTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    @IBAction func messgaeButtonTapped(_ sender: UIButton) {
        calloutAction()
    }
    
    
}
