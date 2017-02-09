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
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
        let postsRef = ref.child("posts")
        postsRef.queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let post = Message(id: id, data: snapshot.value as! [String: Any])
            self.posts.append(post)
            self.feedTableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        feedTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        // appending to the end of the array is more efficient, but this means more recent posts are at the end
        // getting the index like this ensures they're shown in reverse order
        let post = posts[posts.count - indexPath.row - 1]
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
            }
        })
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            cell.nameLabel.text = snapshot.value as? String ?? ""
        })
        cell.contentLabel.text = post.content
        if post.imageUrl == nil {
            cell.contentImageView.isHidden = true
        } else {
            if let storedImage = WebImageCache.shared.image(with: post.id) {
                cell.profileImageView.image = storedImage
                cell.contentImageView.isHidden = false
            } else {
                cell.contentImageTask = WebImageCache.shared.downloadImage(at: post.imageUrl) {imageData in
                    DispatchQueue.main.async {
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: post.id)
                        cell.contentImageView.image = imageData
                        cell.contentImageView.isHidden = false
                    }
                }
            }
        }
        
        return cell
    }
    
}
