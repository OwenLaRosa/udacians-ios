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
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
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
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                    self.idToUserMarker[snapshot.key]?.map = nil
                    self.idToUserMarker[snapshot.key] = marker
                    marker.map = self.mapView
                }
            }
        })
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
    
}
