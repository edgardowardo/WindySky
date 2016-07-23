//
//  WindySkyTests.swift
//  WindySkyTests
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift
import XCTest
@testable import WindySky

class WindySkyTests: XCTestCase {
    
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Clean the realm first!
        try! realm.write({
            for existing in realm.objects(Current) {
                realm.delete(existing)
            }
        })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSpotService() {
        
        try! realm.write({
            for existing in realm.objects(Spot) {
                realm.delete(existing)
            }
        })
        
        XCTAssertEqual(realm.objects(Spot).count, 0)
        
        let e = expectationWithDescription("Expect to install Spot data.")
        
        SpotService.loadSpotData { (r) in
            XCTAssertEqual(r.objects(Spot).count, 209579)
            e.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    } 
    
    func testCitiesViewModel() {
        
        let vm = CitiesViewModel()
        XCTAssertEqual(vm.filteredObjects.value.count, 0)
        XCTAssertEqual(vm.currentObjects.value.count, 0)
        
        vm.getCurrentObjects()
        
        XCTAssertEqual(vm.filteredObjects.value.count, 0)
        XCTAssertEqual(vm.currentObjects.value.count, 2)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "FAVOURITES - 0")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 0)
        XCTAssertEqual(vm.currentObjects.value.last?.0, "RECENTS - 0")
        XCTAssertEqual(vm.currentObjects.value.last?.1.count, 0)

        //
        // Simulate position in London town!
        //
        let location = Coordinate()
        location.lat = 51.50998
        location.lon = -0.1337
        vm.coordinate = location
        
        vm.getCurrentObjects()
        XCTAssertEqual(vm.filteredObjects.value.count, 0)
        XCTAssertEqual(vm.currentObjects.value.count, 3)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "FAVOURITES - 0")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 0)
        XCTAssertEqual(vm.currentObjects.value[1].0, "NEARBY - 13")
        XCTAssertEqual(vm.currentObjects.value[1].1.count, 13)
        XCTAssertEqual(vm.currentObjects.value.last?.0, "RECENTS - 0")
    
        //
        // Filter the previous search with "Lon" among those previous 13
        //
        vm.getCurrentObjects("Lon", isFilter: true, isSearch: false)
        XCTAssertEqual(vm.filteredObjects.value.count, 3)
        XCTAssertEqual(vm.filteredObjects.value.first?.0, "FAVOURITES - 0")
        XCTAssertEqual(vm.filteredObjects.value.first?.1.count, 0)
        XCTAssertEqual(vm.filteredObjects.value[1].0, "NEARBY - 4")
        XCTAssertEqual(vm.filteredObjects.value[1].1.count, 4)
        XCTAssertEqual(vm.filteredObjects.value.last?.0, "RECENTS - 0")
        if let first = vm.filteredObjects.value[1].1.first {
            XCTAssertEqual(first.name, "London")
        } else {
            XCTFail("London is not first!")
        }
        
        XCTAssertEqual(vm.currentObjects.value.count, 3)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "FAVOURITES - 0")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 0)
        XCTAssertEqual(vm.currentObjects.value[1].0, "NEARBY - 13")
        XCTAssertEqual(vm.currentObjects.value[1].1.count, 13)
        XCTAssertEqual(vm.currentObjects.value.last?.0, "RECENTS - 0")
        
        //
        // Simulates the actual search button for "Lon"
        //
        vm.getCurrentObjects("Lon", isFilter: true, isSearch: true)

        XCTAssertEqual(vm.filteredObjects.value.count, 1)
        XCTAssertEqual(vm.filteredObjects.value.first?.0, "RESULTS - 425")
        XCTAssertEqual(vm.filteredObjects.value.first?.1.count, 425)
        if let first = vm.filteredObjects.value.first?.1.first {
            XCTAssertEqual(first.name, "London")
        } else {
            XCTFail("London is not first!")
        }
        
        XCTAssertEqual(vm.currentObjects.value.count, 3)
        XCTAssertEqual(vm.currentObjects.value.first?.0, "FAVOURITES - 0")
        XCTAssertEqual(vm.currentObjects.value.first?.1.count, 0)
        XCTAssertEqual(vm.currentObjects.value[1].0, "NEARBY - 13")
        XCTAssertEqual(vm.currentObjects.value[1].1.count, 13)
        XCTAssertEqual(vm.currentObjects.value.last?.0, "RECENTS - 0")
    }
    
    func testCityViewModelAsynchronously() {
        
        let id = 2643743 // London town!
        let e = expectationWithDescription("Expect return data from server")
        let vm = CityViewModel(cityid: id)
        XCTAssertEqual(vm.city, "")
//        XCTAssertEqual(vm.clouds, "")
//        XCTAssertEqual(vm.cloudsIcon, "")
//        XCTAssertEqual(vm.temperature, "")
//        XCTAssertEqual(vm.temperatureMin, "")
//        
        XCTAssertEqual(vm.realm.objects(Current).filter("id == \(id)").count, 0)
        
        vm.refreshCity {
            XCTAssertEqual(vm.city, "London")
//            XCTAssertGreaterThan(vm.clouds.characters.count, 0)
//            XCTAssertGreaterThan(vm.cloudsIcon.characters.count, 0)
//            XCTAssertGreaterThan(vm.temperature.characters.count, 0)
//            XCTAssertGreaterThan(vm.temperatureMin.characters.count, 0)
            
            //
            // London weather has been fetched, parsed and saved persistently!!!
            //
            XCTAssertEqual(vm.realm.objects(Current).filter("id == \(id)").count, 1)
            
            //
            // Another call to refresh without the call back means it was retrieved from the local datastore!
            //
            vm.refreshCity()
            XCTAssertEqual(vm.city, "London")
//            XCTAssertGreaterThan(vm.clouds.characters.count, 0)
//            XCTAssertGreaterThan(vm.cloudsIcon.characters.count, 0)
//            XCTAssertGreaterThan(vm.temperature.characters.count, 0)
//            XCTAssertGreaterThan(vm.temperatureMin.characters.count, 0)
            
            e.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testOpenWeatherMapServiceAsynchronouslyNegative() {
        let id = -1
        let e = expectationWithDescription("Expect return error from server using the service")
        
        OpenWeatherMapService.fetchCityAndForecast(withId: id, errorCallback:
            { (message) in
                XCTAssertNotNil(message)
                if let m = message {
                    XCTAssertEqual(m, "Error: Not found city")
                }
                e.fulfill()
            }) { (city, forecasts) in
                XCTFail("Should not have completed service.")
            }
        waitForExpectationsWithTimeout(60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testOpenWeatherMapServiceAsynchronously() {
        
        let id = 2643743 // London town!
        let e = expectationWithDescription("Expect return data from server using the service")
        
        OpenWeatherMapService.fetchCityAndForecast(withId: id) { (city, forecasts) in
            XCTAssertEqual(city.name, "London")
            XCTAssertNil(city.lastupdate)
            XCTAssertNotNil(city.coord)
            if let c = city.coord {
                XCTAssertEqual(c.lon, -0.13)
                XCTAssertEqual(c.lat, 51.509999999999998)
            }
            XCTAssertNotNil(city.wind)
            if let w = city.wind {
                XCTAssertGreaterThanOrEqual(w.speed, 0.0)
                XCTAssertGreaterThanOrEqual(w.deg, 0.0)
                XCTAssertLessThanOrEqual(w.deg, 360.0)
            }
            XCTAssertNotNil(city.sys)
            if let c = city.sys {
                XCTAssertEqual(c.country,"GB")
            }
            XCTAssertEqual(city.forecasts.count, 0)
            XCTAssertGreaterThan(forecasts.list.count, 0)
            
            //
            // first forecast is today
            //
            XCTAssertNotNil(forecasts.list.first)
            if let f = forecasts.list.first {
                let firstDate = NSDateFormatter.nsdateFromString(f.dt_txt)
                XCTAssertNotNil(firstDate)                
                if let d = firstDate {
                    let isDateInToday = NSCalendar.currentCalendar().isDateInToday(d)
                    XCTAssertEqual(isDateInToday, true)
                }
                XCTAssertNotNil(f.main)
                XCTAssertNotNil(f.wind)
                if let w = f.wind {
                    XCTAssertGreaterThanOrEqual(w.speed, 0.0)
                    XCTAssertGreaterThanOrEqual(w.deg, 0.0)
                    XCTAssertLessThanOrEqual(w.deg, 360.0)
                }
            }

            //
            // last forecast is later than today
            //
            XCTAssertNotNil(forecasts.list.last)
            if let l = forecasts.list.last {
                let lastDate = NSDateFormatter.nsdateFromString(l.dt_txt)
                XCTAssertNotNil(lastDate)
                if let l = lastDate {
                    XCTAssertEqual(NSDate().compare(l), NSComparisonResult.OrderedAscending)
                }
                XCTAssertNotNil(l.main)
                XCTAssertNotNil(l.wind)
                if let w = l.wind {
                    XCTAssertGreaterThanOrEqual(w.speed, 0.0)
                    XCTAssertGreaterThanOrEqual(w.deg, 0.0)
                    XCTAssertLessThanOrEqual(w.deg, 360.0)
                }
            }
            e.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
