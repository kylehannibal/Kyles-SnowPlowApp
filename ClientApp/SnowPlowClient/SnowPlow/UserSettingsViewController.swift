//
//  SettingsViewController.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 2/5/19.
//  Copyright © 2019 Hannibal Enterprises. All rights reserved.
//

import Foundation
import Parse
import Stripe

class UserSettingsViewController: UIViewController{
    
    @IBOutlet weak var paymentInfoImageView: UIImageView!
    @IBOutlet weak var usernameAvailabilityImageView: UIImageView!
    @IBOutlet weak var emailVerifiedImageView: UIImageView!
    @IBOutlet weak var UsernameTextField: UITextField!
    
    
    @IBOutlet weak var reRequestEmailVerificationButton: UIButton!
    @IBOutlet weak var requestPasswordResetButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let error = UIImage(named: "error-icon")
    let check = UIImage(named: "accept-icon")
    
    
    override func viewDidLoad() {
        global.checkLogin(currentView: self)
        guard let user = PFUser.current() else {
            print("you are not logged in. Please fix that")
            return
        }
        
        //Check if they are loaded and fill boxes
        //IF THIS SCREEN TIMES OUT, handle it
        let error = UIImage(named: "error-icon")
        UsernameTextField.text = user.username
        paymentInfoImageView.image = error
        usernameAvailabilityImageView.image = check
        emailVerifiedImageView.image = error
        
        requestPasswordResetButton.layer.cornerRadius = 8
        reRequestEmailVerificationButton.layer.cornerRadius = 8
        saveButton.layer.cornerRadius = 10
        logoutButton.layer.cornerRadius = 10
        
        
        checkStatus()
        
        
        
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        global.checkLogin(currentView: self)
        guard PFUser.current() != nil else {
            logOutButton(UIButton())
            return
        }
    }
    
    func checkStatus(){
        guard let me = PFUser.current() else {
            logOutButton(UIButton())
            return
        }
        //Check Status of payment info
        
        //check status of Username availability(?) WHy is availability a problem?
        if me.username != me.email{
            usernameAvailabilityImageView.image = check
        }
        //check if email is verified
        guard let verified = me.object(forKey: "emailVerified") else {return}
        if verified as! Bool == true{
            emailVerifiedImageView.image = check
        }
        
    }
    
    @IBAction func addPaymentInfoButton(_ sender: UIButton) {
        // segue somewhere else for future Kyle to deal with
        
    }
    
    @IBAction func usernameTextTypingEnd(_ sender: UITextField) {
        guard let myUsername = UsernameTextField.text else{return}
        guard let user = PFUser.current() else {
            displayErrorMessage(message: "You are not logged in.")
            return
        }
        let query = PFQuery(className: "_User")
        print("UsernameText was tapped")
        query.whereKey("username", equalTo: myUsername)
        do{
            let userList = try query.findObjects()
            
            if (userList.count == 0){
                usernameAvailabilityImageView.image = check
            }else if((userList[0].objectId == user.objectId)){
                usernameAvailabilityImageView.image = check
            }else{
                //displayErrorMessage(message: "That username is taken, try another one!")
                usernameAvailabilityImageView.image = error
                //this is very annoying, need alternative
            }
        }catch{
            print("could not query usernames")
        }
    }
    
    @IBAction func requestEmailVerificationButton(_ sender: UIButton?) {
        guard let user = PFUser.current() else{
            displayErrorMessage(message: "You are not logged in.")
            return
        }
        let email = user.email
        user.email = ""
        user.saveInBackground { result, error in
            if error != nil {
                // Handle the error
                return
            }
            user.email = email
            user.saveInBackground {result, error in
                if error != nil {
                    // if error, deleted User's email. Oops
                    return
                }
            }
        }
    }
    @IBAction func saveButton(_ sender: UIButton) {
        guard let user = PFUser.current() else {
            print("you have been signed out")
            dismiss(animated: true, completion: nil)
            return
        }
        user["setup"] = true
        user["username"] = UsernameTextField.text
        do{
            try user.save()
            dismiss(animated: true, completion: nil)
        }catch{
            print("failure to save user!")
        }
    }
    
    @IBAction func requestPasswordReset(_ sender: UIButton) {
        displayErrorMessage(message: "Are you sure you want to reset your password?")
    }
    
    
    @IBAction func logOutButton(_ sender: UIButton) {
        guard let user = PFUser.current() else {
            dismiss(animated: false, completion: nil)
            return
        }
        //ADD SOMETHING HERE TO SAVE ALL FIELDS TO USER BEFORE LOGGING OUT
        user["setup"] = true
        print(user)
        do{
            try user.save()
        }catch{
            print("Could not save user")
            //add code here to stop function if that doesnt do it already
            return
        }
        //Could create infinite loop
        let sv = UIViewController.displaySpinner(onView: self.view)
        PFUser.logOutInBackground { (error: Error?) in
            UIViewController.removeSpinner(spinner: sv)
            if (error == nil){
                self.dismiss(animated: true, completion: nil)
            }else{
                if let descrip = error?.localizedDescription{
                    self.displayErrorMessage(message: descrip)
                }else{
                    self.displayErrorMessage(message: "error logging out")
                }
                
            }
        }
    }
    func displayErrorMessage(message: String){
        if message == "Are you sure you want to reset your password?"{
            let alertView = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let noAction = UIAlertAction(title: "No", style: .default){ (action: UIAlertAction) in
            }
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction) in
                do{
                    try PFUser.requestPasswordReset(forEmail: PFUser.current()!.email!)
                    print("password reset requested")
                    self.logOutButton(UIButton())
                }catch{
                    self.displayErrorMessage(message: "Unable to request password Reset")
                }
            }
            alertView.addAction(noAction)
            alertView.addAction(yesAction)
            self.present(alertView, animated: true, completion:nil)
        }else{
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
    }
}
