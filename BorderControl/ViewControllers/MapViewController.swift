//
//  MapViewController.swift
//  BorderControl
//
//  Created by Ruchit Palrecha on 11/30/19.
//  Copyright © 2019 ScholarSquad. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var points = [CLLocationCoordinate2D]() {
        didSet {
            print(points)
        }
    }

    @IBOutlet weak var drawBoundaryButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    private let currentLocation = CLLocation()
    private let regionRadius: Double = 1000
    private var drawMode = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawBoundaryButton.setTitle("Draw!", for: .normal)
        drawBoundaryButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        checkLocationServices()
        mapView.mapType = .satelliteFlyover
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        mapView.isScrollEnabled = false
        drawMode = true
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func checkLocationServices() {
      if CLLocationManager.locationServicesEnabled() {
        checkLocationAuthorization()
      } else {
        // Show alert letting the user know they have to turn this on.
      }
    }
    
    func checkLocationAuthorization() {
      switch CLLocationManager.authorizationStatus() {
      case .authorizedWhenInUse:
        mapView.showsUserLocation = true
       case .denied: // Show alert telling users how to turn on permissions
       break
      case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
      case .restricted: // Show an alert letting them know what’s up
       break
      case .authorizedAlways:
       break
      }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           centerMapOnUserLocation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
        if(drawMode) {
            mapView.removeOverlays(mapView.overlays) //Reset shapes
            if let touch = touches.first {
                let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
                points.append(coordinate)
            }
        }
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if(drawMode) {
            if let touch = touches.first {
                let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
                points.append(coordinate)
                let polyline = MKPolyline(coordinates: points, count: points.count)
                mapView.addOverlay(polyline) //Add lines
                
            }
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            if(drawMode) {
            let polygon = MKPolygon(coordinates: &points, count: points.count)
            mapView.addOverlay(polygon) //Add polygon areas
            points = [] //Reset points
            mapView.isScrollEnabled = true
                drawMode = false
            }
        }
    }

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .orange
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        } else if (overlay is MKPolygon) {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = .magenta
            return polygonView
        }
        return MKPolylineRenderer(overlay: overlay)
    }
}
