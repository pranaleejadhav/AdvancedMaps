//
//  ViewController.swift
//  AdvancedMaps
//
//  Created by Pranalee Jadhav on 12/24/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var directions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        addAnnotation()
    }
    
    func addAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 35.202720, longitude: -80.829710)
        self.mapView.addAnnotation(annotation)
        
        
        let region = CLCircularRegion(center: annotation.coordinate, radius: 200, identifier: "UNCC")
        
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        self.mapView.addOverlay(MKCircle(center: annotation.coordinate, radius: 200)) //200 meters
        
        self.locationManager.startMonitoring(for: region)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purple
            circleRenderer.fillColor = UIColor.purple
            circleRenderer.alpha = 0.4
            return circleRenderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 5.0
            renderer.strokeColor = UIColor.purple
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
    }
    

    @IBAction func showAlert() {
        let alert = UIAlertController(title: "Go to Address", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
             textField.placeholder = "Enter Address"
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
            if let textField = alert.textFields?.first, let search = textField.text {
                
              
                    
                self.findNearByPOI(by :search)
                    
             
                
                // reverse geocode the address
                /*self.reverseGeocode(address :textField.text!) { placemark in
                  // placemark is clplacemark
                    //to open apple maps, mkplacemark is needed
                    let destinationPlacemark = MKPlacemark(coordinate: (placemark.location?.coordinate)!)
                    
                     let startingMapItem = MKMapItem.forCurrentLocation()
                    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                    
                    //MKMapItem.openMaps(with: [destinationMapItem], launchOptions: nil)
                    let directionsRequest = MKDirections.Request()
                    directionsRequest.transportType = .automobile
                    directionsRequest.source = startingMapItem
                    directionsRequest.destination = destinationMapItem
                    
                    let directions = MKDirections(request: directionsRequest)
                    directions.calculate(completionHandler: { (response, error) in
                        
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        guard let response = response,
                            let route = response.routes.first else {
                                return
                        }
                        
                        if !route.steps.isEmpty {
                            
                            for step in route.steps {
                                print(step.instructions)
                                self.directions.append(step.instructions)
                            }
                        }
                        
                        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                        
                    })
                }*/
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation =  view.annotation {
            let cordinate = annotation.coordinate
            let destinationPlacemark = MKPlacemark(coordinate: cordinate)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            MKMapItem.openMaps(with: [destinationMapItem], launchOptions: nil)
        }
    }
    
    private func findNearByPOI(by searchStr: String) {
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
        
        let request  = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchStr
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start{ (response, error) in
            
            guard let response = response, error == nil else {
                return
            }
            for mapItem in response.mapItems {
                self.addPlacemarkToMap(placemark: mapItem.placemark)
            }
            
        }
        
    }
    
   
    func reverseGeocode(address: String, completion :@escaping (CLPlacemark) -> ()) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks, let placemark = placemarks.first else {
                return
            }
            
           
            //above code is async
            completion(placemark)
            
            //self.addPlacemarkToMap(placemark: placemark)
        }
    }
    
    
    private func addPlacemarkToMap(placemark :CLPlacemark) {
        let coordinate = placemark.location?.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        annotation.title = placemark.name
        mapView.addAnnotation(annotation)
        print("found")

    }
    
    // Zooming
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        print("inside")
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        mapView.setRegion(region, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let nc = segue.destination as? UINavigationController,
            let directionsTVC = nc.viewControllers.first as? DirectionsTableViewController
            else {
                return
        }
        
        directionsTVC.directions = self.directions
        
    }
    
    

}

