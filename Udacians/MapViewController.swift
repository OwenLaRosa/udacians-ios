//
//  MapViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 12/20/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

// data to be passed to the multiple input VC
// consists of the type of content (event, topic, article)
// and the map coordinates where the user long-pressed
typealias InputData = (type: MultipleInputViewController.ContentType, coordinate: CLLocationCoordinate2D)

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var ref: FIRDatabaseReference!
    var userLocationsRef: FIRDatabaseReference!
    var eventLocationsRef: FIRDatabaseReference!
    var topicLocationsRef: FIRDatabaseReference!
    var articlesRef: FIRDatabaseReference!
    
    var idToUserMarker = [String: GMSMarker]()
    var idToEventMarker = [String: GMSMarker]()
    var idToTopicMarker = [String: GMSMarker]()
    var idToArticleMarker = [String: GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // hybrid satelite and political map
        mapView.mapType = GMSMapViewType(4)
        
        ref = FIRDatabase.database().reference()
        userLocationsRef = ref.child("locations")
        eventLocationsRef = ref.child("event_locations")
        topicLocationsRef = ref.child("topic_locations")
        articlesRef = ref.child("articles")
        
        loadMapData()
    }
    
    func loadMapData() {
        userLocationsRef.queryLimited(toLast: 100).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {(snapshot) in
            if let data = snapshot.value as? [String: Any] {
                if let location = UdaciansLocation(data: data) {
                    let marker = UdaciansMarker(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                    marker.pinType = .person
                    marker.key = snapshot.key
                    marker.icon = #imageLiteral(resourceName: "user_pin")
                    self.idToUserMarker[snapshot.key] = marker
                    marker.map = self.mapView
                }
            }
        })
        userLocationsRef.observe(.childRemoved, with: {(snapshot) in
            self.idToUserMarker[snapshot.key]?.map = nil
            self.idToUserMarker.removeValue(forKey: snapshot.key)
        })
        userLocationsRef.observe(.childChanged, with: {(snapshot) in
            if let data = snapshot.value as? [String: Any] {
                if let location = UdaciansLocation(data: data) {
                    let marker = UdaciansMarker(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                    marker.pinType = .person
                    marker.key = snapshot.key
                    marker.icon = #imageLiteral(resourceName: "user_pin")
                    self.idToUserMarker[snapshot.key]?.map = nil
                    self.idToUserMarker[snapshot.key] = marker
                    marker.map = self.mapView
                }
            }
        })
        eventLocationsRef.queryLimited(toLast: 20).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {(snapshot) in
            if let data = snapshot.value as? [String: Any] {
                if let location = UdaciansLocation(data: data) {
                    let marker = UdaciansMarker(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                    marker.pinType = .event
                    marker.key = snapshot.key
                    marker.icon = #imageLiteral(resourceName: "event_pin")
                    self.idToEventMarker[snapshot.key] = marker
                    marker.map = self.mapView
                }
            }
        })
        eventLocationsRef.observe(.childRemoved, with: {(snapshot) in
            self.idToEventMarker[snapshot.key]?.map = nil
            self.idToEventMarker.removeValue(forKey: snapshot.key)
        })
        topicLocationsRef.queryLimited(toLast: 20).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {(snapshot) in
            if let data = snapshot.value as? [String: Any] {
                if let location = UdaciansLocation(data: data) {
                    let marker = UdaciansMarker(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                    marker.pinType = .topic
                    marker.key = snapshot.key
                    marker.icon = #imageLiteral(resourceName: "topic_pin")
                    self.idToTopicMarker[snapshot.key] = marker
                    marker.map = self.mapView
                }
            }
        })
        topicLocationsRef.observe(.childRemoved, with: {(snapshot) in
            self.idToTopicMarker[snapshot.key]?.map = nil
            self.idToTopicMarker.removeValue(forKey: snapshot.key)
        })
        articlesRef.queryLimited(toLast: 20).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {(snapshot) in
            if let data = snapshot.value as? [String: Any] {
                if let location = UdaciansLocation(data: data) {
                    let marker = UdaciansMarker(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                    marker.pinType = .article
                    marker.key = location.url
                    marker.icon = #imageLiteral(resourceName: "article_pin")
                    marker.title = location.title
                    marker.snippet = location.url
                    self.idToArticleMarker[snapshot.key] = marker
                    marker.map = self.mapView
                }
            }
        })
        articlesRef.observe(.childRemoved, with: {(snapshot) in
            self.idToArticleMarker[snapshot.key]?.map = nil
            self.idToArticleMarker.removeValue(forKey: snapshot.key)
        })
    }
    
    private enum PinType: Int {
        case person = 0, event, topic, article
    }
    
    private class UdaciansMarker: GMSMarker {
        /// type of content marker is associated with
        var pinType: PinType!
        /// content associated with the marker (e.g. user, topic, event ID, or the article URL)
        var key: String!
        
        func loadInfoWindowData(titleRef: FIRDatabaseReference, snippetRef: FIRDatabaseReference, defaultTitle: String!, defaultSnippet: String!) {
            titleRef.observeSingleEvent(of: .value, with: {(snapshot) in
                self.title = snapshot.value as? String ?? defaultTitle
            })
            snippetRef.observeSingleEvent(of: .value, with: {(snapshot) in
                self.snippet = snapshot.value as? String ?? defaultSnippet
            })
        }
    }
    
    private class UdaciansLocation {
        let latitude: Double
        let longitude: Double
        let timeStamp: Int
        
        // for user locations
        let location: String!
        
        // for article locations
        let title: String!
        let url: String!
        
        init?(data: [String: Any]) {
            guard let latitude = data["latitude"] as? Double, latitude >= -90 && latitude <= 90 else { return nil }
            guard let longitude = data["longitude"] as? Double, longitude >= -180 && longitude <= 180 else { return nil }
            guard let timestamp = data["timestamp"] as? Int else { return nil }
            self.latitude = latitude
            self.longitude = longitude
            self.timeStamp = timestamp
            
            self.location = data["location"] as? String
            
            self.title = data["title"] as? String
            self.url = data["url"] as? String
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let udaciansMarker = marker as? UdaciansMarker else { return false }
        switch udaciansMarker.pinType.rawValue {
        case 0: // person
            let userNameRef = ref.child("users").child(udaciansMarker.key).child("basic").child("name")
            let userTitleRef = ref.child("users").child(udaciansMarker.key).child("basic").child("title")
            udaciansMarker.loadInfoWindowData(titleRef: userNameRef, snippetRef: userTitleRef, defaultTitle: nil, defaultSnippet: "Udacian")
            mapView.selectedMarker = udaciansMarker
            break
        case 1: // event
            let eventNameRef = ref.child("events").child(udaciansMarker.key).child("info").child("name")
            let eventPlaceRef = ref.child("events").child(udaciansMarker.key).child("info").child("place")
            udaciansMarker.loadInfoWindowData(titleRef: eventNameRef, snippetRef: eventPlaceRef, defaultTitle: nil, defaultSnippet: nil)
            mapView.selectedMarker = udaciansMarker
            break
        case 2: // topic
            let topicNameRef = ref.child("topics").child(udaciansMarker.key).child("info").child("name")
            let posterNameRef = ref.child("users").child(udaciansMarker.key).child("basic").child("name")
            udaciansMarker.loadInfoWindowData(titleRef: topicNameRef, snippetRef: posterNameRef, defaultTitle: "Unnamed Topic", defaultSnippet: "Unknown Poster")
            mapView.selectedMarker = udaciansMarker
            break
        case 3: // article
            // title and snippet are already set when the marker is created
            mapView.selectedMarker = udaciansMarker
            break
        default:
            return false
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let udaciansMarker = marker as? UdaciansMarker else { return }
        switch udaciansMarker.pinType.rawValue {
        case 0:
            let userVC = storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            userVC.thisUser = udaciansMarker.key
            show(userVC, sender: nil)
            break
        case 1:
            let eventVC = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
            eventVC.eventId = udaciansMarker.key
            show(eventVC, sender: nil)
            break
        case 2:
            let topicVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
            topicVC.chatId = udaciansMarker.key
            show(topicVC, sender: nil)
            break
        case 3:
            if let url = URL(string: udaciansMarker.key) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            break
        default:
            break
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let inputVC = storyboard?.instantiateViewController(withIdentifier: "MultipleInputViewController") as! MultipleInputViewController
        inputVC.coordinate = coordinate
        let addNewMenu = UIAlertController(title: "Add New", message: "What type of content would you like to add?\nThis will overwrite previously added content of the same type.", preferredStyle: .actionSheet)
        addNewMenu.addAction(UIAlertAction(title: "Topic", style: .default, handler: {(alert: UIAlertAction?) -> Void in
            self.performSegue(withIdentifier: "ShowInputView", sender: InputData(type: .topic, coordinate: coordinate))
        }))
        addNewMenu.addAction(UIAlertAction(title: "Article", style: .default, handler: {(alert: UIAlertAction?) -> Void in
            self.performSegue(withIdentifier: "ShowInputView", sender: InputData(type: .article, coordinate: coordinate))
        }))
        addNewMenu.addAction(UIAlertAction(title: "Event", style: .default, handler: {(alert: UIAlertAction?) -> Void in
            self.performSegue(withIdentifier: "ShowInputView", sender: InputData(type: .event, coordinate: coordinate))
        }))
        addNewMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(addNewMenu, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInputView" {
            let inputVC = segue.destination as! MultipleInputViewController
            let data = sender as! InputData
            inputVC.contentType = data.type
            inputVC.coordinate = data.coordinate
        }
    }
    
}
