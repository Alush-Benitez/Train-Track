//
//  FavoritesScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/28/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class FavoritesScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    var lineViews: [UIView] = []
    
    private let refreshControl = UIRefreshControl()
    
    //Color, colorString, Destination, countdowntime, isApproaching, isScheduled, isDelayed, runNumber
    var trainTrackerData: [[[Any]]] = []
    var alertStrings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.decelerationRate = .fast
        for station in favoriteStations {
            trainTrackerData.append(grabTrainTrackerData(mapid: Double(station[1] as! Int)))
            alertStrings.append(grabAlertData(stationid: station[1] as! Int))
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == favoritesCollectionView {
            return favoriteStations.count
        } else {
            return trainTrackerData[collectionView.tag].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == favoritesCollectionView {
            let cell = favoritesCollectionView.dequeueReusableCell(withReuseIdentifier: "FavoritesScreenStationCell", for: indexPath) as! FavoritesScreenStationCell
            cell.stationLabel.text = favoriteStations[indexPath.row][0] as? String
            lineViews = [cell.firstLineView, cell.secondLineView, cell.thirdLineView, cell.fourthLineView, cell.fifthLineView, cell.sixthLineView]
            cell.stationView.layer.cornerRadius = 7
            
            for lineView in lineViews {
                lineView.backgroundColor = .white
                lineView.layer.cornerRadius = 17
            }
            
            for i in 0..<(favoriteStations[indexPath.row][2] as? [UIColor])!.count {
                lineViews[i].backgroundColor = (favoriteStations[indexPath.row][2] as? [UIColor])![i]
            }
            
            cell.setTableViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            
            return cell
        } else {
            if indexPath.row == 0 {
                //Alert Cell
                let firstCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlertCell", for: indexPath) as! AlertCell
                firstCell.layer.cornerRadius = 7
                firstCell.descriptionLabel.text = alertStrings[collectionView.tag] as? String
                firstCell.layer.shadowColor = UIColor.gray.cgColor
                firstCell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
                firstCell.layer.shadowRadius = 1.2
                firstCell.layer.shadowOpacity = 1.0
                firstCell.layer.masksToBounds = false
                firstCell.layer.shadowPath = UIBezierPath(roundedRect:firstCell.bounds, cornerRadius: 7).cgPath
                if alertStrings[collectionView.tag] as? String != "Normal Service" {
                    firstCell.statusIcon.image = UIImage(named: "warning-icon")
                } else {
                    firstCell.statusIcon.image = UIImage(named: "greencheck")
                }
                
                return firstCell
                
            } else {
                //TrainTracker Cell
                let dataCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrainTrackerCell", for: indexPath) as! TrainTrackerCell
                //Destination
                if trainTrackerData[collectionView.tag][indexPath.row - 1][2] as? String == favoriteStations[collectionView.tag][0] as? String {
                    dataCell.destinationLabel.text = "Terminal Arrival"
                    dataCell.runInfoLabel.text = (trainTrackerData[collectionView.tag][indexPath.row - 1][1] as? String)! + " Line Run #" + String(trainTrackerData[collectionView.tag][indexPath.row - 1][7] as! Int)
                } else if trainTrackerData[collectionView.tag][indexPath.row - 1][2] as? String == "Loop" {
                    dataCell.destinationLabel.text = "The Loop"
                    dataCell.runInfoLabel.text = (trainTrackerData[collectionView.tag][indexPath.row - 1][1] as? String)! + " Line Run #" + String(trainTrackerData[collectionView.tag][indexPath.row - 1][7] as! Int) + " to"
                } else {
                    dataCell.destinationLabel.text = trainTrackerData[collectionView.tag][indexPath.row - 1][2] as? String
                    dataCell.runInfoLabel.text = (trainTrackerData[collectionView.tag][indexPath.row - 1][1] as? String)! + " Line Run #" + String(trainTrackerData[collectionView.tag][indexPath.row - 1][7] as! Int) + " to"
                }
                
                //Time
                if trainTrackerData[collectionView.tag][indexPath.row - 1][4] as! Bool{
                    dataCell.timeLabel.text = "Due"
                } else if trainTrackerData[collectionView.tag][indexPath.row - 1][6] as! Bool{
                    dataCell.timeLabel.text = "Delayed"
                } else {
                    dataCell.timeLabel.text = (trainTrackerData[collectionView.tag][indexPath.row - 1][3] as? String)! + " min"
                }
                
                dataCell.backgroundColor = trainTrackerData[collectionView.tag][indexPath.row - 1][0] as? UIColor
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
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        <#code#>
//    }
    
    
    //******************
    //SNAP FOR SCROLLING
    //******************
    private var startingScrollingOffset = CGPoint.zero
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startingScrollingOffset = scrollView.contentOffset // 1
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // [...]
        let cellWidth = 407
        let page: CGFloat
        let offset = scrollView.contentOffset.x + scrollView.contentInset.left // 2
        let proposedPage = offset / CGFloat(max(1, cellWidth))
        let snapPoint: CGFloat = 0.1
        let snapDelta: CGFloat = offset > startingScrollingOffset.x ? (1 - snapPoint) : snapPoint
        
        if floor(proposedPage + snapDelta) == floor(proposedPage) { // 3
            page = floor(proposedPage) // 4
        }
        else {
            page = floor(proposedPage + 1) // 5
        }
        
        targetContentOffset.pointee = CGPoint(
            x: CGFloat(cellWidth) * page,
            y: targetContentOffset.pointee.y
        )
    }

    
}
