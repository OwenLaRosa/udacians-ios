//
//  MultipleInputViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/14/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class MultipleInputViewController: UIViewController {
    
    private struct InfoKeys {
        static let NAME = "name"
        static let TITLE = "title"
        static let URL = "url"
        static let PLACE = "place"
        static let ABOUT = "about"
        static let LONGITUDE = "longitude"
        static let LATITUDE = "latitude"
        static let TIMESTAMP = "timestamp"
    }
    
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
    var currentKey = ""
    var contents = [String: Any]()
    
    let userId = "3050228546"
    
    var ref: FIRDatabaseReference!
    
    public enum ContentType: Int {
        case topic = 0, article, event
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissAction = {
            self.dismiss(animated: true, completion: nil)
        }
        submitAction = {
            self.contents[self.currentKey] = self.inputTextField.text!
            switch self.contentType.rawValue {
            case 0:
                self.addNewTopic()
                break
            case 1:
                break
            case 2:
                break
            default:
                self.dismiss(animated: true, completion: nil)
                break
            }
        }
        nextAction = {
            self.contents[self.currentKey] = self.inputTextField.text!
            self.currentPage += 1
            self.configureUI()
        }
        backAction = {
            self.contents[self.currentKey] = self.inputTextField.text!
            self.currentPage -= 1
            self.configureUI()
        }
        
        ref = FIRDatabase.database().reference()
        
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
            currentKey = InfoKeys.NAME
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
                currentKey = InfoKeys.TITLE
                instructionLabel.text = "What is the title of the article?"
                inputTextField.placeholder = "E.g. How to Code Like Jon Skeet"
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                negativeAction = dismissAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else { // page 2
                currentKey = InfoKeys.URL
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
                currentKey = InfoKeys.NAME
                instructionLabel.text = "What is the name of the event?"
                inputTextField.placeholder = "iOS Developers meetup"
                negativeButton.title = MultipleInputViewController.BUTTON_CANCEL
                negativeAction = dismissAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else if currentPage == 2 {
                currentKey = InfoKeys.PLACE
                instructionLabel.text = "Where is this event?"
                inputTextField.placeholder = "E.g. Microsoft NERD Center. Cambridge, MA"
                negativeButton.title = MultipleInputViewController.BUTTON_BACK
                negativeAction = backAction
                positiveButton.title = MultipleInputViewController.BUTTON_NEXT
                positiveAction = nextAction
            } else { // page 3
                currentKey = InfoKeys.ABOUT
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
        inputTextField.text = contents[currentKey] as? String ?? ""
    }
    
    func addNewTopic() {
        // add info for identifying the location and querying
        contents[InfoKeys.LONGITUDE] = coordinate.longitude
        contents[InfoKeys.LATITUDE] = coordinate.latitude
        contents[InfoKeys.TIMESTAMP] = FIRServerValue.timestamp()
        
        let name = contents[InfoKeys.NAME] as! String
        contents.removeValue(forKey: InfoKeys.NAME)
        
        let topicLocationRef = ref.child("topic_locations").child(userId)
        topicLocationRef.removeValue()
        topicLocationRef.setValue(contents)
        
        let topicRef = ref.child("topics").child(userId)
        let topicNameRef = topicRef.child("info").child("name")
        topicNameRef.setValue(name)
        
        // clear messages from old topic
        let messagesRef = topicRef.child("messages")
        messagesRef.removeValue()
        
        // make this topic visible on the user's profile
        let userTopicRef = ref.child("users").child(userId).child("topics").child(userId)
        userTopicRef.setValue(true)
    }
    
}
