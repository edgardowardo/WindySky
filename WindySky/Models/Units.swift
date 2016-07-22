//
//  Units.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 02/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation

enum PseudoSpeed {
    case Gentle, Moderate, Fresh, Strong
}

enum Units : String {
    case Metric , Imperial, Nautical
    
    func toUnit(fromSpeedMeterPerSecond speed : Double) -> Double {
        switch self {
        case .Nautical :
            return Units.toKnots(speed)
        case .Imperial :
            return Units.toMph(speed)
        case .Metric :
            return speed
        }
    }
    
    static func toKnots(ms : Double) -> Double {
        let val = ms * 1.94384
        let s = String(format:"%.2f", val)
        return Double(s)!
    }
    
    static func toMph(ms : Double) -> Double {
        let val = ms * 2.237
        let s = String(format:"%.2f", val)
        return Double(s)!
    }
    
    func toImperial(km : Double) -> Double {
        return km * 0.621371
    }
    
    func getMeterPerSecond(speed : Double) -> Double {
        switch self {
        case .Imperial :
            return speed / 2.237
        case .Metric :
            return speed
        case .Nautical :
            return speed / 1.94384
        }
    }
    
    var short : String {
        get {
            switch self {
            case .Nautical :
                fallthrough
            case .Metric :
                return "km"
            case .Imperial :
                return "mi"
            }
        }
    }
        
    var speed : String {
        get {
            switch self {
            case .Metric :
                return "m/s"
            case .Imperial :
                return "mph"
            case .Nautical:
                return "kn"
            }
        }
    }
    
    var temperature : String {
        get {
            switch self {
            case .Nautical:
                fallthrough
            case .Metric :
                return "C"
            case .Imperial :
                return "F"
            }
        }
    }
    
    var maxSpeed : Double {
        switch self {
        case .Nautical:
            return Units.toKnots(17)
        case .Metric :
            return 17.0
        case .Imperial :
            return 38.0279
        }
    }
    
    func getLegendOfSpeed(pseudoSpeed : PseudoSpeed) -> String {
        switch self {
        case .Metric :
            switch pseudoSpeed {
            case .Gentle :
                return "0 - 6 \(speed)"
            case .Moderate :
                return "6 - 9 \(speed)"
            case .Fresh :
                return "9 - 15 \(speed)"
            case .Strong :
                return "15+ \(speed)"
            }
        case .Imperial :
            switch pseudoSpeed {
            case .Gentle :
                return "0 - 14 \(speed)"
            case .Moderate :
                return "14 - 21 \(speed)"
            case .Fresh :
                return "21 - 34 \(speed)"
            case .Strong :
                return "34+ \(speed)"
            }
        case .Nautical :
            switch pseudoSpeed {
            case .Gentle :
                return "0 - 12 \(speed)"
            case .Moderate :
                return "12 - 18 \(speed)"
            case .Fresh :
                return "18 - 30 \(speed)"
            case .Strong :
                return "30+ \(speed)"
            }
        }
    }
    
}