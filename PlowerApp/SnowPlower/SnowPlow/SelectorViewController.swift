//
//  SelectorViewController.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 12/12/18.
//  Copyright © 2018 Hannibal Enterprises. All rights reserved.
//

import UIKit
import Parse

class SelectorViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var userOptionButton: UIButton!
    @IBOutlet weak var plowOptionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        global.checkLogin(currentView: self)
        userOptionButton.layer.cornerRadius = 60
        plowOptionButton.layer.cornerRadius = 60
        print(global.myType())
        // Do any additional setup after loading the view.
        
        //requests location access from user
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
            global.setLocation(location: (locationManager.location?.coordinate ?? CLLocationCoordinate2DMake(0.0, 0.0)))
            
        } else {
            displayErrorMessage(message: "Please enable location services")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let user = PFUser.current() else {
            return
        }
        if user["userType"] as! String != ""{
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "SelectortoSettings", sender: self)
            }
        }
    }
    
    @IBAction func CallPlowButton(_ sender: UIButton) {
        global.setUserType(type: "User", logout: false)
        performSegue(withIdentifier: "SelectortoSettings", sender: nil)
    }
    @IBAction func PlowButton(_ sender: UIButton) {
        global.setUserType(type: "Plow", logout: false)
        performSegue(withIdentifier: "SelectortoSettings", sender: nil)
    }
    
    
    //Log in/out functions borrowed from Back4App Tutorials
    func loadLoginScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let logInViewController = storyBoard.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        self.present(logInViewController, animated: true, completion: nil)
    }
    
//    @IBAction func logoutOfApp(_ sender: UIButton) {
//        let sv = UIViewController.displaySpinner(onView: self.view)
//        PFUser.logOutInBackground { (error: Error?) in
//            UIViewController.removeSpinner(spinner: sv)
//            if (error == nil){
//                self.loadLoginScreen()
//            }else{
//                if let descrip = error?.localizedDescription{
//                    self.displayErrorMessage(message: descrip)
//                }else{
//                    self.displayErrorMessage(message: "error logging out")
//                }
//
//            }
//        }
//    }
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
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

}
