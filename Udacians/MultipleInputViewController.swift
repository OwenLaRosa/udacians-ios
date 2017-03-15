//
//  MultipleInputViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/14/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import CoreLocation

class MultipleInputViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!
    
    var contentType: ContentType!
    var coordinate: CLLocationCoordinate2D!
    
    public enum ContentType: Int {
        case topic = 0, article, event
    }

    @IBAction func negativeButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func positiveButtonTapped(_ sender: UIButton) {
        
    }
    
}
