//
//  CityViewController.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 21/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Charts

class CityViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    @IBOutlet weak var radarChart: RadarChartView!
    @IBOutlet weak var forecastsView: UICollectionView!
    var forecastuples : [(String, NSDate, [Forecast])]?
    
    var viewModel : CityViewModel? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        
        radarChart.noDataText = "Wind data is still up in the air..."
        radarChart.descriptionText = ""
        radarChart.rotationEnabled = false
        radarChart.webLineWidth = 0.6
        radarChart.innerWebLineWidth = 0.0
        radarChart.webAlpha = 1.0
//        radarChart.chartYMax = 17.0
//        radarChart.yAxis.customAxisMax = 17.0
//        let gesture = UITapGestureRecognizer(target: self, action: "clickChart:")
//        radarChart.addGestureRecognizer(gesture)
        
        
        if let vm = viewModel {            
            self.title = vm.city
            // TODO: Configure Chart etc.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        guard let viewModel = self.viewModel else { return }
        viewModel.refreshCity()
        viewModel.current
            .asObservable()
            .subscribeNext({ (value) in
                

 //               self.forecastsView.collectionViewLayout = CurrentDetailLayout()
                
                self.configureView()
            })
            .addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showInfo(sender: AnyObject) {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        if let infoView = NSBundle.mainBundle().loadNibNamed("CurrentInfoView", owner: self, options: nil).first as? CurrentInfoView {
            let margin:CGFloat = 8.0
            infoView.units = Units.Metric
            infoView.frame =  CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4, 400.0)
            alertController.view.addSubview(infoView)
        }
        let cancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion:{})
    }
    
}

extension CityViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard let f = self.forecastuples else { return 0 }
        return f.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let f = self.forecastuples else { return 0 }
        return f[section].2.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ForecastCellIdentifier", forIndexPath: indexPath) as! ForecastCell
        guard let _ = self.viewModel?.current.value else { return cell }
        let t = self.forecastuples![indexPath.section]
        let f = t.2[indexPath.row]
        let speed = String(format: "%.2f", f.wind!.speed)
        let temperature = String(format: "%.1f", f.main!.temp)
        cell.imageAlarmed.hidden = true;
        cell.labelHH.text = f.hour
        cell.labelSpeed.text = "\(speed)"
        cell.labelSpeed.backgroundColor = Units.Metric.getColorOfSpeed(f.wind!.speed)
        cell.labelTemp.text = "\(temperature)°"
        if let direction = f.direction {
            cell.imageDirection.image = UIImage(named:  direction.inverse.rawValue)
        } else {
            cell.imageDirection.image = nil
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        guard let _ = self.viewModel?.current.value else { return UICollectionReusableView() }
        
        var cell : UICollectionReusableView
        switch kind {
        case TitlesCell.kindTableHeader :
            let t = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "LeftTitlesCellIdentifier", forIndexPath: indexPath) as! TitlesCell
            t.speedTitle.text = "Speed, \(Units.Metric.speed)"
            t.temperatureTitle.text = "Temperature, °\(Units.Metric.temperature)"
            cell = t
        case TitlesCell.kindTableFooter :
            let t = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "RightTitlesCellIdentifier", forIndexPath: indexPath) as! TitlesCell
            t.speedTitle.text = "Speed, \(Units.Metric.speed)"
            t.temperatureTitle.text = "Temperature, °\(Units.Metric.temperature)"
            cell = t
        case UICollectionElementKindSectionHeader :
            cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayCellIdentifier", forIndexPath: indexPath)
            let forecastEntry = self.forecastuples?[indexPath.section].2[indexPath.row]
            if let c = cell as? DayCell {
                if let day = forecastEntry?.day {
                    c.text.text = day
                    if let entries = self.forecastuples?[indexPath.section].2 where day == "TODAY" && entries.count < 3 {
                        c.text.text = ""
                    }
                }
            }
        default :
            cell = UICollectionReusableView()
        }
        return cell
    }
}

