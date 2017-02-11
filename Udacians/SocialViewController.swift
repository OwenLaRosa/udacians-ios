//
//  SocialViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class SocialViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    let userId = "3050228546"
    
    let chatsTableViewDataSource = ChatsTableViewDataSource()
    let connectionsTableViewDataSource = ConnectionsTableViewDataSource()
    let followersTableViewDataSource = FollowersTableViewDataSource()
    let directMessagesTableViewDataSource = DirectMessagesTableViewDataSource()
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let userRef = ref.child("users").child(userId)
        let enrollmentsRef = userRef.child("enrollments")
        enrollmentsRef.observe(.childAdded, with: {(snapshot) in
            self.chatsTableViewDataSource.enrollments.append(snapshot.key)
            // only force a reload if this segment has been selected
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.tableView.reloadData()
            }
        })
        let topicsRef = userRef.child("topics")
        topicsRef.observe(.childAdded, with: {(snapshot) in
            self.chatsTableViewDataSource.topicIds.append(snapshot.key)
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.tableView.reloadData()
            }
        })
        topicsRef.observe(.childRemoved, with: {(snapshot) in
            for i in 0..<self.chatsTableViewDataSource.topicIds.count {
                if self.chatsTableViewDataSource.topicIds[i] == snapshot.key {
                    self.chatsTableViewDataSource.topicIds.remove(at: i)
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        self.tableView.reloadData()
                    }
                    break
                }
            }
        })
        
        tableView.dataSource = chatsTableViewDataSource
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // chats
            tableView.dataSource = chatsTableViewDataSource
            break
        case 1: // connections
            tableView.dataSource = connectionsTableViewDataSource
            break
        case 2: // followers
            tableView.dataSource = followersTableViewDataSource
            break
        case 3: // direct messages
            tableView.dataSource = directMessagesTableViewDataSource
            break
        default:
            return
        }
        tableView.reloadData()
    }
    
}

class ChatsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var topicIds = [String]()
    var enrollments = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrollments.count + topicIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as! ChatTableViewCell
        
        return cell
    }
    
}

class ConnectionsTableViewDataSource: NSObject, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

class FollowersTableViewDataSource: NSObject, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

class DirectMessagesTableViewDataSource: NSObject, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
