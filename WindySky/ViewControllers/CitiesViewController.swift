//
//  CitiesViewController.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RealmSwift
import CoreLocation

class CitiesViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    var cityViewController: CityViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var viewModel = CitiesViewModel()
    var location : CLLocation? {
        didSet {
            viewModel.coordinate = Coordinate()
            viewModel.coordinate?.lat = location!.coordinate.latitude
            viewModel.coordinate?.lon = location!.coordinate.longitude
        }
    }
    
    // MARK: - View lifecycle -
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.cityViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CityViewController
        }
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = viewModel.searchBarPlaceHolder
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Ask for current location and populate nearby spots
        if CLLocationManager.authorizationStatus() == .NotDetermined || CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        
        self.viewModel
            .currentObjects
            .asObservable()
            .subscribeNext({ (value) in
                self.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
        
        self.viewModel
            .filteredObjects
            .asObservable()
            .subscribeNext({ (value) in
                self.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var current: Current?
                if searchController.active && searchController.searchBar.text != "" {
                    current = viewModel.filteredObjects.value[indexPath.section].1[indexPath.row]
                } else {
                    current = viewModel.currentObjects.value[indexPath.section].1[indexPath.row]
                }
                if let controller = (segue.destinationViewController as? UINavigationController)!.topViewController as? CityViewController, id = current?.id {
                    controller.viewModel = CityViewModel(cityid: id)
                    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                        controller.viewModel?.hudDelegate = appDelegate
                    }
                    controller.title = self.viewModel.title
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    
    // MARK: - Table View
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return viewModel.filteredObjects.value.count
        }
        return viewModel.currentObjects.value.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return viewModel.filteredObjects.value[section].1.count
        }
        return viewModel.currentObjects.value[section].1.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let c: Current
        if searchController.active && searchController.searchBar.text != "" {
            c = viewModel.filteredObjects.value[indexPath.section].1[indexPath.row]
        } else {
            c = viewModel.currentObjects.value[indexPath.section].1[indexPath.row]
        }
        cell.textLabel!.text = c.name
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return viewModel.filteredObjects.value[section].0
        }
        return viewModel.currentObjects.value[section].0
    }
}

// MARK: - Core Location -

extension CitiesViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            viewModel.getCurrentObjects()
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
}

// MARK: - UISearchResultsUpdating Delegate -

extension CitiesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        viewModel.getCurrentObjects(searchText, isFilter: true)
    }
}

// MARK: - Search Bar Delegate -

extension CitiesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        viewModel.getCurrentObjects(searchText, isFilter: true, isSearch: true)
    }
}


