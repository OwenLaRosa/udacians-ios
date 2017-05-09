//
//  ReportAbuseViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 5/8/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class ReportAbuseViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var reportTextBottomSpace: NSLayoutConstraint!
    
    final let defaultText = "Please explan what the user did."
    
    final let spamDescription = "User posts content that is meaningless, repetitive, or disrupts other users."
    final let harrassmentDescription = "User deliberately offends and targets other users."
    final let inappropriateDescription = "User posts content that is violent, profane, pornographic or otherwise violates the community guidelines."
    
    var defaultBottomSpace: CGFloat = 0.0
    
    var ref: FIRDatabaseReference!
    var abuseReportsRef: FIRDatabaseReference!
    var abusiveUserNameRef: FIRDatabaseReference!
    
    var abusiveUserId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportTextView.delegate = self
        reportTextView.becomeFirstResponder()
        
        descriptionLabel.text = spamDescription
        
        defaultBottomSpace = reportTextBottomSpace.constant
        
        ref = FIRDatabase.database().reference()
        abuseReportsRef = ref.child("reports")
        abusiveUserNameRef = ref.child("users").child(abusiveUserId).child("basic").child("name")
        abusiveUserNameRef.observe(.value, with: {(snapshot) in
            self.usernameLabel.text = snapshot.value as? String
        })
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        var contents = [String: String]()
        
        contents["reporter"] = getUid()
        contents["abuser"] = abusiveUserId
        var reportType = ""
        if typeSegment.selectedSegmentIndex == 0 {
            reportType = "spam"
        } else if typeSegment.selectedSegmentIndex == 1 {
            reportType = "harrassment"
        } else if typeSegment.selectedSegmentIndex == 2 {
            reportType = "inappropriate"
        }
        contents["type"] = reportType
        contents["description"] = reportTextView.text
        abuseReportsRef.childByAutoId().setValue(contents)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            descriptionLabel.text = spamDescription
        } else if sender.selectedSegmentIndex == 1 {
            descriptionLabel.text = harrassmentDescription
        } else if sender.selectedSegmentIndex == 2 {
            descriptionLabel.text = inappropriateDescription
        }
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
        reportTextBottomSpace.constant = defaultBottomSpace + getKeyboardOffset(notification: notification)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        reportTextBottomSpace.constant = defaultBottomSpace
    }
    
    private func getKeyboardOffset(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func onDismissKeyboardGesture(_ sender: UITapGestureRecognizer) {
        reportTextView.resignFirstResponder()
    }
    
    
}

extension ReportAbuseViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultText {
            textView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = defaultText
        }
    }
    
}
