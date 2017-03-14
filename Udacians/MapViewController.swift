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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        ref = FIRDatabase.database().reference()
        userLocationsRef = ref.child("locations")
        eventLocationsRef = ref.child("event_locations")
        topicLocationsRef = ref.child("topic_locations")
        articlesRef = ref.child("articles")
    }
    
        
}
