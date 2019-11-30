//
//  ViewController.swift
//  BorderControl
//
//  Created by Ruchit Palrecha on 11/30/19.
//  Copyright © 2019 ScholarSquad. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationServices()
    }
    
    func checkLocationServices() {
      if (CLLocationManager.locationServicesEnabled()) {
        checkLocationAuthorization()
      } else {
        // Show alert letting the user know they have to turn this on.
      }
    }
    
    func checkLocationAuthorization() {
        print("Got to checking location");
        switch (CLLocationManager.authorizationStatus()) {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .authorizedAlways:
            mapView.showsUserLocation = true
            break
        case .denied: // Show alert telling users how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted: // Show an alert letting them know what’s up
            break
        }
    }


}

