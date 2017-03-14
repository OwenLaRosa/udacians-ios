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
                if let location = UserLocation(data: data) {
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
                if let location = UserLocation(data: data) {
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
    }
    
    private enum PinType: Int {
        case person = 0, event, topic, article
    }
    
    private class UdaciansMarker: GMSMarker {
        /// type of content marker is associated with
        var pinType: PinType!
        /// content associated with the marker (e.g. user, topic, event, article ID)
        var key: String!
    }
    
    private class UserLocation {
        let latitude: Double
        let longitude: Double
        let location: String
        let timeStamp: Int
        
        init?(data: [String: Any]) {
            guard let latitude = data["latitude"] as? Double, latitude >= -90 && latitude <= 90 else { return nil }
            guard let longitude = data["longitude"] as? Double, longitude >= -180 && longitude <= 180 else { return nil }
            guard let location = data["location"] as? String  else { return nil }
            guard let timestamp = data["timestamp"] as? Int else { return nil }
            self.latitude = latitude
            self.longitude = longitude
            self.location = location
            self.timeStamp = timestamp
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let udaciansMarker = marker as? UdaciansMarker else { return false }
        switch udaciansMarker.pinType.rawValue {
        case 0: // person
            let userNameRef = ref.child("users").child(udaciansMarker.key).child("basic").child("name")
            userNameRef.observeSingleEvent(of: .value, with: {(snapshot) in
                udaciansMarker.title = snapshot.value as? String ?? ""
            })
            let userTitleRef = ref.child("users").child(udaciansMarker.key).child("basic").child("title")
            userTitleRef.observeSingleEvent(of: .value, with: {(snapshot) in
                udaciansMarker.snippet = snapshot.value as? String ?? "Udacian"
            })
            mapView.selectedMarker = udaciansMarker
            break
        case 1: // event
            break
        case 2: // topic
            break
        case 3: // article
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
            break
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
    
}
