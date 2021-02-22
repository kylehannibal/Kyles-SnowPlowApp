//
//  LogInViewController.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 12/12/18.
//  Copyright © 2018 Hannibal Enterprises. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet fileprivate var signInUsernameField: UITextField!
    @IBOutlet fileprivate var signInPasswordField: UITextField!
    @IBOutlet fileprivate var signUpUsernameField: UITextField!
    @IBOutlet fileprivate var signUpPasswordField: UITextField!
    var failCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInUsernameField.text = ""
        signInPasswordField.text = ""
        signUpUsernameField.text = ""
        signUpPasswordField.text = ""
        
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
            global.setLocation(location: (locationManager.location?.coordinate ?? CLLocationCoordinate2DMake(0.0, 0.0)))
            
        } else {
            displayErrorMessage(message: "Please enable location services to use this application")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        signInUsernameField.text = ""
        signInPasswordField.text = ""
        signUpUsernameField.text = ""
        signUpPasswordField.text = ""
        let currentUser = PFUser.current()
        if currentUser != nil {
            print("current user is not equal to nil")
            if CLLocationManager.locationServicesEnabled() == true {
                if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                }
                
                locationManager.desiredAccuracy = 1.0
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
                loadHomeScreen()
                global.setLocation(location: (locationManager.location?.coordinate ?? CLLocationCoordinate2DMake(0.0, 0.0)))
                
            } else {
                displayErrorMessage(message: "Please enable location services")
            }
        }
    }
    @IBAction func signIn(_ sender: UIButton) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        PFUser.logInWithUsername(inBackground: signInUsernameField.text!, password: signInPasswordField.text!) { (user, error) in
            UIViewController.removeSpinner(spinner: sv)
            if user != nil {
                if PFUser.current()!.object(forKey: "userType") as! String != "User"{
                    self.displayErrorMessage(message: "You are using the incorrect version of the app!") // ADD MORE HERE
                } else{
                    self.loadHomeScreen()
                }
            }else{
                self.failCount += 1
                if let descrip = error?.localizedDescription{
                    self.displayErrorMessage(message: (descrip))
                }
            }
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        let user = PFUser()
        if !isValidEmail(testStr: signUpUsernameField.text!){
            displayErrorMessage(message: "That's not a valid email!")
            signUpUsernameField.text = ""
            return
        }
        user.username = signUpUsernameField.text
        user.password = signUpPasswordField.text
        user.email = signUpUsernameField.text!.lowercased()
        let sv = UIViewController.displaySpinner(onView: self.view)
        do{
            try user.signUp()
            UIViewController.removeSpinner(spinner: sv)
            let me = PFUser.current()!
            me["totalRatings"] = 0
            me["cumulativeNumber"] = 0
            me["jobs"] = []
            me["userType"] = "User"
            me["setup"] = false
            do{
                try me.save()
                self.performSegue(withIdentifier: "toUserMap", sender: nil)
            }catch{
                print("error in instantiating user")
                self.displayErrorMessage(message: "error in instantiating user")
                UIViewController.removeSpinner(spinner: sv)
            }
        }catch{
            self.displayErrorMessage(message: "Email is taken, try a different one.")
            self.signUpUsernameField.text = ""
            UIViewController.removeSpinner(spinner: sv)
        }
    }
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        if failCount >= 3 {
            let forgotPasswordAction = UIAlertAction(title: "Request Password Reset?", style: .destructive) { (forgotPasswordAction) in
                do {
                    try PFUser.requestPasswordReset(forEmail: self.signInUsernameField.text!)
                    print("password reset requested!")
                }catch{
                    print("Error requesting password reset for email ADD MORE CODE HERE TO HANDLE ERROR")
                }
                
            }
            alertView.addAction(forgotPasswordAction)
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadHomeScreen() {
        guard let user = PFUser.current() else{
            return
        }
        signInUsernameField.text = ""
        signInPasswordField.text = ""
        signUpUsernameField.text = ""
        signUpPasswordField.text = ""
        print((user.object(forKey: "setup") as! Bool))
        if !(user.object(forKey: "setup") as! Bool) || user.object(forKey: "userType") as! String == ""{
            DispatchQueue.main.async(){
                print("attempting to segue to setup")
                self.performSegue(withIdentifier: "toUserMap", sender: self)
            }
        }else{
            if user.object(forKey: "userType") as! String == "User"{
                DispatchQueue.main.async(){
                    print("attempting to segue to usermap")
                    self.performSegue(withIdentifier: "toUserMap", sender: self)
                }
            }
        }
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
