//
//  ThreeTitleTableViewCell.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/16/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class ThreeTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var thirdTitleLabel: UILabel!

    var photoImageTask: URLSessionDataTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}
