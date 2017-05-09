//
//  FeedViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FeedViewController: UIViewController {
    
    @IBOutlet var feedTableView: UITableView!
    
    private var posts = [Message]()
    
    var ref: FIRDatabaseReference!
    var dataSource: PostFeedTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = PostFeedTableViewDataSource(owner: self, tableView: feedTableView)
        dataSource.isMainFeed = true
        feedTableView.dataSource = dataSource
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // only add the listener once to prevent duplicate entries
        let connectionsRef = ref.child("users").child(getUid()).child("connections")
        connectionsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // user IDs of users we're following
            var connections = [String]()
            for i in snapshot.children.allObjects as! [FIRDataSnapshot] {
                connections.append(i.key)
            }
            if connections.count == 0 {
                self.dataSource.posts.removeAll()
                self.feedTableView.reloadData()
            } else {
                self.getConnectionPostLinks(connections: connections)
            }
        })
    }
    
    private func getConnectionPostLinks(connections: [String]) {
        self.dataSource.posts.removeAll()
        for i in connections {
            let userPostLinksRef = ref.child("users").child(i).child("posts")
            userPostLinksRef.observe(.childAdded, with: { (snapshot) in
                let postRef = self.ref.child("posts").child(snapshot.key)
                postRef.observe(.value, with: { (snapshot) in
                    guard let contents = snapshot.value as? [String: AnyObject] else { return }
                    let post = Message(id: snapshot.key, data: contents)
                    self.dataSource.posts.append(post)
                    self.dataSource.posts.sort(by: {$0.0.id < $0.1.id})
                    self.feedTableView.reloadData()
                })
            })
        }
    }
    
}
