//
//  Units.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 22/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import UIColor_FlatColors

extension Units {
    func getColorOfSpeed(speed : Double) -> UIColor {
        switch self {
        case .Nautical :
            let x = 1.94384            
            switch speed {
            case 0.0 ... 6.0 * x :
                return UIColor.flatBelizeHoleColor()
            case 6.0 * x ... 9.0 * x :
                return UIColor.flatGreenSeaColor()
            case 9.0 * x ... 15 * x :
                return UIColor.flatOrangeColor()
            case 15 * x ... Double.infinity :
                return UIColor.flatPomegranateColor()
            default :
                return UIColor.flatCloudsColor()
            }
        case .Metric :
            switch speed {
            case 0.0 ... 6.0 :
                return UIColor.flatBelizeHoleColor()
            case 6.0 ... 9.0 :
                return UIColor.flatGreenSeaColor()
            case 9.0 ... 15 :
                return UIColor.flatOrangeColor()
            case 15 ... Double.infinity :
                return UIColor.flatPomegranateColor()
            default :
                return UIColor.flatCloudsColor()
            }
        case .Imperial :
            switch speed {
            case 0.0 ... 13.4216 :
                return UIColor.flatBelizeHoleColor()
            case 13.4216 ... 20.1324 :
                return UIColor.flatGreenSeaColor()
            case 20.1324 ... 33.554 :
                return UIColor.flatOrangeColor()
            case 33.554 ... Double.infinity :
                return UIColor.flatPomegranateColor()
            default :
                return UIColor.flatCloudsColor()
            }
        }
    }
}

