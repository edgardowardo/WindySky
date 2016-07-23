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
    private var cityid : Int
    
    init(cityid : Int) {
        self.cityid = cityid
    }
    
    var city : String {
        if let t = current.value?.name {
            return t
        }
        return ""
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
                                                        self.hudDelegate?.hideHud()
                                                        if let callback = withCallBack {
                                                            callback()
                                                        }
            })
        }
    }
}