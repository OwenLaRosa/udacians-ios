//
//  MessageViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/13/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var textEntry: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var userId = "3050228546"
    
    var ref: FIRDatabaseReference!
    var messagesReference: FIRDatabaseReference!
    var senderDirectMessageReference: FIRDatabaseReference!
    var recipientDirectMessageReference: FIRDatabaseReference!
    
    var isDirect = false
    var chatId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
        var chatTitleReference: FIRDatabaseReference
        if isDirect {
            messagesReference = getDirectChatReference(user1: userId, user2: chatId)
            senderDirectMessageReference = ref.child("users").child(userId).child("direct_messages").child(chatId)
            recipientDirectMessageReference = ref.child("users").child(chatId).child("direct_messages").child(userId)
            chatTitleReference = ref.child("users").child(userId).child("basic").child("name")
        } else {
            messagesReference = ref.child("topics").child(chatId).child("messages")
            if chatId.hasPrefix("nd") && !chatId.hasSuffix("beta") {
                // course discussion for nanodegree
                chatTitleReference = ref.child("nano_degrees").child(chatId).child("name")
            } else if chatId.hasSuffix("beta") {
                // course discussion for beta nanodegree program
                chatTitleReference = ref.child("nano_degrees").child(chatId.replacingOccurrences(of: "beta", with: "")).child("name")
            } else {
                // user posted discussion topic
                chatTitleReference = ref.child("topics").child(chatId).child("info").child("name")
            }
            chatTitleReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let title = snapshot.value as? String {
                    self.title = title
                } else {
                    self.title = "Course Discussion"
                }
            })
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
    }
    
    private func getDirectChatReference(user1: String, user2: String) -> FIRDatabaseReference {
        let chatReference: FIRDatabaseReference
        let directMessagesReference = ref.child("direct_messages")
        let user1Int = Int(user1)!
        let user2Int = Int(user2)!
        if user1Int < user2Int {
            chatReference = directMessagesReference.child(user1).child(user2)
        } else {
            chatReference = directMessagesReference.child(user2).child(user1)
        }
        return chatReference
     }
    
}

extension MessageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        cell.contentLabel.text = "lorem ipsum dolor sit amet"
        
        return cell
    }
    
}
