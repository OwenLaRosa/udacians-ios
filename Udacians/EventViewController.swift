//
//  EventViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/10/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MessageUI

class EventViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAndPlaceLabel: UILabel!
    @IBOutlet weak var attendeeCountLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    @IBOutlet weak var attendeesCollectionView: UICollectionView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var tableViewHeader: UIView!
    
    var eventId: String!
    var ref: FIRDatabaseReference!
    var eventRef: FIRDatabaseReference!
    var isMemberReference: FIRDatabaseReference!
    var dataSource: PostFeedTableViewDataSource!
    var isAttending = false
    
    var attendees = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = PostFeedTableViewDataSource(owner: self, tableView: tableView, eventId: eventId)
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
        eventRef = ref.child("events").child(eventId)
        let infoRef = eventRef.child("info")
        infoRef.observe(.value, with: {(snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            self.nameLabel.text = value["name"] as? String ?? ""
            self.timeAndPlaceLabel.text = value["place"] as? String ?? ""
            self.aboutLabel.text = value["about"] as? String ?? ""
            self.updateTableHeaderHeight()
        })
        let attendeesRef = eventRef.child("members")
        attendeesRef.observe(.childAdded, with: {(snapshot) in
            let user = snapshot.key
            if self.getUid() == user {
                self.attendees.insert(user, at: 0)
            } else {
                self.attendees.append(user)
            }
            self.attendeeCountLabel.text = "\(self.attendees.count) Member\(self.attendees.count != 1 ? "s": "")"
            self.attendeesCollectionView.reloadData()
        })
        attendeesRef.observe(.childRemoved, with: {(snapshot) in
            let user = snapshot.key
            if let index = self.attendees.index(of: user) {
                self.attendees.remove(at: index)
            }
            self.attendeeCountLabel.text = "\(self.attendees.count) Member\(self.attendees.count != 1 ? "s": "")"
            self.attendeesCollectionView.reloadData()
        })
        let postsRef = eventRef.child("posts")
        postsRef.observe(.childAdded, with: {(snapshot) in
            guard let data = snapshot.value as? [String: Any] else { return }
            self.dataSource.posts.append(Message(id: snapshot.key, data: data))
            self.tableView.reloadData()
        })
        postsRef.observe(.childRemoved, with: {(snapshot) in
            let key = snapshot.key
            for i in 0..<self.dataSource.posts.count {
                if self.dataSource.posts[i].id == key {
                    self.dataSource.posts.remove(at: i)
                    break
                }
            }
            self.tableView.reloadData()
        })
        if getUid() == eventId {
            // the user that posted the event can email all members
            interactButton.setTitle("Email", for: .normal)
            interactButton.isHidden = true
        } else {
            isMemberReference = eventRef.child("members").child(getUid())
            isMemberReference.observe(.value, with: {(snapshot) in
                if let flag = snapshot.value as? Bool, flag {
                    self.isAttending = true
                    self.interactButton.setTitle("Not Going", for: .normal)
                } else {
                    self.isAttending = false
                    self.interactButton.setTitle("Attend", for: .normal)
                }
            })
        }
    }
    
    @IBAction func interactButtonTapped(_ sender: UIButton) {
        if getUid() == eventId {
            var memberEmails = [String]()
            // number of emails we've downloaded so far
            var count = 0
            // total number of emails to be downloaded
            var totalEmails = attendees.count
            // it's possible a user may be removed while downloading email addresses
            // copying the arrays will ensure changes to "attendees" will not cause race conditions
            let users = attendees
            for i in users {
                ref.child("users").child(i).child("email").observeSingleEvent(of: .value, with: {(snapshot) in
                    count += 1
                    if let email = snapshot.value as? String {
                        memberEmails.append(email)
                    }
                    if count == totalEmails {
                        self.showMailVC(addresses: memberEmails)
                    }
                })
            }
        } else {
            if isAttending {
                isMemberReference.removeValue()
                ref.child("users").child(getUid()).child("events").child(eventId).removeValue()
            } else {
                isMemberReference.setValue(true)
                ref.child("users").child(getUid()).child("events").child(eventId).setValue(true)
            }
        }
    }
    
    func showMailVC(addresses: [String]) {
        if !MFMailComposeViewController.canSendMail() {
            // TODO: Show alert if mail service unavailable
            showAlert(title: "Mail Unavailable", message: "Mail service is unavailable on your device.")
            return
        }
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.delegate = self
        mailComposeVC.setToRecipients(addresses)
        show(mailComposeVC, sender: nil)
    }
    
    func updateTableHeaderHeight() {
        // variable height of the label with some additional margin at the bottom
        tableViewHeader.frame.size.height = aboutLabel.frame.origin.y + aboutLabel.intrinsicContentSize.height + 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attendees.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileLinkCollectionViewCell", for: indexPath) as! ProfileLinkCollectionViewCell
        
        let attendee = attendees[indexPath.row]
        let photoReference = ref.child("users").child(attendee).child("basic").child("photo")
        photoReference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let storedImage = WebImageCache.shared.image(with: attendee) {
                cell.imageView.image = storedImage
            } else {
                if let url = snapshot.value as? String {
                    cell.profileImageTask = WebImageCache.shared.downloadImage(at: url) {imageData in
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: attendee)
                        DispatchQueue.main.async {
                            cell.imageView.image = imageData
                            cell.setNeedsLayout()
                        }
                    }
                } else {
                    cell.imageView.image = UIImage(named: "Udacians_logo")
                }
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let attendee = attendees[indexPath.row]
        let userVC = storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        userVC.thisUser = attendee
        show(userVC, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WritePost" {
            // destination is a navigation controller, it's single direct child is a post authoring VC
            let destinationVC = segue.destination.childViewControllers[0] as! WritePostViewController
            destinationVC.isUserPosts = false
            destinationVC.eventId = eventId
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
