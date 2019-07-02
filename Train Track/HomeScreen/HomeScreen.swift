//
//  FirstViewController.swift
//  Chi Transit
//
//  Created by Alush Benitez on 5/29/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit
import CoreLocation

class HomeScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var dataCollectionView: UICollectionView!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var fourthLineView: UIView!
    @IBOutlet weak var fifthLineView: UIView!
    @IBOutlet weak var sixthLineView: UIView!
    @IBOutlet weak var accessableIcon: UIImageView!
    @IBOutlet weak var nearbyButton: UIButton!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var lineViews: [UIView] = []
    var loaded = false
    var firstLoad = true
    var nearbyPressed = false
    var selectedIndex = 0
    
    var alertCount = 0
    var colorsAffected: [UIColor] = []
    var alertString = ""
    private let refreshControl = UIRefreshControl()
    
    //mapID, Distance, name, colors, accessable
    //Ordered closest to furthest
    var nearbyStationsData: [[Any]] = [[-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false], [-1.0, -1.0, "", [], false]]
    var trainTrackerData: [[Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dataCollectionView.delegate = self
        dataCollectionView.dataSource = self
        dataCollectionView.register(UINib.init(nibName: "TrainTrackerCell", bundle: nil), forCellWithReuseIdentifier: "TrainTrackerCell")
        dataCollectionView.register(UINib.init(nibName: "NearbyStationCell", bundle: nil), forCellWithReuseIdentifier: "NearbyStationCell")
        dataCollectionView.register(UINib.init(nibName: "AlertCell", bundle: nil), forCellWithReuseIdentifier: "AlertCell")
        locationManager.requestWhenInUseAuthorization()
        
        lineViews = [firstLineView, secondLineView, thirdLineView, fourthLineView, fifthLineView, sixthLineView]
        
        for view in lineViews {
            view.layer.cornerRadius = 15
        }

        //Location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //Refresh
        if #available(iOS 10.0, *) {
            dataCollectionView.refreshControl = refreshControl
        } else {
            dataCollectionView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadTrainTrackerData(_:)), for: .valueChanged)
        nearbyButton.layer.cornerRadius = 7
        nearbyButton.layer.borderWidth = 2
        nearbyButton.layer.borderColor = notBlack.cgColor
        
        lastUpdatedLabel.layer.cornerRadius = 4
        lastUpdatedLabel.layer.backgroundColor = notBlack.cgColor
    }
    
    @objc private func reloadTrainTrackerData(_ sender: Any) {
        if nearbyPressed {
            loaded = false
            
            locationManager.startUpdatingLocation()
        } else {
            grabTrainTrackerData(mapid: nearbyStationsData[selectedIndex][0] as! Double)
            grabAlertData(stationid: Int(nearbyStationsData[selectedIndex][0] as! Double))
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
                let date = Date()
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: date)
                let minutes = calendar.component(.minute, from: date)
                
                var friendlyMin = String(minutes)
                if friendlyMin.count == 1 {
                    friendlyMin = "0" + friendlyMin
                }
                
                if hour >= 12 {
                    lastUpdatedLabel.text = String(hour - 12) + ":" + friendlyMin + " PM"
                } else {
                    lastUpdatedLabel.text = String(hour) + ":" + friendlyMin + " AM"
                }
                
                grabClosestStations()
                
                if firstLoad {
                    grabTrainTrackerData(mapid: nearbyStationsData[0][0] as! Double)
                    grabAlertData(stationid: Int(nearbyStationsData[0][0] as! Double))
                    
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
        var name = ""
        
        //Find Closest Station Data
        for result in json![].arrayValue {
            var latitude = result["location"]["coordinates"][0].doubleValue
            var longitude = result["location"]["coordinates"][1].doubleValue
            stationCoordinate = CLLocation(latitude: result["location"]["coordinates"][1].doubleValue, longitude: result["location"]["coordinates"][0].doubleValue)
            for coordinate in testedCoordinates {
                if result["station_name"].stringValue == "Roosevelt" {
                    latitude = 41.867368
                    longitude = -87.627402
                }
                if latitude == coordinate[0] && longitude == coordinate[1]{
                    tested = true
                }
            }
            
            //Getting mapID, Distance, name, colors
            
            if !tested {
                testedCoordinates.append([latitude, longitude])
                
                if result["station_name"].stringValue == "Harold Washington Library-State/Van Buren" {
                    name = "Harold Washington Library"
                } else {
                    name = result["station_name"].stringValue
                }
                let distanceInMeters = stationCoordinate.distance(from: userCoordinate)
                if distanceInMeters < nearbyStationsData[0][1] as! Double || nearbyStationsData[0][1] as! Double == -1 {
                    //Closer than closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    nearbyStationsData[3] = nearbyStationsData[2]
                    nearbyStationsData[2] = nearbyStationsData[1]
                    nearbyStationsData[1] = nearbyStationsData[0]
                    
                    nearbyStationsData[0][0] = result["map_id"].doubleValue
                    nearbyStationsData[0][1] = distanceInMeters
                    nearbyStationsData[0][2] = name
                    nearbyStationsData[0][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[1][1] as! Double || nearbyStationsData[1][1] as! Double == -1 {
                    //Closer than second closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    nearbyStationsData[3] = nearbyStationsData[2]
                    nearbyStationsData[2] = nearbyStationsData[1]
                    
                    nearbyStationsData[1][0] = result["map_id"].doubleValue
                    nearbyStationsData[1][1] = distanceInMeters
                    nearbyStationsData[1][2] = name
                    nearbyStationsData[1][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[2][1] as! Double || nearbyStationsData[2][1] as! Double == -1 {
                    //closer than third closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    nearbyStationsData[3] = nearbyStationsData[2]
                    
                    nearbyStationsData[2][0] = result["map_id"].doubleValue
                    nearbyStationsData[2][1] = distanceInMeters
                    nearbyStationsData[2][2] = name
                    nearbyStationsData[2][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[3][1] as! Double || nearbyStationsData[3][1] as! Double == -1{
                    //closer than fourth closest
                    nearbyStationsData[4] = nearbyStationsData[3]
                    
                    nearbyStationsData[3][0] = result["map_id"].doubleValue
                    nearbyStationsData[3][1] = distanceInMeters
                    nearbyStationsData[3][2] = name
                    nearbyStationsData[3][4] = result["ada"].boolValue
                } else if distanceInMeters < nearbyStationsData[4][1] as! Double || nearbyStationsData[4][1] as! Double == -1{
                    //closer than fifth closest
                    nearbyStationsData[4][0] = result["map_id"].doubleValue
                    nearbyStationsData[4][1] = distanceInMeters
                    nearbyStationsData[4][2] = name
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
                    stationNameLabel.text = nearbyStationsData[0][2] as? String
                    //[labelObject setMinimumScaleFactor:0.5];
                    //[labelObject setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
                    //stationNameLabel.sizeToFit()
                    accessableIcon.isHidden = !result["ada"].boolValue
                }
            }
            tested = false
        }
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
            
            var friendlyMin = String(predictionMin)
            if friendlyMin.count == 1 {
                friendlyMin = "0" + friendlyMin
            }
            
            if predictionHour < 12 {
                lastUpdatedLabel.text = String(predictionHour) + ":" + String(friendlyMin) + " AM"
            } else {
                lastUpdatedLabel.text = String(predictionHour - 12) + ":" + String(friendlyMin) + " PM"
            }
            
            
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
    
    //*************************
    //PARSE CONSUMER ALERT DATA
    //*************************
    
    func grabAlertData(stationid: Int) {
        let query = "http://www.transitchicago.com/api/1.0/routes.aspx?stationid=" + String(Int(stationid)) + "&outputType=JSON"
        print(query)
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseAlertData(json: json)
            }
        }
    }
    
    func parseAlertData(json: JSON?){
        alertCount = 0
        alertString = ""
        if json!["CTARoutes"]["RouteInfo"].arrayValue == [] {
            if json!["CTARoutes"]["RouteInfo"].dictionaryValue["RouteStatus"]?.stringValue ?? "error" != "Normal Service"{
                alertCount += 1
                alertString = json!["CTARoutes"]["RouteInfo"].dictionaryValue["RouteStatus"]?.stringValue ?? "error"
            }
        } else {
            for result in json!["CTARoutes"]["RouteInfo"].arrayValue {
                if result["RouteStatus"].stringValue != "Normal Service"{
                    alertCount += 1
                    alertString = result["RouteStatus"].stringValue
                }
            }
        }
        
        
        
        if alertCount == 0 {
            alertString = "Normal Service"
            colorsAffected = nearbyStationsData[0][3] as! [UIColor]
        } else if alertCount != 1 {
            alertString = "Multiple Alerts"
        }
    }
    
    
    //**********************
    //SET UP COLLECTION VIEW
    //**********************

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !nearbyPressed {
            print(trainTrackerData.count + 1)
            return trainTrackerData.count + 1
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if nearbyPressed {
            //Show Nearby Stations
            let nearbyDataCell = dataCollectionView.dequeueReusableCell(withReuseIdentifier: "NearbyStationCell", for: indexPath) as! NearbyStationCell
            nearbyDataCell.nearbyStationLabel.text = nearbyStationsData[indexPath.row][2] as? String
            nearbyDataCell.distanceLabel.text = truncateDigitsAfterDecimal(number:((nearbyStationsData[indexPath.row][1] as! Double) / 1609.344), afterDecimalDigits: 1) + " mi"
            nearbyDataCell.layer.cornerRadius = 7
            for view in nearbyDataCell.lineViews {
                view.layer.cornerRadius = 13
                view.backgroundColor = .white
            }
            var count = 0
            for color in nearbyStationsData[indexPath.row][3] as! [UIColor] {
                nearbyDataCell.lineViews[count].backgroundColor = color
                count += 1
            }
            
            //Shadow
            nearbyDataCell.layer.shadowColor = UIColor.gray.cgColor
            nearbyDataCell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
            nearbyDataCell.layer.shadowRadius = 1.2
            nearbyDataCell.layer.shadowOpacity = 1.0
            nearbyDataCell.layer.masksToBounds = false
            nearbyDataCell.layer.shadowPath = UIBezierPath(roundedRect:nearbyDataCell.bounds, cornerRadius: 7).cgPath
            
            return nearbyDataCell
            
            
            
        } else {
            //Show Train Tracker Data
            if indexPath.row == 0 {
                //Alert Cell
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
                } else {
                    dataCell.destinationLabel.text = (trainTrackerData[indexPath.row - 1][2] as? String)!
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if nearbyPressed {
            nearbyPressed = false;
            fixHomeScreen(nearbyPresseed: nearbyPressed)
            stationNameLabel.text = nearbyStationsData[indexPath.row][2] as? String
            accessableIcon.isHidden = !(nearbyStationsData[indexPath.row][4] as? Bool)!
            
            for w in 0..<(nearbyStationsData[indexPath.row][3] as! [UIColor]).count {
                lineViews[w].backgroundColor = (nearbyStationsData[indexPath.row][3]as! [UIColor])[w]
            }
            
            selectedIndex = indexPath.row
            
            grabTrainTrackerData(mapid: nearbyStationsData[indexPath.row][0] as! Double)
            grabAlertData(stationid: Int(nearbyStationsData[indexPath.row][0] as! Double))
            
            
            dataCollectionView.reloadData()
        } else {
            if indexPath.row != 0 {
                let alert = FollowTrainAlertView(runNumber: trainTrackerData[indexPath.row-1][7] as! Int, color: trainTrackerData[indexPath.row-1][0] as! UIColor, destination: trainTrackerData[indexPath.row-1][2] as! String, colorString: trainTrackerData[indexPath.row-1][1] as! String)
                alert.show(animated: true)
            } else {
                let alert = StatusAlertView(stationid: Int(nearbyStationsData[selectedIndex][0] as! Double))
                alert.show(animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.dataCollectionView.frame.width - 40, height: 75)
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
            
            for view in lineViews {
                view.isHidden = true
            }
        } else {
            nearbyButton.isHidden = false

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
        
    }
}
