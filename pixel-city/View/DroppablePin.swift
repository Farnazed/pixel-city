//
//  DroppablePin.swift
//  pixel-city
//
//  Created by farnaz on 2019-10-16.
//  Copyright © 2019 farnaz. All rights reserved.
//

import Foundation
import MapKit

class DroppablePin: NSObject, MKAnnotation{
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier : String
    
    init(coordinate : CLLocationCoordinate2D, identifier : String){
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
