//
//  PointOfInterest.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/18/22.
//

import Foundation
import MapKit

class PointOfInterest: NSObject, MKAnnotation{
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
    }
    
    var subtitle: String? {
        return locationName
    }
}
