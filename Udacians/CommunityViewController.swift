//
//  CommunityViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/7/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var articlesProvider: ArticlesTableViewProvider!
    var eventsProvider: EventsTableViewProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articlesProvider = ArticlesTableViewProvider()
        eventsProvider = EventsTableViewProvider()
        
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
    
    var articles = [String]()
    
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
