//
//  SystemAlertCollectionViewCell.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/1/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class SystemAlertCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
