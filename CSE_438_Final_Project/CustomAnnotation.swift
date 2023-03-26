//
//  CustomAnnotation.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 12/4/22.
//

import UIKit
import MapKit
class CustomAnnotation: MKMarkerAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override var annotation: MKAnnotation? {
        willSet{
            displayPriority = MKFeatureDisplayPriority.required
        }
    }

}
