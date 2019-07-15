//
//  SearchResultsScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/11/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class SearchResultsScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var accessableIcon: UIImageView!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var dataCollectionView: UICollectionView!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var fourthLineView: UIView!
    @IBOutlet weak var fifthLineView: UIView!
    @IBOutlet weak var sixthLineView: UIView!
    
    var stationName = ""
    var stationColors: [UIColor] = []
    var mapId = 0
    var lineViews: [UIView] = []
    
    var trainTrackerData: [[Any]] = []
    var alertString = ""
    private let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        lineViews = [firstLineView, secondLineView, thirdLineView, fourthLineView, fifthLineView, sixthLineView]
        stationNameLabel.text = stationName
        for view in lineViews {
            view.backgroundColor = .white
            view.layer.cornerRadius = 15
        }
        for i in 0..<stationColors.count {
            lineViews[i].backgroundColor = stationColors[i]
        }
        dataCollectionView.delegate = self
        dataCollectionView.dataSource = self
        dataCollectionView.register(UINib.init(nibName: "TrainTrackerCell", bundle: nil), forCellWithReuseIdentifier: "TrainTrackerCell")
        dataCollectionView.register(UINib.init(nibName: "NearbyStationCell", bundle: nil), forCellWithReuseIdentifier: "NearbyStationCell")
        dataCollectionView.register(UINib.init(nibName: "AlertCell", bundle: nil), forCellWithReuseIdentifier: "AlertCell")
        trainTrackerData = grabTrainTrackerData(mapid: Double(mapId))
        alertString = grabAlertData(stationid: mapId)
        dataCollectionView.reloadData()
        
        //Refresh
        if #available(iOS 10.0, *) {
            dataCollectionView.refreshControl = refreshControl
        } else {
            dataCollectionView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadTrainTrackerData(_:)), for: .valueChanged)
    }
    
    @objc private func reloadTrainTrackerData(_ sender: Any) {
        trainTrackerData = grabTrainTrackerData(mapid: Double(mapId))
        alertString = grabAlertData(stationid: mapId)
        dataCollectionView.reloadData()
        let delay = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: delay){
            self.dataCollectionView.refreshControl!.endRefreshing()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trainTrackerData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let firstCell = dataCollectionView.dequeueReusableCell(withReuseIdentifier: "AlertCell", for: indexPath) as! AlertCell
            firstCell.layer.cornerRadius = 7
            firstCell.descriptionLabel.text = alertString
            firstCell.layer.shadowColor = UIColor.gray.cgColor
            firstCell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
            firstCell.layer.shadowRadius = 1.2
            firstCell.layer.shadowOpacity = 1.0
            firstCell.layer.masksToBounds = false
            firstCell.layer.shadowPath = UIBezierPath(roundedRect:firstCell.bounds, cornerRadius: 7).cgPath
            if alertString != "Normal Service" {
                firstCell.statusIcon.image = UIImage(named: "warning-icon")
            } else {
                firstCell.statusIcon.image = UIImage(named: "greencheck")
            }
            return firstCell
        } else {
            //TrainTracker Cell
            let dataCell = dataCollectionView.dequeueReusableCell(withReuseIdentifier: "TrainTrackerCell", for: indexPath) as! TrainTrackerCell
            //Destination
            if trainTrackerData[indexPath.row - 1][2] as? String == stationNameLabel.text! {
                dataCell.destinationLabel.text = "Terminal Arrival"
                dataCell.runInfoLabel.text = (trainTrackerData[indexPath.row - 1][1] as? String)! + " Line Run #" + String(trainTrackerData[indexPath.row - 1][7] as! Int)
            } else if trainTrackerData[indexPath.row - 1][2] as? String == "Loop" {
                dataCell.destinationLabel.text = "The Loop"
                dataCell.runInfoLabel.text = (trainTrackerData[indexPath.row - 1][1] as? String)! + " Line Run #" + String(trainTrackerData[indexPath.row - 1][7] as! Int) + " to"
            } else {
                dataCell.destinationLabel.text = trainTrackerData[indexPath.row - 1][2] as? String
                dataCell.runInfoLabel.text = (trainTrackerData[indexPath.row - 1][1] as? String)! + " Line Run #" + String(trainTrackerData[indexPath.row - 1][7] as! Int) + " to"
            }
            
            //Time
            if trainTrackerData[indexPath.row - 1][4] as! Bool{
                dataCell.timeLabel.text = "Due"
            } else if trainTrackerData[indexPath.row - 1][6] as! Bool{
                dataCell.timeLabel.text = "Delayed"
            } else {
                dataCell.timeLabel.text = (trainTrackerData[indexPath.row - 1][3] as? String)! + " min"
            }
            
            dataCell.backgroundColor = trainTrackerData[indexPath.row - 1][0] as? UIColor
            dataCell.layer.cornerRadius = 7
            
            dataCell.layer.shadowColor = UIColor.gray.cgColor
            dataCell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
            dataCell.layer.shadowRadius = 1.2
            dataCell.layer.shadowOpacity = 1.0
            dataCell.layer.masksToBounds = false
            dataCell.layer.shadowPath = UIBezierPath(roundedRect:dataCell.bounds, cornerRadius: 7).cgPath
            
            return dataCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let alert = FollowTrainAlertView(runNumber: trainTrackerData[indexPath.row-1][7] as! Int, color: trainTrackerData[indexPath.row-1][0] as! UIColor, destination: trainTrackerData[indexPath.row-1][2] as! String, colorString: trainTrackerData[indexPath.row-1][1] as! String)
            alert.show(animated: true)
        } else {
            let alert = StatusAlertView(stationid: mapId)
            alert.show(animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.dataCollectionView.frame.width - 40, height: 75)
    }

}
