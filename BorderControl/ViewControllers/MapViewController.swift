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

    @IBOutlet weak var toggleTrackingButton: UIButton!
    @IBOutlet weak var drawBoundaryButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    private let currentLocation = CLLocation()
    private let regionRadius: Double = 1000
    private var drawMode = false
    private var trackerMode = false
    private let size: MKMapSize = MKMapSize(width: 5, height: 5)
    private var polygon: MKPolygon = MKPolygon()
    weak var timer: Timer?
    
    let alert = UIAlertController(title: "You are outside the designated zone", message: "It's recommended you return back.", preferredStyle: .alert)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawBoundaryButton.setTitle("Draw!", for: .normal)
        drawBoundaryButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        drawBoundaryButton.setTitleColor(UIColor.white, for: .normal)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        checkLocationServices()
        mapView.mapType = .satelliteFlyover
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

    }
    
    @IBAction func toggleTracker(_ sender: Any) {
        trackerMode = !trackerMode
        if(trackerMode) {
            toggleTrackingButton.setTitle("Tracking", for: .normal)
            startTimer()
        } else {
            toggleTrackingButton.setTitle("Not Tracking", for: .normal)
            stopTimer()
        }
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        mapView.isScrollEnabled = false
        drawBoundaryButton.setTitle("Drawing", for: .normal)
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
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
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
            polygon = MKPolygon(coordinates: &points, count: points.count)
            mapView.addOverlay(polygon) //Add polygon areas
            points = [] //Reset points
            mapView.isScrollEnabled = true
            drawMode = false
            drawBoundaryButton.setTitle("Draw!", for: .normal)
        }
    }
    
    @objc func checkStatusWithinPolygon() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let mapPoint: MKMapPoint = MKMapPoint(coordinate)
        let rect: MKMapRect = MKMapRect(origin: mapPoint, size: size)
        if(polygon.intersects(rect)) {
            print("we are inside")
        } else {
            self.present(alert, animated: true)
            trackerMode = !trackerMode
            toggleTrackingButton.setTitle("Not Tracking", for: .normal)
            stopTimer()
            print("we are outside")
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(checkStatusWithinPolygon), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .red
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        } else if (overlay is MKPolygon) {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = UIColor.green.withAlphaComponent(0.2)
            //polygonView
            return polygonView
        }
        return MKPolylineRenderer(overlay: overlay)
    }
}
