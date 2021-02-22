//
//  UserMapViewController.swift
//  
//
//  Created by Kyle Hannibal on 12/12/18.
//

import UIKit
import MapKit
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
    
    func formatAddressFromPlacemark(placemark: CLLocation) -> String{
        //return (placemark.addressDictionary!["FormattedAddressLines"] as! [String]).joined(separator: ", ")
        return ""
    }
    
    @IBAction func userSettingsButtonTapped(_ sender: UIBarButtonItem) {
        guard let user = PFUser.current() else {
            print("Error recieving self")
            return
        }
        print(user)
        user["setup"] = false
        do{
            try user.save()
            performSegue(withIdentifier: "UserMaptoSettings", sender: nil)
        }catch{
            print("error saving user while segueing back to settings")
        }
    }
    
    func reverseGeoCoder(location: CLLocation) -> String?{
        let placemark = location
        
        
        print(placemark)
        return formatAddressFromPlacemark(placemark: placemark)
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
        //let acController =
        //acController.delegate = self as GMSAutocompleteViewControllerDelegate
        //present(acController, animated: true, completion: nil)
    }
    
    @IBAction func textFieldDone(_ sender: UITextField!) {
        //Could not get geocoder to work, so just says error
        textField.text = ""
    }
    @IBAction func didTapFlagsButton(_ sender: UIBarButtonItem){
        
    }
    
    override func viewDidLoad() {
        guard let user = PFUser.current() else{
            return
        }
        super.viewDidLoad()
        let locationManager = CLLocationManager()
        //Initiates the mapView
        let userLat = locationManager.location?.coordinate.latitude
        let userLong = locationManager.location?.coordinate.longitude
        let userLoc = CLLocationCoordinate2DMake(userLat!, userLong!) // 
        mapView.camera = MKMapCamera.init(lookingAtCenter: userLoc, fromEyeCoordinate: userLoc, eyeAltitude: 14000)
        //Sets up the marker where the user can specify the location
        //MUST CHANGE GLOBAL **EVERYTIME** MARKER IS CHANGED
        mapView.addAnnotation(marker)
        
        if user.object(forKey: "setup") as! Bool == false{
            userSettingsButtonTapped(UIBarButtonItem())
        }
        
        textField.text = reverseGeoCoder(location: CLLocation(latitude: userLat!, longitude: userLong!))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let user = PFUser.current() else{
            dismiss(animated: false, completion: nil)
            print("attempting to segue to login")
            return
        }
        if user.object(forKey: "setup") as! Bool == false{
            userSettingsButtonTapped(UIBarButtonItem())
        }
    }
}

extension UserMapViewController: MKMapViewDelegate {
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
    
    /*
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
 */

}

