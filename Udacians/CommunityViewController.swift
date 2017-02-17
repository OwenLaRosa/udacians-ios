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
    
    var ref: FIRDatabaseReference
    
    override init() {
        ref = FIRDatabase.database().reference()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = articles[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreeTitleTableViewCell") as! ThreeTitleTableViewCell
        
        cell.titleLabel.text = article.title
        let userBasicReference = ref.child("users").child(article.id).child("basic")
        let nameReference = userBasicReference.child("name")
        nameReference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let posterName = snapshot.value as? String {
                cell.secondTitleLabel.text = "Shared by: \(posterName)"
            } else {
                cell.secondTitleLabel.text = "Unknown Poster"
            }
        })
        cell.thirdTitleLabel.text = article.url
        let photoReference = userBasicReference.child("photo")
        photoReference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let url = snapshot.value as? String {
                if let storedImage = WebImageCache.shared.image(with: article.id) {
                    cell.photoImageButton.image = storedImage
                } else {
                    cell.photoImageTask = WebImageCache.shared.downloadImage(at: url) {imageData in
                        DispatchQueue.main.async {
                            WebImageCache.shared.storeImage(image: imageData, withIdentifier: article.id)
                            cell.photoImageButton.image = imageData
                        }
                    }
                }
            }
        })
        
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
