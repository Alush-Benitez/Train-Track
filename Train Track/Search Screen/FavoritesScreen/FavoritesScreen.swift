//
//  FavoritesScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/28/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class FavoritesScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var favoriteStationView: UIView!
    @IBOutlet weak var selectedFavoriteLabel: UILabel!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var fourthLineView: UIView!
    @IBOutlet weak var fifthLineView: UIView!
    @IBOutlet weak var sixthLineView: UIView!
    
    @IBOutlet weak var scrollIndicator: UILabel!
    @IBOutlet weak var favoritesTrainTrackerDataCollectionView: UICollectionView!
    
    var lineViews: [UIView] = []
    var selectedFavorite: Int = 0
    
    private let refreshControl = UIRefreshControl()
    
    //Color, colorString, Destination, countdowntime, isApproaching, isScheduled, isDelayed, runNumber
    var trainTrackerData: [[Any]] = []
    var alertStrings: String = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesTrainTrackerDataCollectionView.dataSource = self
        favoritesTrainTrackerDataCollectionView.delegate = self
        favoritesTrainTrackerDataCollectionView.register(UINib.init(nibName: "TrainTrackerCell", bundle: nil), forCellWithReuseIdentifier: "TrainTrackerCell")
        favoritesTrainTrackerDataCollectionView.register(UINib.init(nibName: "AlertCell", bundle: nil), forCellWithReuseIdentifier: "AlertCell")
        
        selectedFavorite = 0
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(FavoritesScreen.leftSwipe))
        left.direction = .left
        self.favoriteStationView.addGestureRecognizer(left)
        self.favoritesTrainTrackerDataCollectionView.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(FavoritesScreen.rightSwipe))
        right.direction = .right
        self.favoriteStationView.addGestureRecognizer(right)
        self.favoritesTrainTrackerDataCollectionView.addGestureRecognizer(right)
        
        lineViews = [firstLineView, secondLineView, thirdLineView, fourthLineView, fifthLineView, sixthLineView]
        
        favoriteStationView.layer.cornerRadius = 7
        selectedFavoriteLabel.text = favoriteStations[selectedFavorite][0] as? String
        
        for lineView in lineViews {
            lineView.backgroundColor = .white
            lineView.layer.cornerRadius = 17
        }
        
        for i in 0..<(favoriteStations[selectedFavorite][2] as? [String])!.count {
            var color: UIColor = .black
            if (favoriteStations[selectedFavorite][2] as! [String])[i] == "red" {
                color = ctaRed
            } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "blue" {
                color = ctaBlue
            } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "brown" {
                color = ctaBrown
            } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "green" {
                color = ctaGreen
            } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "orange" {
                color = ctaOrange
            } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "pink" {
                color = ctaPink
            } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "purple" {
                color = ctaPurple
            } else {
                color = ctaYellow
            }
            
            lineViews[i].backgroundColor = color
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        trainTrackerData = []
        alertStrings = ""
        
        trainTrackerData = (grabTrainTrackerData(mapid: Double(favoriteStations[selectedFavorite][1] as! Int)))
        alertStrings = (grabAlertData(stationid: favoriteStations[selectedFavorite][1] as! Int))
        
        if favoriteStations.count == 0 {
            scrollIndicator.isHidden = true
        } else {
            scrollIndicator.text = String(selectedFavorite + 1) + "/" + String(favoriteStations.count)
            scrollIndicator.isHidden = false
        }
    }
    
    @objc func rightSwipe(){
        if selectedFavorite > 0 {
            selectedFavorite -= 1
            scrollIndicator.text = String(selectedFavorite + 1) + "/" + String(favoriteStations.count)
            UIView.animate(withDuration: 0.7, animations: {
                self.favoritesTrainTrackerDataCollectionView.alpha = 0
                self.favoriteStationView.alpha = 0
            })
            selectedFavoriteLabel.text = favoriteStations[selectedFavorite][0] as? String
            
            for lineView in lineViews {
                lineView.backgroundColor = .white
                lineView.layer.cornerRadius = 17
            }
            
            for i in 0..<(favoriteStations[selectedFavorite][2] as? [String])!.count {
                var color: UIColor = .black
                if (favoriteStations[selectedFavorite][2] as! [String])[i] == "red" {
                    color = ctaRed
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "blue" {
                    color = ctaBlue
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "brown" {
                    color = ctaBrown
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "green" {
                    color = ctaGreen
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "orange" {
                    color = ctaOrange
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "pink" {
                    color = ctaPink
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "purple" {
                    color = ctaPurple
                } else {
                    color = ctaYellow
                }
                
                lineViews[i].backgroundColor = color
            }
            trainTrackerData = (grabTrainTrackerData(mapid: Double(favoriteStations[selectedFavorite][1] as! Int)))
            alertStrings = (grabAlertData(stationid: favoriteStations[selectedFavorite][1] as! Int))
            
            favoritesTrainTrackerDataCollectionView.reloadData()
            
            UIView.animate(withDuration: 0.7, animations: {
                self.favoritesTrainTrackerDataCollectionView.alpha = 1
                self.favoriteStationView.alpha = 1
            })
            
        }
    }
    
    @objc func leftSwipe(){
        if selectedFavorite < favoriteStations.count - 1 {
            selectedFavorite += 1
            scrollIndicator.text = String(selectedFavorite + 1) + "/" + String(favoriteStations.count)
            UIView.animate(withDuration: 0.7, animations: {
                self.favoritesTrainTrackerDataCollectionView.alpha = 0
                self.favoriteStationView.alpha = 0
            })
            selectedFavoriteLabel.text = favoriteStations[selectedFavorite][0] as? String
            
            for lineView in lineViews {
                lineView.backgroundColor = .white
                lineView.layer.cornerRadius = 17
            }
            
            for i in 0..<(favoriteStations[selectedFavorite][2] as? [String])!.count {
                var color: UIColor = .black
                if (favoriteStations[selectedFavorite][2] as! [String])[i] == "red" {
                    color = ctaRed
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "blue" {
                    color = ctaBlue
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "brown" {
                    color = ctaBrown
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "green" {
                    color = ctaGreen
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "orange" {
                    color = ctaOrange
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "pink" {
                    color = ctaPink
                } else if (favoriteStations[selectedFavorite][2] as! [String])[i] == "purple" {
                    color = ctaPurple
                } else {
                    color = ctaYellow
                }
                
                lineViews[i].backgroundColor = color
            }
            trainTrackerData = (grabTrainTrackerData(mapid: Double(favoriteStations[selectedFavorite][1] as! Int)))
            alertStrings = (grabAlertData(stationid: favoriteStations[selectedFavorite][1] as! Int))
            
            favoritesTrainTrackerDataCollectionView.reloadData()
            
            UIView.animate(withDuration: 0.7, animations: {
                self.favoritesTrainTrackerDataCollectionView.alpha = 1
                self.favoriteStationView.alpha = 1
            })
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trainTrackerData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            //Alert Cell
            let firstCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlertCell", for: indexPath) as! AlertCell
            firstCell.layer.cornerRadius = 7
            firstCell.descriptionLabel.text = alertStrings
            firstCell.layer.shadowColor = UIColor.gray.cgColor
            firstCell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
            firstCell.layer.shadowRadius = 1.2
            firstCell.layer.shadowOpacity = 1.0
            firstCell.layer.masksToBounds = false
            firstCell.layer.shadowPath = UIBezierPath(roundedRect:firstCell.bounds, cornerRadius: 7).cgPath
            if alertStrings != "Normal Service" {
                firstCell.statusIcon.image = UIImage(named: "warning-icon")
            } else {
                firstCell.statusIcon.image = UIImage(named: "greencheck")
            }
            
            return firstCell
            
        } else {
            //TrainTracker Cell
            let dataCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrainTrackerCell", for: indexPath) as! TrainTrackerCell
            //Destination
            if trainTrackerData[indexPath.row - 1][2] as? String == favoriteStations[collectionView.tag][0] as? String {
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
        if indexPath.row == 0 {
            let alert = StatusAlertView(stationid: favoriteStations[selectedFavorite][1] as! Int)
            alert.show(animated: true)
        } else {
            let alert = FollowTrainAlertView(runNumber: trainTrackerData[indexPath.row-1][7] as! Int, color: trainTrackerData[indexPath.row-1][0] as! UIColor, destination: trainTrackerData[indexPath.row-1][2] as! String, colorString: trainTrackerData[indexPath.row-1][1] as! String)
            alert.show(animated: true)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        <#code#>
//    }

}
