//
//  CityViewModel.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Alamofire

class CityViewModel {
    
    var realm : Realm! = try? Realm()
    var disposeBag = DisposeBag()
    var current: Variable<Current?> = Variable(nil)
    var isFavourite : Variable<Bool> = Variable(false)
    var hudDelegate : HudDelegate?
    var forecastuples : [(String, NSDate, [Forecast])]?
    private var cityid : Int
    private var realmForecasts : Results<Forecast>? {
        didSet {
            let sections = Set( realmForecasts!.valueForKey("day") as! [String])
            forecastuples = []
            for s in sections {
                if let perdays = realmForecasts?.filter({ s == $0.day }).sort({ $0.timefrom!.compare($1.timefrom!) == .OrderedAscending }), f = perdays.first, date = f.date {
                    forecastuples!.append( (s, date, perdays))
                }
            }
            forecastuples?.sortInPlace({ $0.1.compare($1.1) == .OrderedAscending })
        }
    }
    
    init(cityid : Int) {
        self.cityid = cityid
    }
    
    var title : String {
        if let c = current.value, s = c.sys {
            return "\(s.country), \(c.name)"
        }
        return ""
    }
    
    var direction : Direction? {
        if let c = current.value, w = c.wind {
            let directioncode = Direction.fromDegree(w.deg).rawValue
            if directioncode.characters.count > 0 {
                return Direction(rawValue: directioncode)!
            }
        }
        return nil
    }
    
    var speed : Double {
        if let c = current.value, w = c.wind {
            return w.speed
        }
        return -1.0
    }
    
    var speedName : String {
        switch speed {
        case 0.0 ... 6.0:
            return "Gentle"
        case 6.0 ... 9.0:
            return "Moderate"
        case 9.0 ... 15:
            return "Fresh"
        case 15 ... Double.infinity :
            return "Strong"
        default :
            return "Windless"
        }
    }
    
    var since : String {
        if let c = current.value, lastupdate = c.lastupdate {
            return "since \(lastupdate.hourAndMin)"
        }
        return ""
    }
    
    var iconUnfavourite : String {
        return "icon-star-outline"
    }
    
    var iconFavourite : String {
        return "icon-superstar"
    }
    
    var chartNoDataText : String {
        return "Wind data is still up in the air..."
    }

    var directions : [String] {
        return Direction.directions.map({ return $0.rawValue })
    }
    
    func toggleFavourite() {
        isFavourite.value = !isFavourite.value
        try! realm.write {
            current.value?.isFavourite = isFavourite.value
        }
    }
    
    func refreshCity(withCallBack : (()->Void)? = nil ) {
        var current : Current? = nil
        if let first = realm.objects(Current).filter("id == \(self.cityid)").first {
            current = first
        }
        
        // Current data is not stale. That is  it's less than half an hour, show this data.
        if let c = current, lastupdate = c.lastupdate where NSDate().timeIntervalSinceDate(lastupdate) / 3600 < 0.5 {
            self.current.value = c
            self.realmForecasts = c.forecasts.sorted("dt_txt", ascending: true)
            self.isFavourite.value = c.isFavourite
        } else {
            self.hudDelegate?.showHud(text: "Searching...")
            
            OpenWeatherMapService.fetchCityAndForecast(withId: self.cityid,
                                                       errorCallback: { (message) in self.hudDelegate?.hideHud() },
                                                       callback: { (city, forecasts) in
                                                        autoreleasepool {
                                                            try! self.realm.write {
                                                                city.lastupdate = NSDate()
                                                                city.forecasts = forecasts.list
                                                                self.realm.add(city, update: true)
                                                            }
                                                        }
                                                        self.current.value = city
                                                        self.realmForecasts = city.forecasts.sorted("dt_txt", ascending: true)
                                                        self.hudDelegate?.hideHud()
                                                        if let callback = withCallBack {
                                                            callback()
                                                        }
            })
        }
    }
}