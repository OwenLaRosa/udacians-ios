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
    var negativeAction = {}
    var positiveAction = {}
    var dismissAction = {}
    var submitAction = {}
    var nextAction = {}
    var backAction = {}
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissAction = {
            self.dismiss(animated: true, completion: nil)
        }
        submitAction = {
            
        }
        nextAction = {
            self.currentPage += 1
            self.configureUI()
        }
        backAction = {
            self.currentPage -= 1
            self.configureUI()
        }
        
        configureUI()
    }

    @IBAction func negativeButtonTapped(_ sender: UIButton) {
        negativeAction()
    }
    
    @IBAction func positiveButtonTapped(_ sender: UIButton) {
        positiveAction()
    }
    
    func configureUI() {
        switch contentType.rawValue {
        case 0: // topic
            titleLabel.text = "Add New Topic"
            // topics only have one page
            negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
            negativeAction = dismissAction
            positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
            positiveAction = submitAction
            break
        case 1: // article
            titleLabel.text = "Add New Article"
            if currentPage == 1 {
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                negativeAction = dismissAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else { // page 2
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                negativeAction = backAction
                positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
                positiveAction = submitAction
            }
            break
        case 2: // event
            titleLabel.text = "Add New Event"
            if currentPage == 1 {
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                negativeAction = dismissAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else if currentPage == 2 {
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                negativeAction = backAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else { // page 3
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                negativeAction = backAction
                positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
                positiveAction = submitAction
            }
            break
        default:
            break
        }
    }
    
}
