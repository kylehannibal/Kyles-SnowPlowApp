//
//  PlowMapViewController.swift
//  SnowPlow
//
//  Created by Michael Baraty on 12/12/18.
//  Copyright © 2018 Baraty Hannibal Enterprises. All rights reserved.
//

import UIKit
import MapKit
import Parse

class PlowMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            global.checkLogin(currentView: self)
            let locationManager = CLLocationManager()
//            func checkLocationAuthorizationStatus() {
//                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//                    mapView.showsUserLocation = true
//                } else {
//                    locationManager.requestWhenInUseAuthorization()
//                }
//            }
//
//            func viewDidAppear(_ animated: Bool) {
//                super.viewDidAppear(animated)
//                checkLocationAuthorizationStatus()
//            }
            mapView.delegate = self
            //Initializes the map
            let userLat = locationManager.location?.coordinate.latitude
            let userLong = locationManager.location?.coordinate.longitude
            let userLoc = CLLocationCoordinate2DMake(userLat!, userLong!)
            let camera = MKMapCamera.init(lookingAtCenter: userLoc, fromEyeCoordinate: userLoc, eyeAltitude: 14000)
            //camera(withLatitude: userLat ?? 42.581343, longitude: userLong ?? -70.952681 , zoom: 14)
            mapView.camera = camera
            //mapView.isUserLocationVisible
            
            updateUI()
           
        }
    
    
    func updateUI() {
        //Shows the markers
        showMarkers()
    }
    
    //Shows an individual marker
    func showMarker(position: CLLocationCoordinate2D, size: Double, price: Double, id: String){
        
        let marker = Flag(title: "\(size) sq. Ft. for \(price)", locationName: "Placeholder Loc- Geocode", coordinate: position, ID: id)
        mapView.addAnnotation(marker)
        
    }
    
    //Shows all the markers that have not been accepted on the server
    func showMarkers() {
        
        let flagList = Flags().receiveFlags()
        print(flagList)
        print("printed flaglist inside of PMVC!")
        
        
        for dict in flagList {
            for item in dict.keys{
                let coord = GPS().PFGeotoClLocation(location: dict[item]!)
                
                let query = PFQuery(className: "Flags")
                do{
                    let object = try query.getObjectWithId(item)
                    if (object["accepted"] as! Bool == false) {
                        showMarker(position: coord, size: object["Size"] as! Double, price: object["Payment"] as! Double, id: object.objectId!)
                    }
                } catch {
                    print("error!")
                    //need to add more than this later
                }
                
                
                print("Dict item \(coord)")
            }
        }
        print("Complete!")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title
        {
            print("User tapped on annotation with title: \(annotationTitle!)")
            let camera = MKMapCamera.init(lookingAtCenter: view.annotation!.coordinate, fromEyeCoordinate: view.annotation!.coordinate, eyeAltitude: 14000)
            mapView.setCamera(camera, animated: true)
            global.setObjIDJob(id: view.reuseIdentifier!)
            print(view.reuseIdentifier!)
        }
    }
    
    @IBAction func SettingsButtonPressed(_ sender: UIBarButtonItem) {
        guard let user = PFUser.current() else {return}
        user["setup"] = false
        do{
            try user.save()
            dismiss(animated: true, completion: nil)
            //unwind?
        }catch{
            print("error saving user while segueing back to settings")
        }
    }
    
    
}

extension PlowMapViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Flag else { return nil }
        let identifier = annotation.objectId
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
            view.rightCalloutAccessoryView = mapsButton
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("Info pane tapped")
        performSegue(withIdentifier: "PlowMapToComplete", sender: nil)
    }
}

class Flag: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let objectId: String
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D, ID: String) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.objectId = ID
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
