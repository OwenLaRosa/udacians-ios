//
//  FeedViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var feedTableView: UITableView!
    
    private var posts = [Message]()
    
    private var userId = "3050228546"
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
        
        let connectionsRef = ref.child("users").child(userId).child("connections")
        connectionsRef.observe(.value, with: { (snapshot) in
            // user IDs of users we're following
            var connections = [String]()
            for i in snapshot.children.allObjects as! [FIRDataSnapshot] {
                connections.append(i.key as! String)
            }
            self.getConnectionPostLinks(connections: connections)
        })
    }
    
    private func getConnectionPostLinks(connections: [String]) {
        for i in connections {
            let userPostLinksRef = ref.child("users").child(i).child("posts")
            userPostLinksRef.observe(.childAdded, with: { (snapshot) in
                let postRef = self.ref.child("posts").child(snapshot.key)
                postRef.observe(.value, with: { (snapshot) in
                    let post = Message(id: snapshot.key, data: snapshot.value as! [String: AnyObject])
                    self.posts.append(post)
                    self.posts.sort(by: {$0.0.id > $0.1.id})
                    self.feedTableView.reloadData()
                })
            })
        }
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
        
        let nameRef = ref.child("users").child(post.sender).child("basic").child("name")
        let profilePhotoRef = ref.child("users").child(post.sender).child("basic").child("photo")
        profilePhotoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = URL(string: snapshot.value as? String ?? "") {
                if let storedImage = WebImageCache.shared.image(with: post.sender) {
                    cell.profileImageView.image = storedImage
                } else {
                    cell.profileImageTask = WebImageCache.shared.downloadImage(at: snapshot.value as! String) {imageData in
                        DispatchQueue.main.async {
                            WebImageCache.shared.storeImage(image: imageData, withIdentifier: post.sender)
                            cell.profileImageView.image = imageData
                        }
                    }
                }
            } else {
                cell.profileImageView.image = nil
            }
        })
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if self.indexPathIsVisible(tableView: self.feedTableView, indexPath: indexPath) {
                cell.nameLabel.text = snapshot.value as? String ?? ""
            }
        })
        cell.contentLabel.text = post.content
        
        if post.imageUrl != nil {
            if let storedImage = WebImageCache.shared.image(with: post.id) {
                DispatchQueue.main.async {
                    (cell as! PostWithImageTableViewCell).profileImageView.image = storedImage
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
    
    private func indexPathIsVisible(tableView: UITableView, indexPath: IndexPath) -> Bool {
        for i in tableView.indexPathsForVisibleRows! {
            if i.row == indexPath.row {
                return true
            }
        }
        return false
    }
    
}
