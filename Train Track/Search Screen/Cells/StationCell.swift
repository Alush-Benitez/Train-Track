//
//  StationCell.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/8/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class StationCell: UICollectionViewCell {
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var fourthLineView: UIView!
    @IBOutlet weak var fifthLineView: UIView!
    @IBOutlet weak var sixthLineView: UIView!
    
    var lineViews: [UIView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineViews = [firstLineView, secondLineView, thirdLineView, fourthLineView, fifthLineView, sixthLineView]
        // Initialization code
    }
    
}
