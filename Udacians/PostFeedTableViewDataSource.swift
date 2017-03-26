//
//  PostFeedTableViewDataSource.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/3/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class PostFeedTableViewDataSource: NSObject, UITableViewDataSource {
    
    var owner: UIViewController
    var posts = [Message]()
    var ref: FIRDatabaseReference
    var tableView: UITableView
    let isThisUser: Bool
    var eventId: String!
    // is this the list of all posts from users we're following, accessed from the "Feed" tab?
    var isMainFeed = false
    
    init(owner: UIViewController, tableView: UITableView, isThisUser: Bool = false, eventId: String? = nil) {
        self.owner = owner
        self.tableView = tableView
        self.isThisUser = isThisUser
        self.eventId = eventId
        ref = FIRDatabase.database().reference()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PostTableViewCell!
        
        // appending to the end of the array is more efficient, but this means more recent posts are at the end
        // getting the index like this ensures they're shown in reverse order
        let post = posts[posts.count - indexPath.row - 1]
        
        if post.imageUrl == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "PostWithImageTableViewCell") as! PostWithImageTableViewCell
        }
        
        if eventId != nil || isMainFeed {
            cell.profileImageButton.isUserInteractionEnabled = true
            cell.profileButtonCallback = {
                let userVC = self.owner.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
                userVC.thisUser = post.sender
                self.owner.show(userVC, sender: nil)
            }
        } else {
            cell.profileImageButton.isUserInteractionEnabled = false
        }
        
        let nameRef = ref.child("users").child(post.sender).child("basic").child("name")
        let profilePhotoRef = ref.child("users").child(post.sender).child("basic").child("photo")
        profilePhotoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = URL(string: snapshot.value as? String ?? "") {
                if let storedImage = WebImageCache.shared.image(with: post.sender) {
                    cell.profileImageButton.image = storedImage
                } else {
                    cell.profileImageTask = WebImageCache.shared.downloadImage(at: snapshot.value as! String) {imageData in
                        DispatchQueue.main.async {
                            WebImageCache.shared.storeImage(image: imageData, withIdentifier: post.sender)
                            cell.profileImageButton.image = imageData
                        }
                    }
                }
            } else {
                cell.profileImageButton.image = nil
            }
        })
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if self.indexPathIsVisible(tableView: self.tableView, indexPath: indexPath) {
                cell.nameLabel.text = snapshot.value as? String ?? ""
            }
        })
        cell.contentLabel.text = post.content
        
        if post.imageUrl != nil {
            (cell as! PostWithImageTableViewCell).contentImageView.image = nil
            if let storedImage = WebImageCache.shared.image(with: post.id) {
                DispatchQueue.main.async {
                    (cell as! PostWithImageTableViewCell).contentImageView.image = storedImage
                }
            } else {
                (cell as! PostWithImageTableViewCell).contentImageTask = WebImageCache.shared.downloadImage(at: post.imageUrl) {imageData in
                    DispatchQueue.main.async {
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: post.id)
                        (cell as! PostWithImageTableViewCell).contentImageView.image = imageData
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if eventId != nil {
            // users can delete their own posts
            return eventId == FIRAuth.auth()!.currentUser!.uid
        } else {
            return isThisUser
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = posts.count - indexPath.row - 1
            let post = posts[index]
            posts.remove(at: index)
            if eventId != nil {
                ref.child("events").child(eventId).child("posts").child(post.id).removeValue()
            } else {
                ref.child("posts").child(post.id).removeValue()
                ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("posts").child(post.id).removeValue()
            }
            tableView.reloadData()
        }
    }
    
    private func indexPathIsVisible(tableView: UITableView, indexPath: IndexPath) -> Bool {
        for i in tableView.indexPathsForVisibleRows! {
            if i.row == indexPath.row {
                return true
            }
        }
        return false
    }
    
    
}
