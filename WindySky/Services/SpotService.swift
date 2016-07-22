//
//  SpotService.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift

struct SpotService {

    struct Notification {
        struct Identifier {
            static let willloadSpotData = "NotificationIdentifierOf_willloadSpotData"
            static let didloadSpotData = "NotificationIdentifierOf_didloadSpotData"
        }
    }

    static func loadSpotData(withCallBack : ((realm : Realm)->Void)? = nil ) {
        
        dispatch_async(dispatch_queue_create("loadCityOnBackground", nil)) {
            
            guard let jsonFilePath = NSBundle.mainBundle().pathForResource("city.list", ofType: "json") else { return }
            
            if let jsonData = NSData(contentsOfFile: jsonFilePath) {
                
                dispatch_sync(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.Identifier.willloadSpotData, object: nil)
                })
                
                do {
                    let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                    
                    autoreleasepool {
                        if let jsonArray = jsonObject as? [NSDictionary], realm = try? Realm() {
                            
                            try! realm.write({

                                print("\(NSDate()) loadSpotData")
                                
                                for cityData in jsonArray {
                                    let city = Spot()
                                    
                                    if let id = cityData["_id"] as? Int, name = cityData["name"] as? String, country = cityData["country"] as? String, coordData = cityData["coord"] as? [String : AnyObject], lon = coordData["lon"] as? Double, lat = coordData["lat"] as? Double {
                                        
                                        city.id = id
                                        city.name = name
                                        city.country = country
                                        city.lon = lon
                                        city.lat = lat
                                    }
                                    
                                    realm.add(city, update: true)
                                }
                                print("\(NSDate()) loadedSpotData... \(realm.objects(Spot).count) records")
                            })
                            
                            if let callback = withCallBack {
                                callback(realm: realm)
                            }
                        }
                    }
                    
                } catch {
                    print("city JSON Error: \(error)")
                }
                
                dispatch_sync(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.Identifier.didloadSpotData, object: nil)
                })
            }
        }
    }
}