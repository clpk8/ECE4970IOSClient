//
//  MapViewController.swift
//  MapInterface
//
//  Created by linChunbin on 3/10/19.
//  Copyright © 2019 clpk8. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseCore

class MapViewController: UIViewController {

    
    var lat = 38.4440561
    var lon = -90.21374739404762
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let regionInMeters: Double = 10.1
    let annotation = MKPointAnnotation()
    var carCoordinate = CLLocationCoordinate2D(latitude: 38.4440561, longitude: -90.21374739404762)
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        carCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.title = "Car"
        annotation.coordinate = carCoordinate
        mapView.addAnnotation(annotation)
        let ref = Database.database().reference()
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
        
        let databaseHandle = ref.child("gps").observe(.childChanged, with: { (snapshot) in
            guard let values = snapshot.value as? [String: Any] else {
                return
            }
            if let lat = values["lat"] as? Double{
                self.lat = lat
            }
            if let lon = values["lon"] as? Double{
                self.lon = lon
            }
            
            self.carCoordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
            self.annotation.coordinate = self.carCoordinate
            print("Updated location")
        })
        
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
//    func centerViewOnUserLocation() {
//        if let location = locationManager.location?.coordinate{
//            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//            mapView.setRegion(region, animated: true)
//        }
//    }
//
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
        }
    }

    func gerDirections(){
        guard let location = locationManager.location?.coordinate else {
            return
        }
        
        let request = createDirectionRequest(from: location)
        let directions = MKDirections(request: request)
        
        directions.calculate{[unowned self] (response, error) in
            guard let response = response else { return }
            
            for route in response.routes{
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request{
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: carCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            // happy path
            mapView.showsUserLocation = true
            //centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break;
        case .denied:
            // show alert instruction them how to turn  on permission
            break;
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break;
        case .restricted:
            //parental control
            //show an alert
            break;
        case .authorizedAlways:
            break;
        }
    }
    @IBAction func navigateButtonPress(_ sender: Any) {
                gerDirections()
    }
}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}
