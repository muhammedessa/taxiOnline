//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Muhammed Essa on 1/14/18.
//  Copyright © 2018 Muhammed Essa. All rights reserved.
//

import UIKit
import FirebaseAuth
import  FirebaseDatabase
import CoreLocation
import MapKit

class DriverTableViewController: UITableViewController  , CLLocationManagerDelegate  {
    
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    var rudeRequest : [DataSnapshot] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        Database.database().reference().child("RequestDriver").observe(.childAdded, with: {(snapshot) in
            
            if let rudeRequestDictionary = snapshot.value as? [String:AnyObject] {
              if let lat = rudeRequestDictionary["driverLatitude"] as? Double{
                
              }else{
                self.rudeRequest.append(snapshot)
                self.tableView.reloadData()
                }
            }
            
        })
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coords = manager.location?.coordinate{
            driverLocation = coords
            }
        }

    
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rudeRequest.count
    }
    
    
    @IBAction func logoutDriver(_ sender: Any) {
        
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let snapshot = rudeRequest[indexPath.row]
        if let rudeRequestDictionary = snapshot.value as? [String:AnyObject] {
            if let email = rudeRequestDictionary["email"] as? String{
               
                if let lat = rudeRequestDictionary["lat"] as? Double{
                    if let long = rudeRequestDictionary["long"] as? Double{
                
                 let driverCurrentLocation = CLLocation(latitude:driverLocation.latitude , longitude: driverLocation.longitude)
                        
                 let riderCurrentLocation = CLLocation(latitude:lat , longitude: long)
                        
                       let  distancebtw = driverCurrentLocation.distance(from: riderCurrentLocation) / 1000
                        let distanceResult = round(distancebtw * 100) / 100
                   
                        cell.textLabel?.text =  "\(email) =  \(distanceResult)km"
                        
                    }
                }
                
                
            }
        }
        
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rudeRequest[indexPath.row]
        performSegue(withIdentifier: "acceptRequestCell", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController{
            
            if let snapshot = sender as? DataSnapshot{
                if let rudeRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let email = rudeRequestDictionary["email"] as? String{
                        
                        if let lat = rudeRequestDictionary["lat"] as? Double{
                            if let long = rudeRequestDictionary["long"] as? Double{
                                acceptVC.requestEmail = email
                                let location = CLLocationCoordinate2D(latitude:lat , longitude: long)
                                acceptVC.requestLocation = location
                                acceptVC.driverLocation = driverLocation
                            }
                        }
                    }
                }
                
            }
            
            
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
