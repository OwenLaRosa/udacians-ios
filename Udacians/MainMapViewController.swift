//
//  MainMapViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 11/21/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import UIKit
import GoogleMaps

class MainMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: UIView!
    
    override func loadView() {
        super.loadView()
        
        view = GMSMapView(frame: view.frame)
    }
    
}
