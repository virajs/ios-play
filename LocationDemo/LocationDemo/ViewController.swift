//
//  ViewController.swift
//  LocationDemo
//
//  Created by Papa, John L on 8/18/16.
//  Copyright © 2016 Papa, John L. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
  
  @IBOutlet var mapView: MKMapView!
  var geocoder: CLGeocoder? = nil
  var locationManager: CLLocationManager? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    self.locationManager = CLLocationManager()
    self.locationManager?.delegate = self
    self.checkAuthorization()
  }
  
  @IBAction func epcotPressed(sender: UIButton) {
    findAndMapEpcot()
  }
  
  @IBAction func locationButton(sender: UIButton) {
    findLocation()
  }
  
  func findLocation() {
    NSLog("Authorized")
    self.locationManager?.startUpdatingLocation()
    //self.locationManager?.startMonitoringSignificantLocationChanges()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    NSLog("Finding locations ...")
    //    NSLog("\(locations)")
    for loc in locations {
      NSLog(loc.description)
    }
    manager.stopUpdatingLocation()
    if let lastLocation = locations.last {
      self.geoCode(lastLocation) // last is usually best
      let region = MKCoordinateRegionMakeWithDistance(lastLocation.coordinate, 5000.0, 5000.0)
      self.mapView.setRegion(region, animated: true)
      self.mapView.mapType = MKMapType.Standard
    }
  }
  
  func findAndMapEpcot() {
    
    let epcotLocation = CLLocation(latitude: 28.37, longitude: -81.55)
    let region = MKCoordinateRegionMakeWithDistance(epcotLocation.coordinate, 5000.0, 5000.0)
    self.mapView.mapType = MKMapType.Satellite
    self.mapView.setRegion(region, animated: true)

    let annotation = MKPointAnnotation()
    annotation.title = "Epcot"
    annotation.coordinate = epcotLocation.coordinate
    self.mapView.addAnnotation(annotation)
}
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    NSLog("Failed: \(error.localizedDescription)")
  }
  
  func checkAuthorization() {
    guard CLLocationManager.locationServicesEnabled() else { return }
    let authStatus = CLLocationManager.authorizationStatus()
    NSLog("authStatus \(authStatus)")
    
    switch authStatus {
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      NSLog("auth status is auth always or when in use")
      self.findLocation()
      
    case .Denied, .Restricted:
      NSLog("auth status is denied or restricted")
      return
      
    case .NotDetermined:
      NSLog("auth status is not determined")
      self.locationManager?.requestWhenInUseAuthorization()
    }
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    NSLog("auth status changed to \(status)")
    self.checkAuthorization()
  }
  
  func postalAddressFromAddressDictionary(addressdictionary: Dictionary<NSObject,AnyObject>) -> CNMutablePostalAddress {
    
    let address = CNMutablePostalAddress()
    
    address.street = addressdictionary["Street"] as? String ?? ""
    address.state = addressdictionary["State"] as? String ?? ""
    address.city = addressdictionary["City"] as? String ?? ""
    address.country = addressdictionary["Country"] as? String ?? ""
    address.postalCode = addressdictionary["ZIP"] as? String ?? ""
    
    return address
  }
  
  func geoCode(location: CLLocation) {
    let geocoder = CLGeocoder()
    self.geocoder = geocoder
    
    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
      if let placemarks = placemarks {
        print("*** Found \(placemarks.count) placemarks")
        print("\(placemarks)")
        let pm = placemarks[0]
        let postalFormatter = CNPostalAddressFormatter()
        let postalAddress = self.postalAddressFromAddressDictionary(pm.addressDictionary!)
        let address = postalFormatter.stringFromPostalAddress(postalAddress)
        print("address")
        print(address)
      }
      if let error = error {
        print("geocoding error, uh oh: \(error)")
      }
    })
  }
  
}

