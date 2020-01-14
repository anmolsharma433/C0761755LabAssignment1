//
//  ViewController.swift
//  C0761755LabAssignment1
//
//  Created by Anmol Sharma on 2020-01-14.
//  Copyright © 2020 anmol. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    //navigate Button
    @IBAction func navigate(_ sender: Any) {
        let currenLocation = mapView.userLocation
        let currentCoordinate = CLLocationCoordinate2D(latitude: currenLocation.coordinate.latitude, longitude: currenLocation.coordinate.longitude)
        let destination = mapView.annotations
        let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destination[0].coordinate.latitude, longitude: destination[0].coordinate.longitude)
        getDirections(user: currentCoordinate, destination: destinationlocationcoordinates)
    }
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView?.showsUserLocation = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Adding the Gesture for long Tap
        let lPress = UITapGestureRecognizer(target: self, action: #selector(longPress))
       //lPress.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(lPress)
        
        
    }
    
    @objc func longPress(gestureRecognizer : UITapGestureRecognizer)
    {
        if mapView.annotations.count != 0
        {
            let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
            mapView.removeAnnotations( annotationsToRemove )
        }
        let touchpoint = gestureRecognizer.location(in: mapView)
        let newcoordinate = mapView.convert(touchpoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = "Your Location"
        
        annotation.coordinate = newcoordinate
        mapView.addAnnotation(annotation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    // grabbing the user location
    let userLocation: CLLocation = locations[0]
    
    let lat = userLocation.coordinate.latitude
    let long = userLocation.coordinate.longitude
    
    let latDelta: CLLocationDegrees = 0.05
    let longDelta: CLLocationDegrees = 0.05
    
    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
    let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
    
    let region = MKCoordinateRegion(center: location, span: span)
    mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
         annotation.title = "You are here"
        annotation.coordinate = userLocation.coordinate
         mapView.addAnnotation(annotation)
    }
    
    func getDirections(user : CLLocationCoordinate2D,destination : CLLocationCoordinate2D)
    {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: user, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
        guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.delegate = self
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }

    }
    }

}

extension ViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay :MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}

