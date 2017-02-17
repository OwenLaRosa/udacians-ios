//
//  CommunityViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class CommunityViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var articlesProvider: ArticlesTableViewProvider!
    var eventsProvider: EventsTableViewProvider!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articlesProvider = ArticlesTableViewProvider()
        eventsProvider = EventsTableViewProvider()
        
        ref = FIRDatabase.database().reference()
        
        let articlesReference = ref.child("articles")
        articlesReference.queryOrdered(byChild: "timestamp").queryLimited(toLast: 20).observe(.childAdded, with: {(snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.articlesProvider.articles.append(Article(id: snapshot.key, data: data))
                self.tableView.reloadData()
            }
        })
        
        tableView.reloadData()
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // articles
            tableView.dataSource = articlesProvider
            tableView.delegate = articlesProvider
        case 1: // events
            tableView.dataSource = eventsProvider
            tableView.delegate = eventsProvider
        default:
            break
        }
        tableView.reloadData()
    }
    
}

class ArticlesTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var articles = [Article]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreeTitleTableViewCell") as! ThreeTitleTableViewCell
        
        return cell
    }
    
}

class EventsTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var myEvents = [String]()
    var allEvents = [String]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return myEvents.count
        } else if section == 1 {
            return allEvents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreeTitleTableViewCell") as! ThreeTitleTableViewCell
        
        return cell
    }
    
}
