//
//  Forecasts.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift

class ForecastMain : Object {
    dynamic var temp : Double = 0
}

class Forecast : Object {
    dynamic var dt_txt  = ""
    dynamic var main : ForecastMain?
    dynamic var wind : Wind?
}

class Forecasts : Object {
    let list = List<Forecast>()
}


extension Forecast {    
    var hour : String {
        get {
            let timefrom = NSDateFormatter.nsdateFromString(dt_txt)
            if let t = timefrom {
                let h = NSCalendar.currentCalendar().component(.Hour, fromDate: t)
                let f = NSNumberFormatter()
                f.minimumIntegerDigits = 2
                return f.stringFromNumber(h)!
            }
            return "HH"
        }
    }
    
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
    
    var day : String {
        get {
            let timefrom = NSDateFormatter.nsdateFromString(dt_txt)
            if let t = timefrom {
                if t.isToday() {
                    return "TODAY"
                } else if t.isYesterday() {
                    return ""
                }
                
                let f = NSDateFormatter()
                f.dateFormat = "EEE, dd MMM"
                let s = f.stringFromDate(t)
                return s.uppercaseString
            }
            return "TODAY"
        }
    }
}