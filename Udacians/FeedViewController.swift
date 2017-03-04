//
//  FeedViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController {
    
    @IBOutlet var feedTableView: UITableView!
    
    private var viewAppeared = false
    
    private var posts = [Message]()
    
    private var userId = "3050228546"
    
    var ref: FIRDatabaseReference!
    var dataSource: PostFeedTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = PostFeedTableViewDataSource(tableView: feedTableView)
        feedTableView.dataSource = dataSource
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // only add the listener once to prevent duplicate entries
        if (!viewAppeared) {
            viewAppeared = true
            let connectionsRef = ref.child("users").child(userId).child("connections")
            connectionsRef.observe(.value, with: { (snapshot) in
                // user IDs of users we're following
                var connections = [String]()
                for i in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    connections.append(i.key)
                }
                self.getConnectionPostLinks(connections: connections)
            })
        }
    }
    
    private func getConnectionPostLinks(connections: [String]) {
        for i in connections {
            let userPostLinksRef = ref.child("users").child(i).child("posts")
            userPostLinksRef.observe(.childAdded, with: { (snapshot) in
                let postRef = self.ref.child("posts").child(snapshot.key)
                postRef.observe(.value, with: { (snapshot) in
                    let post = Message(id: snapshot.key, data: snapshot.value as! [String: AnyObject])
                    self.dataSource.posts.append(post)
                    self.dataSource.posts.sort(by: {$0.0.id > $0.1.id})
                    self.feedTableView.reloadData()
                })
            })
        }
    }
    
}
