//
//  SocialViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

public struct DirectDiscussion {
    // id of the other user in the discussion
    let user: String
    // last time the other user sent a message
    var timestamp: Int
}

class SocialViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var chatsTableViewProvider: ChatsTableViewProvider!
    var followingTableViewProvider: ConnectionsTableViewProvider!
    var followersTableViewProvider: ConnectionsTableViewProvider!
    var directMessagesTableViewProvider: ConnectionsTableViewProvider!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        chatsTableViewProvider = ChatsTableViewProvider(owner: self)
        followingTableViewProvider = ConnectionsTableViewProvider(owner: self)
        followersTableViewProvider = ConnectionsTableViewProvider(owner: self)
        directMessagesTableViewProvider = ConnectionsTableViewProvider(owner: self)
        directMessagesTableViewProvider.directMessages = true
        
        ref = FIRDatabase.database().reference()
        
        let userRef = ref.child("users").child(getUid())
        let enrollmentsRef = userRef.child("enrollments")
        enrollmentsRef.observe(.childAdded, with: {(snapshot) in
            self.chatsTableViewProvider.enrollments.append(snapshot.key)
            // only force a reload if this segment has been selected
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.tableView.reloadData()
            }
        })
        let topicsRef = userRef.child("topics")
        topicsRef.observe(.childAdded, with: {(snapshot) in
            self.chatsTableViewProvider.topicIds.append(snapshot.key)
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.tableView.reloadData()
            }
        })
        topicsRef.observe(.childRemoved, with: {(snapshot) in
            for i in 0..<self.chatsTableViewProvider.topicIds.count {
                if self.chatsTableViewProvider.topicIds[i] == snapshot.key {
                    self.chatsTableViewProvider.topicIds.remove(at: i)
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        self.tableView.reloadData()
                    }
                    break
                }
            }
        })
        let followingRef = userRef.child("connections")
        followingRef.observe(.value, with: {(snapshot) in
            self.followingTableViewProvider.connections.removeAll()
            for i in snapshot.children.allObjects as! [FIRDataSnapshot]  {
                self.followingTableViewProvider.connections.append(i.key)
            }
            if self.segmentedControl.selectedSegmentIndex == 1 {
                self.tableView.reloadData()
            }
        })
        let followersRef = userRef.child("followers")
        followersRef.observe(.value, with: {(snapshot) in
            self.followersTableViewProvider.connections.removeAll()
            for i in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.followersTableViewProvider.connections.append(i.key)
            }
            if self.segmentedControl.selectedSegmentIndex == 2 {
                self.tableView.reloadData()
            }
        })
        let directDiscussionsRef = userRef.child("direct_messages")
        directDiscussionsRef.observe(.childAdded, with: {(snapshot) in
            let userId = snapshot.key
            let timestamp = snapshot.value as! Int
            self.directMessagesTableViewProvider.directDiscussions.append(DirectDiscussion(user: userId, timestamp: timestamp))
            self.directMessagesTableViewProvider.directDiscussions.sort(by: {$0.0.timestamp > $0.1.timestamp})
            self.tableView.reloadData()
        })
        directDiscussionsRef.observe(.childRemoved, with: {(snapshot) in
            let userId = snapshot.key
            for i in 0..<self.directMessagesTableViewProvider.directDiscussions.count {
                if userId == self.directMessagesTableViewProvider.directDiscussions[i].user {
                    self.directMessagesTableViewProvider.directDiscussions.remove(at: i)
                    break
                }
            }
            self.tableView.reloadData()
        })
        directDiscussionsRef.observe(.childChanged, with: {(snapshot) in
            let userId = snapshot.key
            let timestamp = snapshot.value as! Int
            for i in 0..<self.directMessagesTableViewProvider.directDiscussions.count {
                if userId == self.directMessagesTableViewProvider.directDiscussions[i].user {
                    self.directMessagesTableViewProvider.directDiscussions.remove(at: i)
                    self.directMessagesTableViewProvider.directDiscussions.insert(DirectDiscussion(user: userId, timestamp: timestamp), at: 0)
                    break
                }
            }
            self.tableView.reloadData()
        })
        
        tableView.dataSource = chatsTableViewProvider
        tableView.delegate = chatsTableViewProvider
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // chats
            tableView.dataSource = chatsTableViewProvider
            tableView.delegate = chatsTableViewProvider
            break
        case 1: // connections
            tableView.dataSource = followingTableViewProvider
            tableView.delegate = followingTableViewProvider
            break
        case 2: // followers
            tableView.dataSource = followersTableViewProvider
            tableView.delegate = followersTableViewProvider
            break
        case 3: // direct messages
            tableView.dataSource = directMessagesTableViewProvider
            tableView.delegate = directMessagesTableViewProvider
            break
        default:
            return
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

class ChatsTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var owner: UIViewController
    var ref: FIRDatabaseReference!
    
    var topicIds = [String]()
    var enrollments = [String]()
    
    init(owner: UIViewController) {
        self.owner = owner
        ref = FIRDatabase.database().reference()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrollments.count + topicIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as! ChatTableViewCell
        
        // determine if this chat is for an enrollment or topic
        var chat: String
        if indexPath.row <= enrollments.count - 1 {
            // enrollments come first, so use the normal index
            
            chat = enrollments[indexPath.row]
            let isBeta = chat.hasSuffix("beta")
            if isBeta {
                chat = chat.replacingOccurrences(of: "beta", with: "")
            }
            let enrollmentReference = ref.child("nano_degrees").child(chat)
            enrollmentReference.observe(.value, with: {(snapshot) in
                guard let result = snapshot.value as? [String: Any] else {
                    cell.nameLabel.text = chat
                    cell.descriptionLabel.text = "Course Discussion"
                    cell.photoImageView.image = UIImage(named: "Udacians_logo")
                    return
                }
                let name = result["name"] as? String
                cell.nameLabel.text = name ?? snapshot.key
                if name != nil {
                    cell.descriptionLabel.text = "General discussion for students in the \(name!)" + (isBeta ? " Beta" : "")
                } else {
                    cell.descriptionLabel.text = "Course discussion"
                }
                if let imageUrl = result["image"] as? String {
                    if let storedImage = WebImageCache.shared.image(with: chat) {
                        cell.photoImageView.image = storedImage
                    } else {
                        DispatchQueue.global(qos: .userInteractive).async {
                            cell.photoImageTask = WebImageCache.shared.downloadImage(at: imageUrl) {imageData in
                                DispatchQueue.main.async {
                                    WebImageCache.shared.storeImage(image: imageData, withIdentifier: chat)
                                    cell.photoImageView.image = imageData
                                }
                            }
                        }
                    }
                } else {
                    cell.photoImageView.image = UIImage(named: "Udacians_logo")
                }
            })
        } else {
            // chats come after enrollments so we need to offset the index by number of enrollments
            chat = topicIds[indexPath.row - enrollments.count]
            let topicNameReference = ref.child("topics").child(chat).child("info").child("name")
            topicNameReference.observe(.value, with: {(snapshot) in
                cell.nameLabel.text = snapshot.value as? String ?? ""
            })
            let userBasicReference = ref.child("users").child(chat).child("basic")
            let posterNameReference = userBasicReference.child("name")
            posterNameReference.observe(.value, with: {(snapshot) in
                cell.descriptionLabel.text = snapshot.value as? String ?? ""
            })
            let posterImageReference = userBasicReference.child("photo")
            posterImageReference.observe(.value, with: {(snapshot) in
                if let imageUrl = snapshot.value as? String {
                    if let storedImage = WebImageCache.shared.image(with: chat) {
                        cell.photoImageView.image = storedImage
                    } else {
                        DispatchQueue.global(qos: .userInteractive).async {
                            cell.photoImageTask = WebImageCache.shared.downloadImage(at: imageUrl) {imageData in
                                DispatchQueue.main.async {
                                    WebImageCache.shared.storeImage(image: imageData, withIdentifier: chat)
                                    cell.photoImageView.image = imageData
                                }
                            }
                        }
                    }
                } else {
                    cell.photoImageView.image = UIImage(named: "Udacians_logo")
                }
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:
        IndexPath) {
        let chatVC = owner.storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        if indexPath.row <= enrollments.count - 1 {
            chatVC.chatId = enrollments[indexPath.row]
        } else {
            chatVC.chatId = topicIds[indexPath.row - enrollments.count]
        }
        owner.show(chatVC, sender: nil)
    }
    
}

class ConnectionsTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var owner: UIViewController!
    var ref: FIRDatabaseReference!
    
    var connections = [String]()
    var directDiscussions = [DirectDiscussion]()
    
    // whether or not this data source shows list of direct messages
    var directMessages = false
    
    init(owner: UIViewController) {
        self.owner = owner
        ref = FIRDatabase.database().reference()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if directMessages {
            return directDiscussions.count
        }
        return connections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionTableViewCell") as! ConnectionTableViewCell
        
        var connection = ""
        if directMessages {
            connection = directDiscussions[indexPath.row].user
            cell.messageButton.isHidden = true
        } else {
            cell.messageButton.isHidden = false
            connection = connections[indexPath.row]
            cell.calloutAction = {
                let chatVC = self.owner.storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                chatVC.isDirect = true
                chatVC.chatId = connection
                self.owner.show(chatVC, sender: nil)
            }
        }
        
        cell.connection = connection
        let userBasicRef = ref.child("users").child(connection).child("basic")
        let nameRef = userBasicRef.child("name")
        nameRef.observe(.value, with: {(snapshot) in
            cell.nameLabel.text = snapshot.value as? String ?? ""
        })
        let titleRef = userBasicRef.child("title")
        titleRef.observe(.value, with: {(snapshot) in
            cell.titleLabel.text = snapshot.value as? String ?? "I'm a Udacian!"
        })
        let photoRef = userBasicRef.child("photo")
        photoRef.observe(.value, with: {(snapshot) in
            if let imageUrl = snapshot.value as? String {
                if let storedImage = WebImageCache.shared.image(with: connection) {
                    cell.photoImageView.image = storedImage
                } else {
                    DispatchQueue.global(qos: .userInteractive).async {
                        cell.photoImageTask = WebImageCache.shared.downloadImage(at: imageUrl) {imageData in
                            DispatchQueue.main.async {
                                WebImageCache.shared.storeImage(image: imageData, withIdentifier: connection)
                                cell.photoImageView.image = imageData
                            }
                        }
                    }
                }
            } else {
                cell.photoImageView.image = UIImage(named: "Udacians_logo")
            }
        })
        let locationRef = ref.child("locations").child(connection).child("location")
        locationRef.observe(.value, with: {(snapshot) in
            cell.locationLabel.text = snapshot.value as? String ?? "Unknown Location"
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if directMessages {
            let connection = directDiscussions[indexPath.row].user
            let chatVC = self.owner.storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
            chatVC.chatId = connection
            chatVC.isDirect = true
            self.owner.show(chatVC, sender: nil)
        } else {
            let connection = connections[indexPath.row]
            let profileVC = self.owner.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            profileVC.thisUser = connection
            self.owner.show(profileVC, sender: nil)
        }
    }
    
}
