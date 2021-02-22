//
//  Job.swift
//  SnowPlow
//
//  This class was used to map out the process of 
//  Created by Michael Baraty on 12/13/18.
//  Copyright © 2018 Baraty Hannibal Enterprises. All rights reserved.
//

import Foundation
import Parse
import CoreLocation
import MapKit

class Job: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let payment: Double
    let size: Double

    init(coordinate: CLLocationCoordinate2D, payment: Double, size: Double) {
        self.coordinate = coordinate
        self.payment = payment
        self.size = size
        
        super.init()
    }
    
    func sendJobToServer(job: Job) {
        
    }
    
    func recieveJobsFromServer() -> [Job] {
        return [Job(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), payment: 10.0, size: 30)]
    }
    
    func markJobAsCompleted(job: Job) {
        
    }
    
    var subtitle: String? {
        return "$\(payment); \(size) Sq. Ft."
    }
}
