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
    // bottom space constraint of the parent view, used for keyboard movement
    @IBOutlet weak var viewBottomOffset: NSLayoutConstraint!
    
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
                self.addNewArticle()
                break
            case 2:
                self.addNewEvent()
                break
            default:
                break
            }
            self.dismiss(animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        inputTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
        inputTextField.resignFirstResponder()
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
        addCoordinatesAndTimestamp()
        
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
    
    func addNewArticle() {
        guard let url = Utils.validateUrl(url: inputTextField.text!) else { return }
        contents[InfoKeys.URL] = url
        addCoordinatesAndTimestamp()
        let articleRef = ref.child("articles").child(userId)
        articleRef.removeValue()
        articleRef.setValue(contents)
    }
    
    func addNewEvent() {
        var eventLocation = [String: Any]()
        eventLocation[InfoKeys.LONGITUDE] = coordinate.longitude
        eventLocation[InfoKeys.LATITUDE] = coordinate.latitude
        eventLocation[InfoKeys.TIMESTAMP] = FIRServerValue.timestamp()
        
        let eventLocationRef = ref.child("event_locations").child(userId)
        eventLocationRef.removeValue()
        eventLocationRef.setValue(eventLocation)
        
        let eventRef = ref.child("events").child(userId)
        let eventInfoRef = eventRef.child("info")
        eventInfoRef.setValue(contents)
        
        let eventPostsRef = eventRef.child("posts")
        eventPostsRef.removeValue()
        
        let eventMembersRef = eventRef.child("members")
        eventMembersRef.observe(.childAdded, with: {(snapshot) in
            let memberId = snapshot.key
            if memberId == self.userId {
                return
            }
            let memberEventReference = self.ref.child("users").child(memberId).child("events").child(self.userId)
            memberEventReference.removeValue()
            eventMembersRef.child(memberId).removeValue()
        })
        
        let thisUserEventReference = ref.child("users").child(userId).child("events").child(userId)
        thisUserEventReference.setValue(true)
        eventMembersRef.child(userId).setValue(true)
    }
    
    func addCoordinatesAndTimestamp() {
        contents[InfoKeys.LONGITUDE] = coordinate.longitude
        contents[InfoKeys.LATITUDE] = coordinate.latitude
        contents[InfoKeys.TIMESTAMP] = FIRServerValue.timestamp()
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        viewBottomOffset.constant = -getKeyboardOffset(notification: notification)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        viewBottomOffset.constant = 0
    }
    
    private func getKeyboardOffset(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
}
