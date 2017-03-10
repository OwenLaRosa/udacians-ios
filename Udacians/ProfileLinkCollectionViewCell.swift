//
//  ProfileLinkCollectionViewCell.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/3/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class ProfileLinkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // used for profile pictures of event attendees
    // not used for profile links as these images are stored locally
    var profileImageTask: URLSessionDataTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}
