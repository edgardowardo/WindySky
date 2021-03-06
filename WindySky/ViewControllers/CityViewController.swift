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
import RxCocoa
import RealmSwift
import Charts

class CityViewController: UIViewController {
    
    var viewModel : CityViewModel!
    @IBOutlet weak var radarChart: RadarChartView!
    @IBOutlet weak var forecastsView: UICollectionView!
    private var star : UIButton!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = self.viewModel else { return }
        viewModel.refreshCity()
        viewModel.current
            .asObservable()
            .subscribeNext({ (value) in
                if let _ = value {
                    self.title = viewModel.title
                    self.updateChart(withDirection: viewModel.direction, andSpeed: viewModel.speed, andSpeedName: viewModel.speedName, andSince: viewModel.since)
                    self.forecastsView.reloadData()
                    self.radarChart.yAxis.customAxisMax = Units.Metric.maxSpeed
                }
            })
            .addDisposableTo(disposeBag)
        
        radarChart.noDataText = viewModel.chartNoDataText
        radarChart.descriptionText = ""
        radarChart.rotationEnabled = false
        radarChart.webLineWidth = 0.6
        radarChart.innerWebLineWidth = 0.0
        radarChart.webAlpha = 1.0
        radarChart.yAxis.customAxisMax = 17.0

        forecastsView.dataSource = self
        forecastsView.registerNib(UINib(nibName: "ForecastCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "LeftTitlesCell", bundle: nil), forSupplementaryViewOfKind: TitlesCell.kindTableHeader, withReuseIdentifier: "LeftTitlesCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "RightTitlesCell", bundle: nil), forSupplementaryViewOfKind: TitlesCell.kindTableFooter, withReuseIdentifier: "RightTitlesCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "DayCell", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "DayCellIdentifier")
        forecastsView.contentInset = UIEdgeInsets(top: 0, left: -TitlesCell.size.width, bottom: 0, right: -TitlesCell.size.width)
        
        let imageNormal = UIImage(named: viewModel.iconUnfavourite)!
        let imageSelected = UIImage(named: viewModel.iconFavourite)
        star = UIButton(type: .Custom)
        star.bounds = CGRectMake(0, 0, imageNormal.size.width, imageNormal.size.height)
        star.setImage(imageNormal, forState: .Normal)
        star.setImage(imageSelected, forState: .Selected)

        star.rx_tap
            .asObservable()
            .subscribeNext { (n) in
                viewModel.toggleFavourite()
            }.addDisposableTo(disposeBag)
        
        viewModel.isFavourite
            .asObservable()
            .bindTo(star.rx_selected)
            .addDisposableTo(disposeBag)

        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: star)], animated: true)
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
    
    func updateChart(withDirection direction: Direction?, andSpeed speed : Double, andSpeedName speedname : String, andSince since : String ) {
        var speeds = direction?.directionsWithspeed(speed)
        if speeds == nil {
            speeds = Array<Double>.init(count: 16, repeatedValue: 0.0)
        }
        setChart(viewModel.directions, values: speeds!, andDirection: direction, andSpeed: speed, andSpeedName: speedname, andSince: since)
    }
    
    func setChart(dataPoints: [String], values: [Double], andDirection direction: Direction?, andSpeed speed : Double, andSpeedName speedname : String, andSince since : String) {
        
        guard let _ = self.viewModel?.current else { return }
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0 ..< dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let speedText = String(format: "%.2f", speed)
        let speedname = ( speedname == "" ) ? "Windless" : speedname
        let directionname = ( direction == nil ) ? "nowhere" : direction!.name.lowercaseString
        let speedUnit = Units.Metric.speed
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: "\(speedname) wind from \(directionname) at \(speedText) \(speedUnit) \(since)")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false
        let speedColor = Units.Metric.getColorOfSpeed(speed)
        chartDataSet.fillColor = speedColor
        chartDataSet.setColor(speedColor, alpha: 0.6)
        let chartData = RadarChartData(xVals: viewModel.directions, dataSets: [chartDataSet])
        
        radarChart.data = chartData
        radarChart.animate(yAxisDuration: NSTimeInterval(1.4), easingOption: ChartEasingOption.EaseOutBack)
    }
    
}

extension CityViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard let f = viewModel.forecastuples else { return 0 }
        return f.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let f = viewModel.forecastuples else { return 0 }
        return f[section].2.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ForecastCellIdentifier", forIndexPath: indexPath) as! ForecastCell
        guard let _ = self.viewModel?.current.value else { return cell }
        let t = viewModel.forecastuples![indexPath.section]
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
            let forecastEntry = viewModel.forecastuples?[indexPath.section].2[indexPath.row]
            if let c = cell as? DayCell {
                if let day = forecastEntry?.day {
                    c.text.text = day
                    if let entries = viewModel.forecastuples?[indexPath.section].2 where day == "TODAY" && entries.count < 3 {
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

