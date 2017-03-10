//
//  EventViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/10/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class EventViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAndPlaceLabel: UILabel!
    @IBOutlet weak var attendeeCountLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    @IBOutlet weak var attendeesCollectionView: UICollectionView!
    @IBOutlet weak var aboutLabel: UILabel!
    
    let userId = "3050228546"
    var eventId: String!
    var ref: FIRDatabaseReference!
    var eventRef: FIRDatabaseReference!
    
    var attendees = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        eventRef = ref.child("events").child(eventId)
        let infoRef = eventRef.child("info")
        infoRef.observe(.value, with: {(snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            self.nameLabel.text = value["name"] as? String ?? ""
            self.timeAndPlaceLabel.text = value["place"] as? String ?? ""
            self.aboutLabel.text = value["about"] as? String ?? ""
        })
        let attendeesRef = eventRef.child("members")
        attendeesRef.observe(.childAdded, with: {(snapshot) in
            let user = snapshot.key
            if self.userId == user {
                self.attendees.insert(user, at: 0)
            } else {
                self.attendees.append(user)
            }
            self.attendeesCollectionView.reloadData()
        })
        attendeesRef.observe(.childRemoved, with: {(snapshot) in
            let user = snapshot.key
            if let index = self.attendees.index(of: user) {
                self.attendees.remove(at: index)
            }
            self.attendeesCollectionView.reloadData()
        })
    }
    
    @IBAction func interactButtonTapped(_ sender: UIButton) {
        
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
                        DispatchQueue.main.async {
                            WebImageCache.shared.storeImage(image: imageData, withIdentifier: attendee)
                            cell.imageView.image = imageData
                        }
                    }
                } else {
                    cell.imageView.image = UIImage(named: "Udacity_logo")
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
    
    
}
