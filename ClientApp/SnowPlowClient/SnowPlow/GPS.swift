//
//  GPS.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 1/8/19.
//  Copyright © 2019 Hannibal Enterprises. All rights reserved.
//

import Foundation
import Parse
import CoreLocation

class GPS {
    
    //converts CLLocationCoordinate2D object to Parse's PFGeoPoint object
    func CLlocationtoPFGeo(location: CLLocationCoordinate2D) -> PFGeoPoint{
        return PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
    }
    
    //converts Parse's PFGeoPoint object to CLLocationCoordinate2D object
    func PFGeotoClLocation(location: PFGeoPoint) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(location.latitude, location.longitude)
    }
    
}

