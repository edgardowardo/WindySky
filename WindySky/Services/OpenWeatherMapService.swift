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
    
    static func fetchCityAndForecast(withId cityid : Int, errorCallback : ((message : String?) -> Void)? = nil, callback : (city: Current, forecasts: Forecasts)->Void ) {
        Alamofire
            .request(Router.Search(id: cityid))
            .responseJSON { response in
                if let json = response.result.value as? [String : AnyObject] {
                    guard let cod = json["cod"] as? Int where cod == 200 else {
                        if let errorBack = errorCallback {
                            errorBack(message: json["message"] as? String)
                        }
                        return
                    }
                    let c = Current(value: json)
                    Alamofire
                        .request(Router.Forecast(id: cityid))
                        .responseJSON { response in
                            if let json2 = response.result.value as? [String : AnyObject] {
                                guard let cod = json2["cod"] as? String where cod == "200" else {
                                    if let errorBack = errorCallback {
                                        errorBack(message: json2["message"] as? String)
                                    }
                                    return
                                }
                                let f = Forecasts(value: json2)
                                callback(city: c, forecasts: f)
                            }
                    }
                }
        }
    }
}

