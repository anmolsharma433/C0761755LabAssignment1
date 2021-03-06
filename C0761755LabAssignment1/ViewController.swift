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
    
    var currentCoordinate = CLLocationCoordinate2D()
    var destinationlocationcoordinates = CLLocationCoordinate2D()
    var destinations = CLLocationCoordinate2D()
    var travelType: String = "car"
    @IBOutlet weak var zoom: UIStepper!
    @IBAction func zoomFunc(_ sender: UIStepper) {
        if sender.value < 0
               {
                   var region: MKCoordinateRegion = mapView.region
                   region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
                   region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
                   mapView.setRegion(region, animated: true)
                   zoom.value = 0
               }
               else
               {
                   var region: MKCoordinateRegion = mapView.region
                   region.span.latitudeDelta /= 2.0
                   region.span.longitudeDelta /= 2.0
                   mapView.setRegion(region, animated: true)
                   zoom.value = 0
               }
        
    }
    
    
    @IBOutlet weak var modeOfTransport: UISegmentedControl!
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
       
            mapView.removeOverlays(mapView.overlays)
        
        
        switch  sender.selectedSegmentIndex {
        case 0:
            travelType = "car"
        case 1:
            travelType = "walk"
        default:
            break
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    //navigate Button
    @IBAction func navigate(_ sender: Any) {
        let currenLocation = mapView.userLocation
        currentCoordinate = CLLocationCoordinate2D(latitude: currenLocation.coordinate.latitude, longitude: currenLocation.coordinate.longitude)
        let destination = mapView.annotations
        destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destination[0].coordinate.latitude, longitude: destination[0].coordinate.longitude)
        
        if travelType == "car"{
            getDirections(user: currentCoordinate, destination: destinationlocationcoordinates, transportType: .automobile)
        }
        else{
            getDirections(user: currentCoordinate, destination: destinationlocationcoordinates, transportType: .walking)
        }
        
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
        zoom.value = 0
        zoom.minimumValue = -5
        zoom.maximumValue = 5
        
        //Adding the Gesture for long Tap
        let lPress = UITapGestureRecognizer(target: self, action: #selector(longPress))
        //lPress.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(lPress)
        
        
    }
    
    @objc func longPress(gestureRecognizer : UITapGestureRecognizer)
    {
        let count = mapView.overlays.count
        if count != 0
        {
            mapView.removeOverlays(mapView.overlays)
        }
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
        destinations = CLLocationCoordinate2D(latitude: newcoordinate.latitude, longitude: newcoordinate.longitude)
        mapView.addAnnotation(annotation)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // grabbing the user location
        let userLocation: CLLocation = locations[0]
        
        let lat = userLocation.coordinate.latitude
        let long = userLocation.coordinate.longitude
        
        let latDelta: CLLocationDegrees = 0.07
        let longDelta: CLLocationDegrees = 0.07
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.title = "You are here"
        annotation.coordinate = userLocation.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func getDirections(user : CLLocationCoordinate2D,destination : CLLocationCoordinate2D,transportType : MKDirectionsTransportType)
    {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: user, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinations, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = transportType
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            let rr = unwrappedResponse.routes[0]
            
          self.mapView.addOverlay(rr.polyline)
          self.mapView.delegate = self
          self.mapView.setVisibleMapRect(rr.polyline.boundingMapRect, animated: true)
            
        }
    }
    
}

extension ViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay :MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        if travelType == "car"{
        renderer.strokeColor = UIColor.cyan
        renderer.lineWidth = 4
        }
        else{
            renderer.lineDashPattern = [0, 10]
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 4
        }
        return renderer
    }
    
    
    
    
}

