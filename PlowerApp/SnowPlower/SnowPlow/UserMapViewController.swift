//
//  UserMapViewController.swift
//  
//
//  Created by Michael Baraty on 12/12/18.
//

import UIKit
import MapKit
import GooglePlaces
import Parse

class UserMapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var textField: UITextField!
    
    var marker: MKPlacemark = MKPlacemark.init(coordinate: global.jobLocation)
    var locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    //segues to the table view controller showing users' past requests
    @IBAction func seeRequestsButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "MapToRequests", sender: nil)
    }
    
    @IBAction func userSettingsButtonTapped(_ sender: UIBarButtonItem) {
        guard let user = PFUser.current() else {return}
        user["setup"] = false
        do{
            try user.save()
            dismiss(animated: true, completion: nil)
            //unwind(for: , towards: SettingsViewController)
        }catch{
            print("error saving user while segueing back to settings")
        }
    }
    
    
    //prepares for and performs segue to the form
    @IBAction func selectLocationButtonTapped(_ sender: UIBarButtonItem) {
        print(global.jobLocation)
        performSegue(withIdentifier: "UserMapToForm", sender: nil)
        print("button worked")
    }
    
    // Present the Autocomplete view controller when the textField is tapped.
    @IBAction func textFieldTapped(_ sender: UITextField) {
        textField.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(acController, animated: true, completion: nil)
    }
    
    @IBAction func textFieldDone(_ sender: UITextField!) {
        //Could not get geocoder to work, so just says error
        textField.text = ""
    }
    @IBAction func didTapFlagsButton(_ sender: UIBarButtonItem){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        global.checkLogin(currentView: self)
        let locationManager = CLLocationManager()
        //Initiates the mapView
        let userLat = locationManager.location?.coordinate.latitude
        let userLong = locationManager.location?.coordinate.longitude
        let userLoc = CLLocationCoordinate2DMake(userLat!, userLong!)
        mapView.camera = MKMapCamera.init(lookingAtCenter: userLoc, fromEyeCoordinate: userLoc, eyeAltitude: 14000)
        //Sets up the marker where the user can specify the location
        //MUST CHANGE GLOBAL **EVERYTIME** MARKER IS CHANGED
        mapView.addAnnotation(marker)
        
        getCoordinate(addressString: "1600 Pennsylvania Ave NW, Washington, DC 20500") { (location, error) in
            print("White house is at \(location)")
        }
    }
}

extension UserMapViewController: MKMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        textField.text = place.name
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }


}

