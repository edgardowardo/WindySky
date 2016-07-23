//
//  CitiesViewModel.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class CitiesViewModel {
    
    var realm : Realm! = try? Realm()
    var currentObjects: Variable<[(String, [Current])]> = Variable([])
    var filteredObjects: Variable<[(String, [Current])]> = Variable([])
    var coordinate: Coordinate?
    
    var searchBarPlaceHolder : String {
        return "Search with a city name"
    }
    
    var title : String {
        return "Windy Sky"
    }
    
    func getCurrentObjects(searchText : String? = nil, isFilter : Bool = false, isSearch : Bool = false) {
        var currents = [(String, [Current])]()
        
        if isSearch {
            let cities = realm.objects(Spot).filter("name contains '\(searchText!)'")
            let results = Array(cities.map({ return cityFromSpot($0) }))
            currents.append(("RESULTS - \(results.count)", results))
        } else {
            // Get favourite objects
            var favourites = realm.objects(Current).filter("isFavourite == 1")
            if let s = searchText {
                favourites = favourites.filter("name contains '\(s)'")
            }
            favourites = favourites.sorted("lastupdate", ascending: false)
            currents.append(("FAVOURITES - \(favourites.count)", Array(favourites)))
            
            // Get nearby objects
            if let loc = self.coordinate {
                let nearbies = getNearbies(fromLocation: loc, andSearchText: searchText)
                currents.append(("NEARBY - \(nearbies.count)", Array(nearbies)))
            }
            
            // Get recent objects
            var recents = realm.objects(Current)
            if let s = searchText {
                recents = recents.filter("name contains '\(s)'")
            }
            recents = recents.sorted("lastupdate", ascending: false)
            currents.append(("RECENTS - \(recents.count)", Array(recents)))
        }
        
        if isFilter {
            filteredObjects.value = currents
        } else {
            currentObjects.value = currents
        }
    }
    
    private func getNearbies(fromLocation location: Coordinate?, andSearchText searchText : String?) -> [Current] {
        if let loc = location {
            let latitude = loc.lat, longitude = loc.lon
            let searchDistance = 2.0
            let minLat = latitude - (searchDistance / 69)
            let maxLat = latitude + (searchDistance / 69)
            let minLon = longitude - searchDistance / fabs(cos(latitude.degreesToRadians)*69)
            let maxLon = longitude + searchDistance / fabs(cos(latitude.degreesToRadians)*69)
            let predicate = "lat <= \(maxLat) AND lat >= \(minLat) AND lon <= \(maxLon) AND lon >= \(minLon)"
            var nearbyCities = realm.objects(Spot).filter(predicate)
            if let s = searchText {
                nearbyCities = nearbyCities.filter("name contains '\(s)'")
            }
            let nearbies = nearbyCities.map( { return cityFromSpot($0) })
            return nearbies
        }
        return []
    }
    
    private func cityFromSpot(spot : Spot) -> Current {
        let c:Current = Current()
        c.id = spot.id
        c.name = spot.name
        c.sys = Sys()
        c.sys?.country = spot.country
        c.coord = Coordinate()
        c.coord?.lon = spot.lon
        c.coord?.lat = spot.lat
        return c
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    var degreesToRadians : Double {
        return self * M_PI / 180.0
    }
}