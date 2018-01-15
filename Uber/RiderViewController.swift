//
//  RiderViewController.swift
//  Uber
//
//  Created by Muhammed Essa on 1/14/18.
//  Copyright © 2018 Muhammed Essa. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController , CLLocationManagerDelegate{

    @IBOutlet weak var logutBtn: UIBarButtonItem!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var callDriverBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var driverCalling = false
    var driverLocation = CLLocationCoordinate2D()
    var driverOnyWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        if let email = Auth.auth().currentUser?.email{
            
            Database.database().reference().child("RequestDriver").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: {(snapshot) in
                self.driverCalling = true
                self.callDriverBtn.setTitle("Cancel driver", for: .normal)
                Database.database().reference().child("RequestDriver").removeAllObservers()
                
                if let rudeRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let driverlat = rudeRequestDictionary["driverLatitude"] as? Double{
                        if let driverlong = rudeRequestDictionary["driverLongitude"] as? Double{
                            self.driverLocation = CLLocationCoordinate2D(latitude:driverlat , longitude:driverlong)
                            self.driverOnyWay = true
                 self.showDriverRider()
               
                        }
                    }
                }
                        
        })
        
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    
    
    func showDriverRider(){
        let driverCLocation = CLLocation(latitude:driverLocation.latitude , longitude:driverLocation.longitude)
        let riderCLocation = CLLocation(latitude:userLocation.latitude , longitude:userLocation.longitude)
        let  distancebtw = driverCLocation.distance(from: riderCLocation) / 1000
        let distanceResult = round(distancebtw * 100) / 100
        callDriverBtn.setTitle("Driver distance \(distanceResult) km please wait", for: .normal)
        
        map.removeAnnotations(map.annotations )
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let longDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        let span  = MKCoordinateSpan(latitudeDelta: latDelta , longitudeDelta: longDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: userLocation , span:span)
        map.setRegion(region, animated: true)
        
        let riderPoint = MKPointAnnotation()
        riderPoint.coordinate = userLocation
        riderPoint.title = "You here !"
        map.addAnnotation(riderPoint)
        
        let driverPoint = MKPointAnnotation()
        driverPoint.coordinate = driverLocation
        driverPoint.title = "You here !"
        map.addAnnotation(driverPoint)
        
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coords = manager.location?.coordinate{
            
            
            let latDelta: CLLocationDegrees = 0.01
            let longDelta: CLLocationDegrees = 0.01
            
            let span  = MKCoordinateSpan(latitudeDelta: latDelta , longitudeDelta: longDelta)
            
            let location  = CLLocationCoordinate2D(latitude: coords.latitude , longitude: coords.longitude)
            
            userLocation = location
            
            
            
            if driverCalling{
                showDriverRider()
                if let email = Auth.auth().currentUser?.email{
                    Database.database().reference().child("RequestDriver").queryOrdered(byChild: "email").queryEqual(toValue: email ).observe(.childAdded, with: {(snapshot) in
                        if let rudeRequestDictionary = snapshot.value as? [String:AnyObject] {
                            if let driverlat = rudeRequestDictionary["driverLatitude"] as? Double{
                                if let driverlong = rudeRequestDictionary["driverLongitude"] as? Double{
                                    self.driverLocation = CLLocationCoordinate2D(latitude:driverlat , longitude:driverlong)
                                    self.driverOnyWay = true
                                    self.showDriverRider()
                                    
                                    
                                    if let rudeRequestDictionary = snapshot.value as? [String:AnyObject] {
                                        if let driverlat = rudeRequestDictionary["driverLatitude"] as? Double{
                                            if let driverlong = rudeRequestDictionary["driverLongitude"] as? Double{
                                                self.driverLocation = CLLocationCoordinate2D(latitude:driverlat , longitude:driverlong)
                                                self.driverOnyWay = true
                                                self.showDriverRider()
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                    
                                }
                            }
                        }
                    })
                }
                
            }else{
                let region: MKCoordinateRegion = MKCoordinateRegion(center: location , span:span)
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations )
                let annotation = MKPointAnnotation()
                annotation.title = "Hello there !"
                annotation.subtitle = "Muhammed Essa"
                annotation.coordinate = location
                map.addAnnotation(annotation)
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
       try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func callDriverAction(_ sender: Any) {
        
        if !driverOnyWay{
       

        if let email = Auth.auth().currentUser?.email{
            
            if driverCalling {
                driverCalling = false
                callDriverBtn.setTitle("Call driver", for: .normal)
                
                Database.database().reference().child("RequestDriver").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: {(snapshot) in
                    snapshot.ref.removeValue()
                Database.database().reference().child("RequestDriver").removeAllObservers()
                    
                })
                
            }else{
                let requestInfo : [String:Any] = ["email":email , "lat":userLocation.latitude , "long":userLocation.longitude]
                Database.database().reference().child("RequestDriver").childByAutoId().setValue(requestInfo)
                
                driverCalling = true
                callDriverBtn.setTitle("Cancel request", for: .normal)
            }

        }
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
