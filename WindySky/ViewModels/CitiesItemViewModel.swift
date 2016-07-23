//
//  CitiesItemViewModel.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 22/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import CoreLocation

class CitiesItemViewModel {

    var current : Current!
    var currentLocation : CLLocation?
    var indexPath : NSIndexPath!

    init(current : Current, currentLocation : CLLocation?, indexPath : NSIndexPath) {
        self.current = current
        self.currentLocation = currentLocation
        self.indexPath = indexPath
    }

    var mainText : String {
        return self.current.name
    }
    
    var iconName : String {
        if indexPath.section > 0 {
            return "icon-dot-fill"
        }
        return self.current.isFavourite ? "icon-superstar" : "icon-dot-fill"
    }
    
    private var location : CLLocation {
        get {
            if let c =  self.current.coord {
                return CLLocation(latitude: c.lat, longitude: c.lon)
            }
            return CLLocation(latitude: 0, longitude: 0)
        }
    }
        
    var detailText : String {
        if let d = self.currentLocation?.distanceFromLocation(location), c = current, s = c.sys {
            let distance = d / 1000
            return "\(s.country), \(Int(distance))km"
        }
        return ""
    }
}