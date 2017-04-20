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
        articlesProvider = ArticlesTableViewProvider(owner: self)
        eventsProvider = EventsTableViewProvider(owner: self)
        
        ref = FIRDatabase.database().reference()
        
        let articlesReference = ref.child("articles")
        articlesReference.queryOrdered(byChild: "timestamp").queryLimited(toLast: 20).observe(.childAdded, with: {(snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.articlesProvider.articles.append(Article(id: snapshot.key, data: data))
                self.tableView.reloadData()
            }
        })
        let myEventsReference = ref.child("users").child(getUid()).child("events")
        myEventsReference.observe(.childAdded, with: {(snapshot) in
            self.eventsProvider.myEvents.append(snapshot.key)
            self.tableView.reloadData()
        })
        myEventsReference.observe(.childRemoved, with: {(snapshot) in
            for i in 0..<self.eventsProvider.myEvents.count {
                if snapshot.key == self.eventsProvider.myEvents[i] {
                    self.eventsProvider.myEvents.remove(at: i)
                    self.tableView.reloadData()
                }
            }
        })
        let allEventsReference = ref.child("event_locations")
        allEventsReference.queryOrdered(byChild: "timestamp").queryLimited(toLast: 20).observe(.childAdded, with: {(snapshot) in
            self.eventsProvider.allEvents.append(snapshot.key)
            self.tableView.reloadData()
        })
        
        tableView.dataSource = articlesProvider
        tableView.delegate = articlesProvider
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

class ArticlesTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var articles = [Article]()
    
    var ref: FIRDatabaseReference
    var owner: UIViewController!
    
    init(owner: UIViewController) {
        self.owner = owner
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
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: article.id)
                        DispatchQueue.main.async {
                            cell.photoImageButton.image = imageData
                            cell.setNeedsLayout()
                        }
                    }
                }
            }
        })
        
        cell.photoButtonCallback = {
            let profileVC = self.owner.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            profileVC.thisUser = article.id
            self.owner.show(profileVC, sender: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        if let url = URL(string: article.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            owner.showAlert(title: "Cannot open URL", message: "URL is not in the correct format")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

class EventsTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var myEvents = [String]()
    var allEvents = [String]()
    
    var ref: FIRDatabaseReference
    var owner: UIViewController
    
    init(owner: UIViewController) {
        self.owner = owner
        ref = FIRDatabase.database().reference()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Events"
        } else {
            return "All Events"
        }
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
        let eventId = getEvent(at: indexPath)
        
        let eventInfoReference = ref.child("events").child(eventId).child("info")
        let nameReference = eventInfoReference.child("name")
        nameReference.observe(.value, with: {(snapshot) in
            cell.titleLabel.text = snapshot.value as? String ?? ""
        })
        let eventAboutReference = eventInfoReference.child("about")
        eventAboutReference.observe(.value, with: {(snapshot) in
            cell.secondTitleLabel.text = snapshot.value as? String ?? ""
        })
        let eventPlaceReference = eventInfoReference.child("place")
        eventPlaceReference.observe(.value, with: {(snapshot) in
            cell.thirdTitleLabel.text = snapshot.value as? String ?? ""
        })
        let photoReference = ref.child("users").child(eventId).child("basic").child("photo")
        photoReference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let url = snapshot.value as? String {
                if let storedImage = WebImageCache.shared.image(with: eventId) {
                    cell.photoImageButton.image = storedImage
                } else {
                    cell.photoImageTask = WebImageCache.shared.downloadImage(at: url) {imageData in
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: eventId)
                        DispatchQueue.main.async {
                            cell.photoImageButton.image = imageData
                            cell.setNeedsLayout()
                        }
                    }
                }
            }
        })
        
        cell.photoButtonCallback = {
            let profileVC = self.owner.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            profileVC.thisUser = eventId
            self.owner.show(profileVC, sender: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventId = getEvent(at: indexPath)
        let eventVC = owner.storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        eventVC.eventId = eventId
        owner.show(eventVC, sender: nil)
    }
    
    private func getEvent(at indexPath: IndexPath) -> String {
        if indexPath.section == 0 {
            return myEvents[indexPath.row]
        } else {
            return allEvents[indexPath.row]
        }
    }
    
}
