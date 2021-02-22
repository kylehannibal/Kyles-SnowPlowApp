//
//  PlowMapViewController.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 12/12/18.
//  Copyright © 2018 Hannibal Enterprises. All rights reserved.
//

import UIKit
import MapKit
import Parse

class PlowMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var routeSelected = false
    var locationManager = CLLocationManager()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            global.checkLogin(currentView: self)
            let locationManager = CLLocationManager()
            mapView.delegate = self
            //Initializes the map
            let userLat = locationManager.location?.coordinate.latitude
            let userLong = locationManager.location?.coordinate.longitude
            let userLoc = CLLocationCoordinate2DMake(userLat!, userLong!)
            global.setLocation(location: userLoc)
            let camera = MKMapCamera.init(lookingAtCenter: userLoc, fromEyeCoordinate: userLoc, eyeAltitude: 14000)
            //camera(withLatitude: userLat ?? 42.581343, longitude: userLong ?? -70.952681 , zoom: 14)
            mapView.camera = camera
            //mapView.isUserLocationVisible
            updateUI()
            
            NotificationCenter.default.addObserver(self, selector:#selector(PlowMapViewController.checkLocationStatus), name:UIApplication.willEnterForegroundNotification, object: nil)
        }
    
    @objc func checkLocationStatus(){
        let currentLocation = (locationManager.location?.coordinate)!
        let currentCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let jobCLLocation = CLLocation(latitude: global.jobLocation.latitude, longitude: global.jobLocation.longitude)
        if (currentCLLocation.distance(from: jobCLLocation) * 1609.344) <= 5{
            //success, user made it to location
            performSegue(withIdentifier: "PlowMapToComplete", sender: nil)
        }else{
            //print
            let alert = UIAlertController(title: nil, message: "Drive to the location, you will be sent to the next screen upon arrival!", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel) { (alert) -> Void in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okButton)
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let user = PFUser.current() else {
            dismiss(animated: true, completion: nil)
            return
        }
        if user.object(forKey: "setup") as! Bool == false{
            SettingsButtonPressed(UIBarButtonItem())
        }
        //have to set routeSelected to false somewhere in this function, once returned to from markascompleted
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
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
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
        UIViewController.removeSpinner(spinner: sv)
        print("Complete!")
    }
    
    var flagSelected = false
    var fastestTime = 999999999999999999.0
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline){
            polylineRenderer.strokeColor = UIColor.init(red: 47/255, green: 141/255, blue: 255/255, alpha: 0.75)
            
        }
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if flagSelected{//doesnt allow user to look at other flags until denying or accepting the current route
            return
        }
        if let annotationTitle = view.annotation?.title
        {
            print("User tapped on annotation with title: \(annotationTitle!)")
            if annotationTitle!.contains("min") || annotationTitle!.contains("h "){
                view.isSelected = false
                view.isSelected = true
            }
            if annotationTitle!.contains("for"){
                let camera = MKMapCamera.init(lookingAtCenter: view.annotation!.coordinate, fromEyeCoordinate: view.annotation!.coordinate, eyeAltitude: 14000)
                mapView.setCamera(camera, animated: true)
                global.setObjIDJob(id: view.reuseIdentifier!)
            }
            if annotationTitle! == "My Location"{
                return
            }
            print(view.reuseIdentifier!)
        }
    }
    
    func plotPolyline(route: MKRoute){
        mapView.addOverlay(route.polyline)
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0), animated: true)
        }else{
            let polylineBoundingRect = mapView.visibleMapRect.union(route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineBoundingRect, edgePadding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0), animated: false)
        }
    }
    var fastestRoute: MKRoute = MKRoute()
    func calculateSegmentDirections(destination: CLLocationCoordinate2D){
        let request: MKDirections.Request = MKDirections.Request()
        request.transportType = .automobile
        
        let myLocation = MKMapItem(placemark: MKPlacemark(coordinate: (locationManager.location?.coordinate)!))
        let myDestination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        request.source = myLocation
        request.destination = myDestination
        
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response: MKDirections.Response?, error: Error?) in
            if let routeResponse = response?.routes{
                print(routeResponse.count)
                var time: Double = 99999999999999999999.0
                for route in routeResponse{
                    if route.expectedTravelTime < time{
                        time = route.expectedTravelTime
                        self.fastestRoute = route
                        print("Fastest time: \(time)")
                    }
                }
                self.plotPolyline(route: self.fastestRoute)
                let points = self.fastestRoute.polyline.points()
                let midpoint: CLLocationCoordinate2D = points[self.fastestRoute.polyline.pointCount / 2].coordinate
                let length = lengthPopUp(title: String(time), coordinate: midpoint)
                self.mapView.addAnnotation(length)
                self.mapView.selectAnnotation(length, animated: false)
            }else if let _ = error{
                let alert = UIAlertController(title: nil, message: "Directions not available", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .cancel) { (alert) -> Void in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(okButton)
                self.present(alert, animated: true)
            }
        }
        
        
    }
    
    @IBAction func SettingsButtonPressed(_ sender: UIBarButtonItem) {
        guard let user = PFUser.current() else {return}
        user["setup"] = false
        do{
            try user.save()
            performSegue(withIdentifier: "PlowMaptoSettings", sender: nil)
        }catch{
            print("error saving user while segueing back to settings")
        }
    }
    
    
}

extension PlowMapViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Flag{
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
                let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
                mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
                view.rightCalloutAccessoryView = mapsButton
            }
            view.markerTintColor = UIColor(displayP3Red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
            return view
        }else if let annotation = annotation as? lengthPopUp{
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: "EstimatedTime") as? MKMarkerAnnotationView{
                dequeuedView.annotation = annotation
                view = dequeuedView
                print("dequeued view")
            }else{
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "EstimatedTime")
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: 5)
                let goButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
                goButton.setImage(UIImage(named: "accept-icon"), for: .normal)
                view.rightCalloutAccessoryView = goButton
                routeSelected = true
                print("new view")
            }
            view.markerTintColor = UIColor.init(red: 47/255, green: 141/255, blue: 255/255, alpha: 0)
            print("printed view in lengthPopUp: \(view)")
            return view
        }
        return nil
    }
    
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard view.reuseIdentifier != nil else {return}
        print("\(view.reuseIdentifier!): \(routeSelected) ")
        if view.reuseIdentifier! == "EstimatedTime" && routeSelected{
            mapView.removeAnnotation(view.annotation!)
            mapView.removeOverlay(fastestRoute.polyline)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if view.reuseIdentifier! == "EstimatedTime"{
            routeSelected = false
            print(routeSelected)
            
            //Flags().markAsAccepted(objid: global.objIDJob)
            
            let alert = UIAlertController(title: nil, message: "Please return to the app once you have arrived", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Go", style: .cancel) { (alert) -> Void in
                let placemark = MKMapItem(placemark: MKPlacemark(coordinate: global.jobLocation))
                placemark.openInMaps(launchOptions: nil)
                self.navigationController?.popViewController(animated: true)
                view.isSelected = false
                
            }
            alert.addAction(okButton)
            self.present(alert, animated: true)
            
            //transition to directions?
            //popup to tell user not to force close app during process
            //popup to ask user for directions app to use
        }else{
            global.jobLocation = (view.annotation?.coordinate)!
            print("Info pane tapped")
            calculateSegmentDirections(destination: (view.annotation?.coordinate)!)
        }
        //performSegue(withIdentifier: "PlowMapToComplete", sender: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            performSegue(withIdentifier: "PlowMapToComplete", sender: nil)
        }
    }
    
}

class lengthPopUp: NSCoder, MKAnnotation { // fix this, make sure the item to appear on midpoint of polyline doesnt change camera, and has annotation view
    var title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        var number = Double(title)! / 60
        if number > 60{
            number = number / 60
            self.title = "\(Int(number))h \(lround((number - Double(Int(number))) * 60))m"
        }else{
            self.title = "\(lround(number)) min"
        }
        self.coordinate = coordinate
        
        super.init()
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
