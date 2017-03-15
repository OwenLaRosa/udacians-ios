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
    
    static let BUTTON_CANCEL = "Cancel"
    static let BUTTON_SUBMIT = "Submit"
    static let BUTTON_BACK = "Back"
    static let BUTTON_NEXT = "Next"
    
    var contentType: ContentType!
    var coordinate: CLLocationCoordinate2D!
    var currentPage = 1
    
    public enum ContentType: Int {
        case topic = 0, article, event
    }

    @IBAction func negativeButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func positiveButtonTapped(_ sender: UIButton) {
        switch contentType.rawValue {
        case 0:
            // topics only have one page
            negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
            positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
            break
        case 1:
            if currentPage == 1 {
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
            } else { // page 2
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
            }
            break
        case 2:
            if currentPage == 1 {
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
            } else if currentPage == 2 {
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
            } else { // page 3
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
            }
            break
        default:
            break
        }
    }
    
}
