//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Muhammed Essa on 1/14/18.
//  Copyright © 2018 Muhammed Essa. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {

    
    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail =  ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latDelta: CLLocationDegrees = 0.01
        let longDelta: CLLocationDegrees = 0.01
        let span  = MKCoordinateSpan(latitudeDelta: latDelta , longitudeDelta: longDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: requestLocation , span:span)
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Hello there !"
        annotation.subtitle = "Muhammed Essa"
        annotation.coordinate = requestLocation
        map.addAnnotation(annotation)

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func acceptBtn(_ sender: Any) {
        // update rider request
        
        Database.database().reference().child("RequestDriver").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded, with: {(snapshot) in
            snapshot.ref.updateChildValues((["driverLatitude":self.driverLocation.latitude , "driverLongitude":self.driverLocation.longitude ]))
            Database.database().reference().child("RequestDriver").removeAllObservers()
        })
        
        
        // dive direction
        
        let requestClocation = CLLocation(latitude:requestLocation.latitude,longitude:requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestClocation){(placemarks , error) in
            if let placemarks = placemarks{
                if  placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark:placeMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
            
        }
    }
    
  

}
