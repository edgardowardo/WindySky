//
//  OpenWeatherMapService.swift
//  SwanWeather
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import Alamofire

class OpenWeatherMapService {
    
    static func fetchCityAndForecast(withId cityid : Int, callback : (city: Current, forecasts: Forecasts)->Void ) {
        Alamofire
            .request(Router.Search(id: cityid))
            .responseJSON { response in
                if let json = response.result.value as? [String : AnyObject] {
                    let c = Current(value: json)
                    Alamofire
                        .request(Router.Forecast(id: cityid))
                        .responseJSON { response in
                            if let json = response.result.value as? [String : AnyObject] {
                                let f = Forecasts(value: json)
                                callback(city: c, forecasts: f)
                            }
                    }
                }
        }
    }
}

