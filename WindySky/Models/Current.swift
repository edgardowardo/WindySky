//
//  Current.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift

class Sys : Object {
    dynamic var country  = ""
}

class Wind : Object {
    dynamic var speed : Double = 0
    dynamic var deg : Double = 0
}

class Coordinate : Object {
    dynamic var lon : Double = 0
    dynamic var lat : Double = 0
}

class Current : Object {
    dynamic var id: Int = 0
    dynamic var lastupdate : NSDate? = nil
    dynamic var name  = ""
    dynamic var coord : Coordinate?
    dynamic var wind : Wind?
    dynamic var sys : Sys?
    dynamic var isFavourite = false
    var forecasts = List<Forecast>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Current {
    var direction : Direction? {
        get {
            let deg = wind!.deg
            let directioncode = Direction.fromDegree(deg).rawValue
            if directioncode.characters.count > 0 {
                return Direction(rawValue: directioncode)!
            } else {
                return nil
            }
        }
    }
}