//
//  ViewController.swift
//  findmycar
//
//  Created by Sam Knepper on 2/28/17.
//  Copyright © 2017 Apress. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

var userLocation: CLLocation!
var region: MKCoordinateRegion!

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var parkButton: UIButton!
    @IBOutlet weak var findCarButton: UIButton!
    var locationManager: CLLocationManager!
    var day = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        parkButton.layer.borderWidth = 1
        parkButton.layer.borderColor = UIColor.black.cgColor
        findCarButton.layer.borderWidth = 1
        findCarButton.layer.borderColor = UIColor.black.cgColor
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        day = components.day!
        fetchLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
   
    @IBAction func showMap(_ sender: UIButton) {
        if shouldPerformSegueWithIdentifier(identifier: "MapSegue", sender: nil){
            performSegue(withIdentifier: "MapSegue", sender: sender)
        }
    }
    
    func shouldPerformSegueWithIdentifier(identifier: String!,sender: AnyObject!) -> Bool {
        var segueShouldOccur = true
        if identifier == "MapSegue" {
            // perform your computation to determine whether segue should occur
            if userLocation == nil {
                segueShouldOccur = false
            }
            if !segueShouldOccur {
                let notPermitted = UIAlertController(title: "Error", message: "You need to set a location first.", preferredStyle: .alert)
                notPermitted.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(notPermitted, animated: true, completion: nil)

                // prevent segue from occurring
                return false
            }
        }
        
        // by default perform the segue transition
        return true
    }

    
    @IBAction func pressedParkButton(_ sender: UIButton) {
        var alert = UIAlertController()
        if day % 2 == 0 {
            alert = UIAlertController(title: "Park on the Correct Side", message: "Today is an even day.", preferredStyle: .alert)
        }else{
            alert = UIAlertController(title: "Park on the Correct Side", message: "Today is an odd day.", preferredStyle: .alert)
        }
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            self.determineCurrentLocation()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let ref = FIRDatabase.database().reference(fromURL: "https://findmycar-5f1c0.firebaseio.com/")
        ref.child("car-location").child("long").setValue(userLocation.coordinate.longitude)
        ref.child("car-location").child("lat").setValue(userLocation.coordinate.latitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func fetchLocation(){
        let ref = FIRDatabase.database().reference(fromURL: "https://findmycar-5f1c0.firebaseio.com/")
        ref.child("car-location").observe(.value, with: { snapshot in
            let long = snapshot.childSnapshot(forPath: "long").value
            let lat = snapshot.childSnapshot(forPath: "lat").value
            userLocation = CLLocation(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

