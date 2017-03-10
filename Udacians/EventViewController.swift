//
//  EventViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/10/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAndPlaceLabel: UILabel!
    @IBOutlet weak var attendeeCountLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!
    
    var eventId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = eventId
    }
    
    @IBAction func interactButtonTapped(_ sender: UIButton) {
        
    }
    
    
}
