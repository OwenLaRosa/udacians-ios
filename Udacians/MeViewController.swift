//
//  MeViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var aboutMeLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ref: FIRDatabaseReference!
    let userId = "3050228546"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        updateTableHeaderHeight()
        
        let userRef = ref.child("users").child(userId)
        let userBasicRef = userRef.child("basic")
        let nameRef = userBasicRef.child("name")
        nameRef.observeSingleEvent(of: .value, with: {(snapshot) in
            self.usernameLabel.text = snapshot.value as? String ?? ""
            self.updateTableHeaderHeight()
        })
        let titleRef = userBasicRef.child("title")
        titleRef.observeSingleEvent(of: .value, with: {(snapshot) in
            self.titleLabel.text = snapshot.value as? String ?? ""
            self.updateTableHeaderHeight()
        })
        let photoRef = userBasicRef.child("photo")
        photoRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let url = snapshot.value as? String {
                if let storedImage = WebImageCache.shared.image(with: self.userId) {
                    self.profileImageView.image = storedImage
                    self.updateTableHeaderHeight()
                } else {
                    _ = WebImageCache.shared.downloadImage(at: url) {imageData in
                        DispatchQueue.main.async {
                            WebImageCache.shared.storeImage(image: imageData, withIdentifier: self.userId)
                            self.profileImageView.image = imageData
                            self.updateTableHeaderHeight()
                        }
                    }
                }
            }
        })
        let aboutRef = userBasicRef.child("about")
        aboutRef.observeSingleEvent(of: .value, with: {(snapshot) in
            self.aboutMeLabel.text = snapshot.value as? String ?? ""
            self.updateTableHeaderHeight()
        })
        let followerCountRef = userRef.child("follower_count")
        followerCountRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let followers = snapshot.value as? Int ?? 0
            self.followersCountLabel.text = "\(followers) Follower\(followers != 1 ? "s": "")"
            self.updateTableHeaderHeight()
        })
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        print("follow button tapped")
    }
    
    func updateTableHeaderHeight() {
        tableView.tableHeaderView?.frame.size.height = collectionView.frame.origin.y + collectionView.frame.size.height + 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
}
