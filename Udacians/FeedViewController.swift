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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        // appending to the end of the array is more efficient, but this means more recent posts are at the end
        // getting the index like this ensures they're shown in reverse order
        let post = posts[posts.count - indexPath.row - 1]
        let nameRef = ref.child("users").child(post.sender).child("basic").child("name")
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            cell.nameLabel.text = snapshot.value as? String ?? ""
        })
        cell.contentLabel.text = post.content
        
        return cell
    }
    
}
