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