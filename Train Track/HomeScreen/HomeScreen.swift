//
//  FirstViewController.swift
//  Chi Transit
//
//  Created by Alush Benitez on 5/29/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit
import CoreLocation

class HomeScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate{
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var dataCollectionView: UICollectionView!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var fourthLineView: UIView!
    @IBOutlet weak var fifthLineView: UIView!
    @IBOutlet weak var sixthLineView: UIView!
    @IBOutlet weak var accessableIcon: UIImageView!
    @IBOutlet weak var nearbyButton: UIButton!
    @IBOutlet weak var elevatorAlertIcon: UIImageView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var lineViews: [UIView] = []
    var loaded = false
    var firstLoad = true
    var nearbyPressed = false
    var selectedIndex = 0
    
    
    
    private let refreshControl = UIRefreshControl()
    
    
    //mapID, Distance, name, colors, accessable
    //Ordered closest to furthest
    var nearbyStationsData: [[Any]] = [[-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false]]
    var trainTrackerData: [[Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dataCollectionView.delegate = self
        dataCollectionView.dataSource = self
        nearbyButton.layer.cornerRadius = 7
        nearbyButton.layer.borderWidth = 2
        nearbyButton.layer.borderColor = notBlack.cgColor
        
        locationManager.requestWhenInUseAuthorization()
        
        lineViews = [firstLineView, secondLineView, thirdLineView, fourthLineView, fifthLineView, sixthLineView]
        
        for view in lineViews {
            view.layer.cornerRadius = 15
        }

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        if #available(iOS 10.0, *) {
            dataCollectionView.refreshControl = refreshControl
        } else {
            dataCollectionView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadTrainTrackerData(_:)), for: .valueChanged)
       // refreshControl.attributedTitle = NSAttributedString(string: "Reloading Train Tracker Data...")
    }
    
    @objc private func reloadTrainTrackerData(_ sender: Any) {
        if nearbyPressed {
            loaded = false
            
            locationManager.startUpdatingLocation()
        } else {
            grabTrainTrackerData(mapid: nearbyStationsData[selectedIndex][0] as! Double)
        }
        dataCollectionView.reloadData()
        let delay = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: delay){
            self.dataCollectionView.refreshControl!.endRefreshing()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            currentLocation = location
            if !loaded {
                grabClosestStations()
                if firstLoad {
                    grabTrainTrackerData(mapid: nearbyStationsData[0][0] as! Double)
                    firstLoad = false
                    
                }
                dataCollectionView.reloadData()
                loaded = true
            }
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    //***********************
    //PARSE STATION INFO DATA
    //***********************
    
    func grabClosestStations() {
        let query = "https://data.cityofchicago.org/resource/8mj8-j3c4.json"
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseClosestStations(json: json)
            }
        }
    }
    
    func parseClosestStations(json: JSON?){
        var stationCoordinate: CLLocation
        var testedCoordinates: [[Double]] = [[0,0]]
        var tested = false
        let userCoordinate = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        nearbyStationsData = [[-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false]]
        
        //Find Closest Station Data
        for result in json![].arrayValue {
            stationCoordinate = CLLocation(latitude: result["location"]["coordinates"][1].doubleValue, longitude: result["location"]["coordinates"][0].doubleValue)
            for coordinate in testedCoordinates {
                if result["location"]["coordinates"][1].doubleValue == coordinate[0] && result["location"]["coordinates"][0].doubleValue == coordinate[1]{
                    tested = true
                }
            }
            
            //Getting mapID, Distance, name, colors
            
            if !tested {
                testedCoordinates.append([result["location"]["coordinates"][1].doubleValue, result["location"]["coordinates"][0].doubleValue])
                let distanceInMeters = stationCoordinate.distance(from: userCoordinate)
                if distanceInMeters < nearbyStationsData[0][1] as! Double || nearbyStationsData[0][1] as! Double == -1 {
                    //Closer than closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    nearbyStationsData[3] = nearbyStationsData[2]
                    nearbyStationsData[2] = nearbyStationsData[1]
                    nearbyStationsData[1] = nearbyStationsData[0]
                    
                    
                    nearbyStationsData[0][0] = result["map_id"].doubleValue
                    nearbyStationsData[0][1] = distanceInMeters
                    nearbyStationsData[0][2] = result["station_name"].stringValue
                    nearbyStationsData[0][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[1][1] as! Double || nearbyStationsData[1][1] as! Double == -1 {
                    //Closer than second closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    nearbyStationsData[3] = nearbyStationsData[2]
                    nearbyStationsData[2] = nearbyStationsData[1]
                    
                    nearbyStationsData[1][0] = result["map_id"].doubleValue
                    nearbyStationsData[1][1] = distanceInMeters
                    nearbyStationsData[1][2] = result["station_name"].stringValue
                    nearbyStationsData[1][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[2][1] as! Double || nearbyStationsData[2][1] as! Double == -1 {
                    //closer than third closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    nearbyStationsData[3] = nearbyStationsData[2]
                    
                    nearbyStationsData[2][0] = result["map_id"].doubleValue
                    nearbyStationsData[2][1] = distanceInMeters
                    nearbyStationsData[2][2] = result["station_name"].stringValue
                    nearbyStationsData[2][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[3][1] as! Double || nearbyStationsData[3][1] as! Double == -1{
                    //closer than fourth closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    
                    nearbyStationsData[3][0] = result["map_id"].doubleValue
                    nearbyStationsData[3][1] = distanceInMeters
                    nearbyStationsData[3][2] = result["station_name"].stringValue
                    nearbyStationsData[3][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[4][1] as! Double || nearbyStationsData[4][1] as! Double == -1{
                    //closer than fifth closest
                    nearbyStationsData[4][0] = result["map_id"].doubleValue
                    nearbyStationsData[4][1] = distanceInMeters
                    nearbyStationsData[4][2] = result["station_name"].stringValue
                    nearbyStationsData[4][4] = result["ada"].boolValue
                }
            }
            tested = false
        }
        
        
        
        tested = false
        var testedIds: [Int] = []
        
        //Get colors from determined closest stations

        var lines = [UIColor]()
        
        var flag = false
        
        for i in 0..<nearbyStationsData.count {
            for result in json![].arrayValue {
                if result["map_id"].doubleValue == nearbyStationsData[i][0] as! Double && result["station_name"] != "Wilson" {
                    flag = true
                    //set lines
                    if result["red"].boolValue && !lines.contains(ctaRed) {
                        lines.append(ctaRed)
                        
                    }
                    if result["blue"].boolValue && !lines.contains(ctaBlue) {
                        lines.append(ctaBlue)
                    }
                    if result["g"].boolValue && !lines.contains(ctaGreen) {
                        lines.append(ctaGreen)
                    }
                    if result["brn"].boolValue && !lines.contains(ctaBrown) {
                        lines.append(ctaBrown)
                    }
                    if result["pnk"].boolValue && !lines.contains(ctaPink) {
                        lines.append(ctaPink)
                    }
                    if result["o"].boolValue && !lines.contains(ctaOrange) {
                        lines.append(ctaOrange)
                    }
                    if ((result["p"].boolValue || result["pexp"].boolValue) && !lines.contains(ctaPurple))  {
                        lines.append(ctaPurple)
                    }
                    if result["y"].boolValue && !lines.contains(ctaYellow) {
                        lines.append(ctaYellow)
                    }
                } else if flag || result["station_name"] == "Wilson" {
                    
                    if result["station_name"] == "Wilson" {
                        lines.append(ctaRed)
                        lines.append(ctaPurple)
                        
                    }
                    
                    nearbyStationsData[i][3] = lines
                    if i == 0 {
                        //Set main color things if closest
                        for w in 0..<lines.count {
                            lineViews[w].backgroundColor = lines[w]
                        }
                    }
                    lines = []
                    flag = false
                    
                    break;
                }
            }
        }
        
        for result in json![].arrayValue {
            for id in testedIds {
                if result["map_id"].intValue == id {
                    tested = true
                }
            }
            
            if !tested {
                testedIds.append(result["map_id"].intValue)
                if result["map_id"].doubleValue == nearbyStationsData[0][0] as! Double && firstLoad {
                    stationNameLabel.text = result["station_name"].stringValue
                    accessableIcon.isHidden = !result["ada"].boolValue
                }
            }
            tested = false
        }
        
        print(nearbyStationsData[0])
        
    }
    
    
    
    //************************
    //PARSE TRAIN TRACKER DATA
    //************************
    
    func grabTrainTrackerData(mapid: Double) {
        let query = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=167e3f6b5d0646889964748acf3bcc58&mapid=" + String(Int(mapid)) + "&outputType=JSON"
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseTrainTrackerData(json: json)
            }
        }
    }
    
    func parseTrainTrackerData(json: JSON?){
        trainTrackerData = []
        
        for result in json!["ctatt"]["eta"].arrayValue {
            
            //Color, colorString, Destination, countdowntime, isApproaching, isScheduled, isDelayed, runNumber
            var info: [Any] = []
            
            //Colorz
            if result["rt"].stringValue == "Red" {
                info.append(ctaRed)
                info.append("Red")
            } else if result["rt"].stringValue == "Blue" {
                info.append(ctaBlue)
                info.append("Blue")
            } else if result["rt"].stringValue == "Brn" {
                info.append(ctaBrown)
                info.append("Brown")
            } else if result["rt"].stringValue == "G" {
                info.append(ctaGreen)
                info.append("Green")
            } else if result["rt"].stringValue == "Org" {
                info.append(ctaOrange)
                info.append("Orange")
            } else if result["rt"].stringValue == "P" {
                info.append(ctaPurple)
                info.append("Purple")
            } else if result["rt"].stringValue == "Pink" {
                info.append(ctaPink)
                info.append("Pink")
            } else {
                info.append(ctaYellow)
                info.append("Yellow")
            }
            
            //Destination
            if result["destNm"].stringValue == "Skokie" {
                info.append("Dempster-Skokie")
            } else {
                info.append(result["destNm"].stringValue)
            }
            
            //time
            var index = result["arrT"].stringValue.index(result["arrT"].stringValue.startIndex, offsetBy: 14)
            var index2 = result["arrT"].stringValue.index(result["arrT"].stringValue.startIndex, offsetBy: 15)
            let arrivalMin = Int(String(result["arrT"].stringValue[index...index2]))!
            let predictionMin = Int(String(result["prdt"].stringValue[index...index2]))!
            index = result["arrT"].stringValue.index(result["arrT"].stringValue.startIndex, offsetBy: 11)
            index2 = result["arrT"].stringValue.index(result["arrT"].stringValue.startIndex, offsetBy: 12)
            let arrivalHour = Int(String(result["arrT"].stringValue[index...index2]))!
            let predictionHour = Int(String(result["prdt"].stringValue[index...index2]))!
            
            if arrivalHour == predictionHour {
                info.append(String(arrivalMin - predictionMin))
            } else {
                info.append(String((60 - predictionMin) + arrivalMin))
            }
            
            //bools
            info.append(result["isApp"].boolValue)
            info.append(result["isSch"].boolValue)
            info.append(result["isDly"].boolValue)
            
            //run number
            info.append(result["rn"].intValue)
            
            trainTrackerData.append(info)
            
        }
    }
    
    
    
    
    
    
    
    //**********************
    //SET UP COLLECTION VIEW
    //**********************

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !nearbyPressed {
            return trainTrackerData.count
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nearbyDataCell = collectionView.dequeueReusableCell(withReuseIdentifier: "nearbyDataCell", for: indexPath as IndexPath) as! NearbyDataCollectionViewCell
        nearbyDataCell.layer.cornerRadius = 7
        
        var nearbyLineViews = [nearbyDataCell.firstLineView, nearbyDataCell.secondLineView, nearbyDataCell.thirdLineView, nearbyDataCell.fourthLineView, nearbyDataCell.fifthLineView, nearbyDataCell.sixthLineView]
        
        for view in nearbyLineViews {
            view?.backgroundColor = .white
        }
       
        
        if !nearbyPressed {
            for view in nearbyLineViews {
                view?.isHidden = true
            }
            nearbyDataCell.layer.shadowColor = UIColor.white.cgColor
            nearbyDataCell.nearbyStationLabel.isHidden = true
            nearbyDataCell.destinationLabel.isHidden = false
            nearbyDataCell.runInfoLabel.isHidden = false
            nearbyDataCell.timeLabel.textColor = .white
            
            nearbyDataCell.destinationLabel.isHidden = false
            nearbyDataCell.timeLabel.isHidden = false
            
            //Train Tracker data
            if trainTrackerData[indexPath.row][4] as! Bool{
                nearbyDataCell.timeLabel.text = "Due"
            } else if trainTrackerData[indexPath.row][6] as! Bool{
                nearbyDataCell.timeLabel.text = "Delayed"
            } else {
                nearbyDataCell.timeLabel.text = (trainTrackerData[indexPath.row][3] as? String)! + " min"
            }
            
            if trainTrackerData[indexPath.row][2] as? String == stationNameLabel.text! {
                nearbyDataCell.destinationLabel.text = "Terminal Arrival"
            } else {
                nearbyDataCell.destinationLabel.text = (trainTrackerData[indexPath.row][2] as? String)!
            }
            
            nearbyDataCell.runInfoLabel.text = (trainTrackerData[indexPath.row][1] as? String)! + " Line Run # " + String(trainTrackerData[indexPath.row][7] as! Int) + " to"
            nearbyDataCell.backgroundColor = trainTrackerData[indexPath.row][0] as? UIColor
            
            
            
        } else {
            
            //Shadow
            nearbyDataCell.layer.shadowColor = UIColor.gray.cgColor
            nearbyDataCell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            nearbyDataCell.layer.shadowRadius = 2.0
            nearbyDataCell.layer.shadowOpacity = 1.0
            nearbyDataCell.layer.masksToBounds = false
            nearbyDataCell.layer.shadowPath = UIBezierPath(roundedRect:nearbyDataCell.bounds, cornerRadius: nearbyDataCell.contentView.layer.cornerRadius).cgPath
            
            
            nearbyDataCell.timeLabel.text = truncateDigitsAfterDecimal(number:((nearbyStationsData[indexPath.row][1] as! Double) / 1609.344), afterDecimalDigits: 2) + " mi"
            nearbyDataCell.backgroundColor = .white
            nearbyDataCell.destinationLabel.isHidden = true
            nearbyDataCell.runInfoLabel.isHidden = true
            nearbyDataCell.timeLabel.textColor = notBlack
            
            nearbyDataCell.nearbyStationLabel.isHidden = false
            nearbyDataCell.nearbyStationLabel.text = nearbyStationsData[indexPath.row][2] as? String
            
            
            
            for view in nearbyLineViews {
                view?.isHidden = false
                view?.layer.cornerRadius = 12
            }
            
            var count = 0
            for color in nearbyStationsData[indexPath.row][3] as! [UIColor] {
                nearbyLineViews[count]?.backgroundColor = color
                count += 1
            }
        }
        
        return nearbyDataCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if nearbyPressed {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
            nearbyPressed = false;
            fixHomeScreen(nearbyPresseed: nearbyPressed)
            stationNameLabel.text = nearbyStationsData[indexPath.row][2] as? String
            accessableIcon.isHidden = !(nearbyStationsData[indexPath.row][4] as? Bool)!
            
            for w in 0..<(nearbyStationsData[indexPath.row][3] as! [UIColor]).count {
                lineViews[w].backgroundColor = (nearbyStationsData[indexPath.row][3]as! [UIColor])[w]
            }
            
            selectedIndex = indexPath.row
            
            grabTrainTrackerData(mapid: nearbyStationsData[indexPath.row][0] as! Double)
            
            
            dataCollectionView.reloadData()
        } else {
            let alert = FollowTrainAlertView(runNumber: trainTrackerData[indexPath.row][7] as! Int, color: trainTrackerData[indexPath.row][0] as! UIColor, destination: trainTrackerData[indexPath.row][2] as! String, colorString: trainTrackerData[indexPath.row][1] as! String)
            alert.show(animated: true)
        }
       
        
    }
    
    //****************
    //HELPER FUNCTIONS
    //****************
    
    func truncateDigitsAfterDecimal(number: Double, afterDecimalDigits: Int) -> String {
        if afterDecimalDigits < 1 || afterDecimalDigits > 512 {return "0"}
        return String(format: "%.\(afterDecimalDigits)f", number)
    }
    
    func fixHomeScreen(nearbyPresseed: Bool){
        if nearbyPressed {
            stationNameLabel.text = "Nearby"
            nearbyButton.isHidden = true
            accessableIcon.isHidden = true
            favoriteButton.isHidden = true
            
            for view in lineViews {
                view.isHidden = true
            }
        } else {
            nearbyButton.isHidden = false
            
            favoriteButton.isHidden = false
            
            for view in lineViews {
                view.backgroundColor = .white
                view.isHidden = false
            }
        }
    }
    
    //*******
    //ACTIONS
    //*******
    
    @IBAction func nearbyPressed(_ sender: Any) {
        nearbyPressed = true
        fixHomeScreen(nearbyPresseed: nearbyPressed)
        dataCollectionView.reloadData()
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        
    }
}

