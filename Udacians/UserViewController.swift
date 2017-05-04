//
//  UserViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewDataSource: PostFeedTableViewDataSource!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var aboutMeLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    enum ProfileLink { case personal, blog, linkedin, twitter }
    var profileLinks = [(type: ProfileLink, url: String)]()
    
    @IBOutlet weak var editProfileButton: UIBarButtonItem!
    
    @IBOutlet weak var writePostButton: UIBarButtonItem!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var thisUser: String!
    var isFollowing: Bool!
    var isFollowingRef: FIRDatabaseReference!
    var userFollowerRef: FIRDatabaseReference!
    var followerCountRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if the VC was launched from the "Me" tab thisUser should be nil and user can delete posts
        // in all other cases, the user is viewing profiles and should not be able to delete posts
        tableViewDataSource = PostFeedTableViewDataSource(owner: self, tableView: tableView, isThisUser: thisUser == nil)
        tableView.dataSource = tableViewDataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
        updateTableHeaderHeight()
        
        let isMeVC = thisUser == nil
        if isMeVC {
            // profile is displayed from the "Me" tab
            followButton.isHidden = true
            title = "My Profile"
            thisUser = getUid()
        } else {
            // logout button should not show on others' profiles
            tableView.tableFooterView = nil
            // user should not be able to follow themselves either on the "Me" tab or their profile prsented with navigation
            if thisUser == getUid() {
                followButton.isHidden = true
            } else {
                // user can follow/unfollow other users
                isFollowingRef = ref.child("users").child(getUid()).child("connections").child(thisUser)
                userFollowerRef = ref.child("users").child(thisUser).child("followers").child(getUid())
                isFollowingRef.observe(.value, with: {(snapshot) in
                    if snapshot.value is NSNull {
                        self.isFollowing = false
                        self.followButton.setTitle("Follow", for: .normal)
                    } else {
                        self.isFollowing = true
                        self.followButton.setTitle("Unfollow", for: .normal)
                    }
                })
            }
            // no need for edit profile button or writing posts for others' profiles
            editProfileButton = nil
            writePostButton = nil
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            
        }
        
        let userRef = ref.child("users").child(thisUser)
        let userBasicRef = userRef.child("basic")
        let nameRef = userBasicRef.child("name")
        nameRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let name = snapshot.value as? String ?? ""
            self.usernameLabel.text = name
            if !isMeVC {
                self.title = name
            }
            self.updateTableHeaderHeight()
        })
        let titleRef = userBasicRef.child("title")
        titleRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let title = snapshot.value as? String, title != "" {
                self.titleLabel.text = title
            } else {
                self.titleLabel.text = "Udacian"
            }
            self.updateTableHeaderHeight()
        })
        let photoRef = userBasicRef.child("photo")
        photoRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let url = snapshot.value as? String {
                if let storedImage = WebImageCache.shared.image(with: self.thisUser) {
                    self.profileImageView.image = storedImage
                    self.updateTableHeaderHeight()
                } else {
                    _ = WebImageCache.shared.downloadImage(at: url) {imageData in
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: self.thisUser)
                        DispatchQueue.main.async {
                            self.profileImageView.image = imageData
                            self.updateTableHeaderHeight()
                        }
                    }
                }
            }
        })
        let aboutRef = userBasicRef.child("about")
        aboutRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let about = snapshot.value as? String, about != "" {
                self.aboutMeLabel.text = about
            } else {
                self.aboutMeLabel.text = "I'm a Udacian!"
            }
            self.updateTableHeaderHeight()
        })
        followerCountRef = userRef.child("follower_count")
        followerCountRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let followers = snapshot.value as? Int ?? 0
            self.followersCountLabel.text = "\(followers) Follower\(followers != 1 ? "s": "")"
            self.updateTableHeaderHeight()
        })
        
        let profileLinksRef = ref.child("users").child(thisUser).child("profile")
        profileLinksRef.observeSingleEvent(of: .value, with: {(snapshot) in
            var hasLinks = false
            if let value = snapshot.value as? [String: AnyObject] {
                if let site = value["site"] as? String, site != "" {
                    hasLinks = true
                    self.profileLinks.append((type: .personal, url: site))
                }
                if let blog = value["blog"] as? String, blog != "" {
                    hasLinks = true
                    self.profileLinks.append((type: .blog, url: blog))
                }
                if let linkedin = value["linkedin"] as? String, linkedin != "" {
                    hasLinks = true
                    self.profileLinks.append((type: .linkedin, url: linkedin))
                }
                if let twitter = value["twitter"] as? String, twitter != "" {
                    hasLinks = true
                    self.profileLinks.append((type: .twitter, url: twitter))
                }
            }
            if !hasLinks {
                self.collectionViewHeight.constant = 0
                self.updateTableHeaderHeight()
            }
            self.collectionView.reloadData()
        })
        
        let postLinksRef = ref.child("users").child(thisUser).child("posts")
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
        if isFollowing! == true {
            isFollowingRef.removeValue()
            userFollowerRef.removeValue()
            followerCountRef.runTransactionBlock({(mutableData) in
                if mutableData.value is NSNull {
                    mutableData.value = 0
                } else {
                    mutableData.value = (mutableData.value! as! Int) - 1
                }
                if (mutableData.value as! Int) < 0 {
                    mutableData.value = 0
                }
                return FIRTransactionResult.success(withValue: mutableData)
            })
        } else {
            isFollowingRef.setValue(true)
            userFollowerRef.setValue(true)
            followerCountRef.runTransactionBlock({(mutableData) in
                if mutableData.value is NSNull {
                    mutableData.value = 1
                } else {
                    mutableData.value = (mutableData.value! as! Int) + 1
                }
                return FIRTransactionResult.success(withValue: mutableData)
            })
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        logoutButton.isEnabled = false
        _ = UdacityClient.shared.deleteSession(completion: { success in
            try? FIRAuth.auth()?.signOut()
            KeychainWrapper.standardKeychainAccess().removeObject(forKey: "email")
            KeychainWrapper.standardKeychainAccess().removeObject(forKey: "password")
            UdacityClient.shared.token = ""
            UdacityClient.shared.userId = ""
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func updateTableHeaderHeight() {
        if collectionViewHeight.constant == 0 {
            // we don't need the extra 8 points of padding if collection view is visible
            tableView.tableHeaderView?.frame.size.height = collectionView.frame.origin.y - 8
        } else {
            // bottom of the collection view with 8 points of padding
            tableView.tableHeaderView?.frame.size.height = collectionView.frame.origin.y + collectionViewHeight.constant + 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileLinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileLinkCollectionViewCell", for: indexPath) as! ProfileLinkCollectionViewCell
        let link = profileLinks[indexPath.row]
        switch link.type {
        case .personal:
            cell.imageView.image = UIImage(named: "site")
        case .blog:
            cell.imageView.image = UIImage(named: "blog")
        case .linkedin:
            cell.imageView.image = UIImage(named: "linkedin")
        case .twitter:
            cell.imageView.image = UIImage(named: "twitter")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let link = profileLinks[indexPath.row]
        if let url = URL(string: link.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
