//
//  ViewController.swift
//  Uber
//
//  Created by Muhammed Essa on 1/13/18.
//  Copyright © 2018 Muhammed Essa. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var buttomButton: UIButton!
    
    @IBOutlet weak var riderLable: UILabel!
    @IBOutlet weak var switchLabel: UISwitch!
    @IBOutlet weak var driverLabel: UILabel!
    
    
    
    var signUpMode = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        
        if email.text == "" || password.text == "" {
            showAlert(title: "no info", message: "please check email and password")
        }else{
            if let emailtext = email.text{
                if let passwordtext = password.text{
                    
         
            if signUpMode{
                //sign up
                Auth.auth().createUser(withEmail: emailtext, password: passwordtext, completion: { (user, error) in
                    if error != nil {
                        self.showAlert(title: "Error", message: error!.localizedDescription)
                    }else{
                        print("Register Success")
                        
                        if self.riderDriverSwitch.isOn{
                            // driver
                           let req =  Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.displayName = "Driver"
                            req?.commitChanges(completion: nil)
                             self.performSegue(withIdentifier: "driverSegue", sender: nil)
                        }else{
                            // rider
                            let req =  Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.displayName = "Rider"
                            req?.commitChanges(completion: nil)
                            self.performSegue(withIdentifier: "riderSegue", sender: nil)
                        }
                    }
                })
            }else{
                // login
                Auth.auth().signIn(withEmail: emailtext, password: passwordtext, completion: { (user, error) in
                    if error != nil {
                        self.showAlert(title: "Error", message: error!.localizedDescription)
                    }else{
                        
                        if user?.displayName == "Driver"{
                            // driver
                            print("driverSegue")
                             self.performSegue(withIdentifier: "driverSegue", sender: nil)
                        }else{
                            //rider
                             self.performSegue(withIdentifier: "riderSegue", sender: nil)
                        }
                       
                    }
                })
                
            }
                }
            }
        }

    }
    
    func showAlert(title: String , message: String){
        let alertController = UIAlertController(title:title , message:message, preferredStyle:.alert )
        alertController.addAction(UIAlertAction(title:"OK", style:.default , handler:nil))
        self.present(alertController,animated: true,completion: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        
        if signUpMode{
            topButton.setTitle("Login", for: .normal)
            buttomButton.setTitle("Sign Up", for: .normal)
            riderLable.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
        }else{
            topButton.setTitle("Sign Up", for: .normal)
            buttomButton.setTitle("Login", for: .normal)
            riderLable.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
        }
        
    }
    
    


}

