//
//  CurrentInfoView.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 22/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit

class DayCell : UICollectionReusableView {
    static let size = CGSizeMake(110, 150)
    @IBOutlet weak var text: UILabel!
}

class TitlesCell : UICollectionReusableView {
    static let kindTableHeader = "TableHeaderKind"
    static let kindTableFooter = "TableFooterKind"
    static let size = CGSizeMake(110, 150)
    @IBOutlet weak var speedTitle: UILabel!
    @IBOutlet weak var temperatureTitle: UILabel!
}

class ForecastCell : UICollectionViewCell {
    static let size = CGSizeMake(35, 150)
    static let kind = "ForecastCellKind"
    @IBOutlet weak var labelHH: UILabel!
    @IBOutlet weak var imageDirection: UIImageView!
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var imageAlarmed: UIImageView!
}

class CurrentInfoView : UIView {
    @IBOutlet weak var legend1: UIView!
    @IBOutlet weak var legend2: UIView!
    @IBOutlet weak var legend3: UIView!
    @IBOutlet weak var legend4: UIView!
    @IBOutlet weak var legend1Text: UILabel!
    @IBOutlet weak var legend2Text: UILabel!
    @IBOutlet weak var legend3Text: UILabel!
    @IBOutlet weak var legend4Text: UILabel!
    
    var units : Units? {
        didSet {
            if let u = units {
                legend1Text.text = u.getLegendOfSpeed(.Gentle)
                legend2Text.text = u.getLegendOfSpeed(.Moderate)
                legend3Text.text = u.getLegendOfSpeed(.Fresh)
                legend4Text.text = u.getLegendOfSpeed(.Strong)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let unit = Units(rawValue: "Metric")!
        legend1.layer.cornerRadius = legend1.frame.size.width / 2
        legend2.layer.cornerRadius = legend1.frame.size.width / 2
        legend3.layer.cornerRadius = legend1.frame.size.width / 2
        legend4.layer.cornerRadius = legend1.frame.size.width / 2
        legend1.backgroundColor = unit.getColorOfSpeed(0.0)
        legend2.backgroundColor = unit.getColorOfSpeed(7.0)
        legend3.backgroundColor = unit.getColorOfSpeed(10.0)
        legend4.backgroundColor = unit.getColorOfSpeed(16.0)
    }
}
