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
            instructionLabel.text = "What would you like to discuss with other students?"
            inputTextField.placeholder = "Discussion prompt"
            // topics only have one page
            negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
            negativeAction = dismissAction
            positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
            positiveAction = submitAction
            break
        case 1: // article
            titleLabel.text = "Add New Article"
            if currentPage == 1 {
                instructionLabel.text = "What is the title of the article?"
                inputTextField.placeholder = "E.g. How to Code Like Jon Skeet"
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                negativeAction = dismissAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else { // page 2
                instructionLabel.text = "What is the URL of the article?"
                inputTextField.placeholder = "http://google.com"
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                negativeAction = backAction
                positiveButton.title = MultipleInputViewController.BUTTON_SUBMIT
                positiveAction = submitAction
            }
            break
        case 2: // event
            titleLabel.text = "Add New Event"
            if currentPage == 1 {
                instructionLabel.text = "What is the name of the event?"
                inputTextField.placeholder = "iOS Developers meetup"
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                negativeAction = dismissAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else if currentPage == 2 {
                instructionLabel.text = "Where is this event?"
                inputTextField.placeholder = "E.g. Microsoft NERD Center. Cambridge, MA"
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                negativeAction = backAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else { // page 3
                instructionLabel.text = "Event Details"
                inputTextField.placeholder = "Competitive Hackathon, Saturday at 1:00 PM"
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
