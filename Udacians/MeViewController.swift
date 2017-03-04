//
//  MeViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewDataSource: PostFeedTableViewDataSource!
    
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
        
        tableViewDataSource = PostFeedTableViewDataSource(tableView: tableView, isThisUser: true)
        tableView.dataSource = tableViewDataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
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
        
        let postLinksRef = ref.child("users").child(userId).child("posts")
        postLinksRef.queryLimited(toLast: 10).observe(.childAdded, with: {(snapshot) in
            let postId = snapshot.key
            let postReference = self.ref.child("posts").child(postId)
            postReference.observe(.value, with: {(snapshot) in
                if let data = snapshot.value as? [String: Any] {
                    let post = Message(id: postId, data: data)
                    self.tableViewDataSource.posts.append(post)
                    self.tableView.reloadData()
                }
            })
        })
        
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        print("follow button tapped")
    }
    
    func updateTableHeaderHeight() {
        tableView.tableHeaderView?.frame.size.height = collectionView.frame.origin.y + collectionView.frame.size.height + 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileLinkCollectionViewCell", for: indexPath) as! ProfileLinkCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
