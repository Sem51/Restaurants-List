//
//  RestaurantCustomTableViewCell.swift
//  Restaraunts
//
//  Created by Семен Осипов on 10.11.16.
//  Copyright © 2016 Семен Осипов. All rights reserved.
//

import UIKit

class RestaurantCustomTableViewCell: UITableViewCell {

    @IBOutlet var fieldLabel: UILabel!
    @IBOutlet var valueLabel: UILabel! 
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
