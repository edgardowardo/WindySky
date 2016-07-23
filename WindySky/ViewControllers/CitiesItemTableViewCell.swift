//
//  CitiesItemTableViewCell.swift
//  WindySky
//
//  Created by EDGARDO AGNO on 23/07/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit

class CitiesItemTableViewCell : UITableViewCell {
    
    var viewModel : CitiesItemViewModel? {
        didSet {
            self.layoutCell()
        }
    }
    
    private func layoutCell() {
        if let viewModel = self.viewModel {
            self.textLabel!.text = viewModel.mainText
            self.detailTextLabel?.text = viewModel.detailText
            self.imageView?.image = UIImage(named: viewModel.iconName)
        }
    }
}
