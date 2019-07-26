//
//  AlertDetails.swift
//  Chi Transit
//
//  Created by Alush Benitez on 6/27/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class AlertDetails: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var alertsCollectionView: UICollectionView!
    @IBOutlet weak var systemAlertsButton: UIButton!
    @IBOutlet weak var elevatorAlertsButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var lineHeader: UIView!
    
    var lineName = ""
    var statusInfo: [Any] = []
    
    //Headline, Description, Severity, StartTime, EndTime
    var alertsInfo: [[Any]] = []
    
    //Station Name, LinesAffected
    var elevatorAlertsInfo: [[Any]] = []
    var elevatorAlertsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertsCollectionView.register(UINib.init(nibName: "SystemAlertCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SystemAlertCollectionViewCell")
        alertsCollectionView.register(UINib.init(nibName: "ElevatorAlertCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ElevatorAlertCollectionViewCell")
        
        systemAlertsButton.backgroundColor = notBlack
        elevatorAlertsButton.backgroundColor = .white
        
        systemAlertsButton.setTitle("System Alerts", for: .normal)
        elevatorAlertsButton.setTitle("Elevator Alerts", for: .normal)
        elevatorAlertsButton.setTitleColor(notBlack, for: .normal)
        systemAlertsButton.setTitleColor(.white, for: .normal)
        
        systemAlertsButton.layer.cornerRadius = 16
        elevatorAlertsButton.layer.cornerRadius = 16
        
        //Setup
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.backgroundColor = ctaRed
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isNavigationBarHidden = true
        
        lineLabel.text = lineName
        
        
        alertsCollectionView.dataSource = self
        alertsCollectionView.delegate = self
        
        if lineName == "Red Line" {
            grabAlertData(lineId: "Red")
            lineHeader.backgroundColor = ctaRed
        } else if lineName == "Blue Line" {
            grabAlertData(lineId: "Blue")
            lineHeader.backgroundColor = ctaBlue
        } else if lineName == "Brown Line" {
            grabAlertData(lineId: "Brn")
            lineHeader.backgroundColor = ctaBrown
        } else if lineName == "Green Line" {
            grabAlertData(lineId: "G")
            lineHeader.backgroundColor = ctaGreen
        } else if lineName == "Orange Line" {
            grabAlertData(lineId: "Org")
            lineHeader.backgroundColor = ctaOrange
        } else if lineName == "Purple Line" {
            grabAlertData(lineId: "Pexp")
            lineHeader.backgroundColor = ctaPurple
        } else if lineName == "Pink Line" {
            grabAlertData(lineId: "Pink")
            lineHeader.backgroundColor = ctaPink
        } else {
            grabAlertData(lineId: "Y")
            lineHeader.backgroundColor = ctaYellow
            
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    //*************************
    //PARSE COMSUMER ALERT DATA
    //*************************
    
    func grabAlertData(lineId: String) {
        let query = "http://www.transitchicago.com/api/1.0/alerts.aspx?activeonly=false&planned=true&routeid=" + lineId + "&outputType=JSON"
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseAlertData(json: json)
            }
        }
    }
    
    func parseAlertData(json: JSON?){
        for result in json!["CTAAlerts"]["Alert"].arrayValue {
            var info: [Any] = []
            var linesAffected: [UIColor] = []
            if result["Impact"].stringValue == "Elevator Status" {
                for service in result["ImpactedService"].dictionaryValue["Service"]!.arrayValue {
                    if service["ServiceType"].stringValue == "T" {
                        info.append(service["ServiceName"].stringValue)
                    }
                    if service["ServiceType"].stringValue == "R" {
                        if service["ServiceId"].stringValue == "Red" {
                            linesAffected.append(ctaRed)
                        } else if service["ServiceId"].stringValue == "Blue" {
                            linesAffected.append(ctaBlue)
                        } else if service["ServiceId"].stringValue == "Brn" {
                            linesAffected.append(ctaBrown)
                        } else if service["ServiceId"].stringValue == "G" {
                            linesAffected.append(ctaGreen)
                        } else if service["ServiceId"].stringValue == "Org" {
                            linesAffected.append(ctaOrange)
                        } else if service["ServiceId"].stringValue == "P" || service["ServiceId"].stringValue == "Pexp" {
                            linesAffected.append(ctaPurple)
                        } else if service["ServiceId"].stringValue == "Pink" {
                            linesAffected.append(ctaPink)
                        } else {
                            linesAffected.append(ctaYellow)
                        }
                    }
                }
                if linesAffected == [] && result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceType"]!.stringValue == "R"{
                    //String crap cause the cta is stupid
                    info.append(result["Headline"].stringValue)
                    if result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "Red" {
                        linesAffected.append(ctaRed)
                    } else if result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "Blue" {
                        linesAffected.append(ctaBlue)
                    } else if result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "Brn" {
                        linesAffected.append(ctaBrown)
                    } else if result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "G" {
                        linesAffected.append(ctaGreen)
                    } else if result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "Org" {
                        linesAffected.append(ctaOrange)
                    } else if result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "P" || result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "Pexp" {
                        linesAffected.append(ctaPurple)
                    } else if result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue == "Pink" {
                        linesAffected.append(ctaPink)
                    } else {
                        linesAffected.append(ctaYellow)
                    }
                }
                info.append(linesAffected)
                elevatorAlertsInfo.append(info)
            } else {
                info.append(result["Headline"].stringValue)
                info.append(result["ShortDescription"].stringValue)
                info.append(Int(result["SeverityScore"].stringValue) ?? 0)
                info.append(result["EventStart"].stringValue)
                info.append(result["EventEnd"].stringValue)
                alertsInfo.append(info)
            }
        }
        //Insertion Sort for RegularAlerts
        let n = alertsInfo.count
        if n != 0 {
            for i in 1..<n {
                let key = alertsInfo[i][2] as! Int
                let keyStuff: [Any] = alertsInfo[i]
                var j = i - 1
                
                while j >= 0 && (alertsInfo[j][2] as! Int) < key {
                    alertsInfo[j + 1] = alertsInfo[j]
                    j = j-1
                }
                alertsInfo[j + 1][2] = key
                alertsInfo[j + 1] = keyStuff
            }
        }
    }
    
    //*********************
    //COLLECTION VIEW SETUP
    //*********************
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if elevatorAlertsShown {
            return CGSize(width: 365, height: 75)
        } else {
            return CGSize(width: 365, height: 180)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !elevatorAlertsShown && alertsInfo.count != 0 {
            alertsCollectionView.isHidden = false
            return alertsInfo.count
        } else if elevatorAlertsInfo.count != 0 && elevatorAlertsShown{
            alertsCollectionView.isHidden = false
            return elevatorAlertsInfo.count
        } else {
            alertsCollectionView.isHidden = true
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !elevatorAlertsShown {
            //Headline, Description, Severity, StartTime, EndTime
            let cell = alertsCollectionView.dequeueReusableCell(withReuseIdentifier: "SystemAlertCollectionViewCell", for: indexPath) as! SystemAlertCollectionViewCell
            cell.headlineLabel.text = alertsInfo[indexPath.row][0] as? String
            cell.colorView.layer.cornerRadius = 7
            cell.colorView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            if alertsInfo[indexPath.row][2] as! Int >= 40 {
                cell.colorView.backgroundColor = alertRed
                cell.statusLabel.text = "!"
            } else if alertsInfo[indexPath.row][2] as! Int >= 20 {
                cell.colorView.backgroundColor = alertYellow
                cell.statusLabel.text = "!"
            } else {
                cell.colorView.backgroundColor = infoBlue
                cell.statusLabel.text = "i"
            }
            cell.discriptionLabel.text = alertsInfo[indexPath.row][1] as? String
            
            //STRING CRAP
            let startTimeFromCTA = alertsInfo[indexPath.row][3] as? String
            let endTimeFromCTA = alertsInfo[indexPath.row][4] as? String
            
            if startTimeFromCTA != "" && endTimeFromCTA != ""{
                let startDateBefore = startTimeFromCTA![..<(startTimeFromCTA!.firstIndex(of: "T") ?? startTimeFromCTA!.endIndex)]
                let endDateBefore = endTimeFromCTA![..<(endTimeFromCTA!.firstIndex(of: "T") ?? endTimeFromCTA!.endIndex)]
                cell.startTimeLabel.text = stringCrap(date: String(startDateBefore))
                
                if startDateBefore == endDateBefore {
                    cell.endTimeLabel.isHidden = true
                    cell.toLabel.isHidden = true
                } else {
                    cell.endTimeLabel.isHidden = false
                    cell.toLabel.isHidden = false
                    cell.endTimeLabel.text = stringCrap(date: String(endDateBefore))
                }
            } else if startTimeFromCTA != "" {
                let startDateBefore = startTimeFromCTA![..<(startTimeFromCTA!.firstIndex(of: "T") ?? startTimeFromCTA!.endIndex)]
                cell.startTimeLabel.text = stringCrap(date: String(startDateBefore))
                cell.endTimeLabel.isHidden = false
                cell.toLabel.isHidden = false
                cell.endTimeLabel.text = "TBD"
            }
            
            
            //cell.startTimeLabel.text = alertsInfo[indexPath.row][3] as? String
            //cell.endTimeLabel.text = alertsInfo[indexPath.row][4] as? String
            cell.discriptionLabel.sizeToFit()
            cell.discriptionLabel.sizeToFit()

            
            cell.layer.cornerRadius = 7
            cell.layer.backgroundColor = UIColor.white.cgColor
            
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
            cell.layer.shadowRadius = 1.2
            cell.layer.shadowOpacity = 1.0
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 7).cgPath
        
            return cell
        } else {
            let cell = alertsCollectionView.dequeueReusableCell(withReuseIdentifier: "ElevatorAlertCollectionViewCell", for: indexPath) as! ElevatorAlertCollectionViewCell
            let lineViews: [UIView] = [cell.firstLineView, cell.secondLineView, cell.thirdLineView, cell.fourthLineView, cell.fifthLineView, cell.sixthLineView]
            for line in lineViews {
                line.backgroundColor = .white
                line.layer.cornerRadius = 10
            }
            for i in 0..<(elevatorAlertsInfo[indexPath.row][1] as! [UIColor]).count {
                lineViews[i].backgroundColor = .white
                lineViews[i].backgroundColor = (elevatorAlertsInfo[indexPath.row][1] as! [UIColor])[i]
                
            }
            cell.layer.cornerRadius = 7
            cell.layer.backgroundColor = UIColor.white.cgColor
            
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
            cell.layer.shadowRadius = 1.2
            cell.layer.shadowOpacity = 1.0
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 7).cgPath
            
            var stationName = elevatorAlertsInfo[indexPath.row][0] as? String
            if elevatorAlertsInfo[indexPath.row][0] as? String == "Harold Washington Library-State/Van Buren" {
                stationName = "Harold Washington Library"
            }
            
            cell.stationLabel.text = stationName
            return cell
            
        }
    }

    
    @IBAction func systemAlertsToggle(_ sender: Any) {
        if elevatorAlertsShown {
            elevatorAlertsShown = !elevatorAlertsShown
            systemAlertsButton.backgroundColor = notBlack
            systemAlertsButton.setTitleColor(.white, for: .normal)
            elevatorAlertsButton.setTitleColor(notBlack, for: .normal)
            elevatorAlertsButton.backgroundColor = .white
            
            alertsCollectionView.reloadData()
            
        }
    }
    
    @IBAction func elevatorAlertsToggle(_ sender: Any) {
        if !elevatorAlertsShown {
            elevatorAlertsShown = !elevatorAlertsShown
            elevatorAlertsButton.backgroundColor = notBlack
            elevatorAlertsButton.setTitleColor(.white, for: .normal)
            systemAlertsButton.setTitleColor(notBlack, for: .normal)
            systemAlertsButton.backgroundColor = .white
            alertsCollectionView.reloadData()
        }
    }
    
    //Helper
    
    func stringCrap(date: String) -> String {
        let startDateBefore = date
        var startDateBeforeAltered = startDateBefore
        //year
        var range = startDateBefore.index(startDateBefore.endIndex, offsetBy: -6)..<startDateBefore.endIndex
        startDateBeforeAltered.removeSubrange(range)
        range = startDateBeforeAltered.startIndex..<startDateBeforeAltered.index(startDateBeforeAltered.endIndex, offsetBy: -2)
        startDateBeforeAltered.removeSubrange(range)
        let year = String(startDateBeforeAltered)
        
        //month
        startDateBeforeAltered = startDateBefore
        range = startDateBefore.index(startDateBefore.endIndex, offsetBy: -3)..<startDateBefore.endIndex
        startDateBeforeAltered.removeSubrange(range)
        range = startDateBeforeAltered.startIndex..<startDateBeforeAltered.index(startDateBeforeAltered.endIndex, offsetBy: -2)
        startDateBeforeAltered.removeSubrange(range)
        let month = String(startDateBeforeAltered)
        
        //day
        startDateBeforeAltered = startDateBefore
        range = startDateBeforeAltered.startIndex..<startDateBeforeAltered.index(startDateBeforeAltered.endIndex, offsetBy: -2)
        startDateBeforeAltered.removeSubrange(range)
        let day = String(startDateBeforeAltered)
        
        return (month + "/" + day + "/" + year)
    }
}
