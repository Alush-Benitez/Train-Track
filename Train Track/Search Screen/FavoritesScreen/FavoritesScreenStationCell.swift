//
//  FavoritesScreenStationCell.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/28/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class FavoritesScreenStationCell: UICollectionViewCell  {
    
    
    @IBOutlet weak var stationView: UIView!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var fourthLineView: UIView!
    @IBOutlet weak var fifthLineView: UIView!
    @IBOutlet weak var sixthLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    func setTableViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
//        stationInfoCollectionView.delegate = dataSourceDelegate
//        stationInfoCollectionView.dataSource = dataSourceDelegate
//        stationInfoCollectionView.tag = row
//        stationInfoCollectionView.register(UINib.init(nibName: "TrainTrackerCell", bundle: nil), forCellWithReuseIdentifier: "TrainTrackerCell")
//        stationInfoCollectionView.register(UINib.init(nibName: "AlertCell", bundle: nil), forCellWithReuseIdentifier: "AlertCell")
//        stationInfoCollectionView.reloadData()
//    }
}
