//
//  Forecast+Extensions.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 23/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation

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
    
    var timefrom : NSDate? {
        get {
            return NSDateFormatter.nsdateFromString(dt_txt)
        }
    }
    
    var date : NSDate? {
        get {
            if let t = timefrom {
                let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let components = cal.components([.Day , .Month, .Year ], fromDate: t)
                let newDate = cal.dateFromComponents(components)
                return newDate
            }
            return nil
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