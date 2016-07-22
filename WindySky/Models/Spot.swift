//
//  Spot.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift

class Spot: Object {
    
    // MARK: - Properties -
    
    dynamic var id: Int = 0
    dynamic var name  = ""
    dynamic var country = ""
    dynamic var lon : Double = 0
    dynamic var lat : Double = 0
    
    // MARK: - Property Attributes -
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}