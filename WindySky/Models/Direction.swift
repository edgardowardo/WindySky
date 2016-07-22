//
//  Direction.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 22/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation


enum Direction : String {
    case N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW
    
    static var directions : [Direction] {
        get {
            return [N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW]
        }
    }
    
    static func fromDegree(degree : Double) -> Direction {
        switch degree {
        case 348.75 ..< 360:
            fallthrough
        case 0 ..< 11.25:
            return .N
        case 11.25 ..< 33.75:
            return .NNE
        case 33.75 ..< 56.25:
            return .NE
        case 56.25 ..< 78.75:
            return .ENE
        case 78.75 ..< 101.25:
            return .E
        case 101.25 ..< 123.75:
            return .ESE
        case 123.75 ..< 146.25:
            return .SE
        case 146.25 ..< 168.75:
            return  .SSE
        case 168.75 ..< 191.25:
            return .S
        case 191.25 ..< 213.75:
            return .SSW
        case 213.75 ..< 236.25:
            return .SW
        case 236.25 ..< 258.75:
            return .WSW
        case 258.75 ..< 281.25:
            return .W
        case 281.25 ..< 303.75:
            return .WNW
        case 303.75 ..< 326.25:
            return .NW
        case 326.25 ..< 348.75:
            return .NNW
        default :
            assertionFailure("incorrect degree!")
            return .N
        }
    }
    
    var name : String {
        get {
            switch self {
            case N :
                return "North"
            case NNE :
                return "North north east"
            case NE:
                return "North east"
            case ENE:
                return "East north east"
            case E:
                return "East"
            case ESE:
                return "East south east"
            case SE:
                return "South east"
            case SSE:
                return "South south east"
            case S:
                return "South"
            case SSW:
                return "South south west"
            case SW:
                return "South west"
            case WSW:
                return "West south west"
            case W:
                return "West"
            case WNW:
                return "West north west"
            case NW:
                return "North west"
            case NNW:
                return "North north west"
            }
        }
    }
    
    var inverse : Direction {
        get {
            switch self {
            case N :
                return S
            case NNE :
                return SSW
            case NE:
                return SW
            case ENE:
                return WSW
            case E:
                return W
            case ESE:
                return WNW
            case SE:
                return NW
            case SSE:
                return NNW
            case S:
                return N
            case SSW:
                return NNE
            case SW:
                return NE
            case WSW:
                return ENE
            case W:
                return E
            case WNW:
                return ESE
            case NW:
                return SE
            case NNW:
                return SSE
            }
        }
    }
        
    func directionsWithspeed(speed : Double) -> [Double] {
        var speeds = Array<Double>.init(count: 16, repeatedValue: 0.0)
        let directions = Direction.directions
        
        if let index = directions.indexOf(self.inverse) {
            
            if index == 0 {
                speeds[directions.count-1] = speed
            } else {
                speeds[index-1] = speed
            }
            
            if index == directions.count-1 {
                speeds[0] = speed
            } else {
                speeds[index + 1] = speed
            }
            
            speeds[index] = speed
        }
        return speeds
   }
    
}