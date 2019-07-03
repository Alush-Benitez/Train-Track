//
//  StatusAlertView.swift
//  Chi Transit
//
//  Created by Alush Benitez on 6/21/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit
import Foundation

class StatusAlertView: UIView, PopUpAnimation {
    var backgroundView = UIView()
    var dialogView = UIView()
    var regularAlerts: [[Any]] = []
    var accessibilityAlerts: [[Any]] = []
    
    var heightCount = 0

    convenience init(stationid: Int) {
        self.init(frame: UIScreen.main.bounds)
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.8
        addSubview(backgroundView)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        
        grabConsumerAlerts(stationid: stationid)
        
        let dialogViewWidth = frame.width-64
        
        //**************
        //CURRENT ALERTS
        //**************
        
        let regularAlertsHeader =  UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 25))
        regularAlertsHeader.text = "Current Alerts"
        regularAlertsHeader.textColor = notBlack
        regularAlertsHeader.font = UIFont(name: "Montserrat-Bold", size: 20.0)
        regularAlertsHeader.textAlignment = .left
    
        var noRegularAlerts = false
        heightCount += 40
        var alertDataViews = addDataToViews(array: regularAlerts, dialogViewWidth: dialogViewWidth)
        
        if alertDataViews.count != 0 {
            for view in alertDataViews {
                dialogView.addSubview(view as! UIView)
            }
        } else {
            noRegularAlerts = true
        }
        
        //********************
        //ACCESSIBILITY ALERTS
        //********************
        
        let heightBeforeAccessibility = heightCount
        if !noRegularAlerts {
            heightCount += 10
        }
        alertDataViews = addDataToViews(array: accessibilityAlerts, dialogViewWidth: dialogViewWidth)
        if alertDataViews.count == 0 {
            heightCount -= 10
        }
        
        if alertDataViews.count == 0 && noRegularAlerts{
            //No regular alerts AND no elevator alerts
            let noAlertsHeader =  UILabel(frame: CGRect(x: 8, y: 19, width: dialogViewWidth-16, height: 30))
            noAlertsHeader.text = "No Service Alerts"
            noAlertsHeader.textColor = notBlack
            noAlertsHeader.font = UIFont(name: "Montserrat-Bold", size: 24)
            noAlertsHeader.textAlignment = .center
            regularAlertsHeader.isHidden = true
            dialogView.addSubview(noAlertsHeader)
            heightCount += 20
        } else if noRegularAlerts {
            //ONLY no regular alerts
            
            regularAlertsHeader.text = "Accessibility Alerts"
            for view in alertDataViews {
                dialogView.addSubview(view as! UIView)
            }
        } else if alertDataViews.count != 0{
            //BOTH PRESENT
            let elevatorAlertsSeperator = UIView(frame: CGRect(x: 8, y: heightBeforeAccessibility, width: Int(dialogViewWidth-16), height: 2))
            elevatorAlertsSeperator.backgroundColor = .gray
            //heightCount += 10
            dialogView.addSubview(elevatorAlertsSeperator)
            
            for view in alertDataViews {
                dialogView.addSubview(view as! UIView)
            }
        }

        dialogView.addSubview(regularAlertsHeader)
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: Double(frame.width-64), height: Double(heightCount + 8))
        
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 7
        dialogView.clipsToBounds = true
        addSubview(dialogView)
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)


    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
    //************
    //DATA PARSING
    //************
    
    func grabConsumerAlerts(stationid: Int) {
        let query = "http://www.transitchicago.com/api/1.0/alerts.aspx?activeonly=true&stationid=" + String(stationid) + "&outputType=JSON"
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseConsumerAlerts(json: json)
            }
        }
    }
    
    func parseConsumerAlerts(json: JSON?){
        // Severity, Impacted Lines, Description
        for result in json!["CTAAlerts"]["Alert"].arrayValue {
            var info: [Any] = []
            
            info.append(Int(result["SeverityScore"].stringValue) ?? 0)
            var linesAffected: [String] = []
            for service in result["ImpactedService"].dictionaryValue["Service"]!.arrayValue {
                if service["ServiceType"].stringValue == "R" {
                    linesAffected.append(service["ServiceId"].stringValue)
                }
                if service["ServiceType"].stringValue == "B" {
                    linesAffected.append(service["ServiceId"].stringValue)
                }
                if service["ServiceType"].stringValue == "X" {
                    linesAffected.append("Red")
                    linesAffected.append("Blue")
                    linesAffected.append("Brn")
                    linesAffected.append("G")
                    linesAffected.append("Org")
                    linesAffected.append("Pink")
                    linesAffected.append("P")
                    linesAffected.append("Y")
                    
                }
            }
            if linesAffected == [] && result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceType"]!.stringValue == "R"{
                linesAffected.append(result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue)
            } else if linesAffected == [] && result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceType"]!.stringValue == "X" {
                linesAffected.append("Red")
                linesAffected.append("Blue")
                linesAffected.append("Brn")
                linesAffected.append("G")
                linesAffected.append("Org")
                linesAffected.append("Pink")
                linesAffected.append("P")
                linesAffected.append("Y")
            }
            info.append(linesAffected)
            
            if result["Impact"].stringValue == "Elevator Status" {
                info.append(result["Headline"].stringValue)
                accessibilityAlerts.append(info)
            } else {
                info.append(result["ShortDescription"].stringValue)
                regularAlerts.append(info)
            }
        }
        //Insertion Sort for RegularAlerts
        let n = regularAlerts.count
        if n != 0 {
            for i in 1..<n {
                let key = regularAlerts[i][0] as! Int
                let keyStuff: [Any] = regularAlerts[i]
                var j = i - 1
                
                while j >= 0 && (regularAlerts[j][0] as! Int) < key {
                    regularAlerts[j + 1] = regularAlerts[j]
                    j = j-1
                }
                regularAlerts[j + 1][0] = key
                regularAlerts[j + 1] = keyStuff
            }
        }
    }
    
    
    //Helper func
    
    func addDataToViews(array: [[Any]], dialogViewWidth: CGFloat) -> [Any] {
        var alertDataViews: [Any] = []
        
        for i in 0..<array.count {
            var lineCount = 1
            for line in array[i][1] as! [String] {
                if line != "Pexp" {
                    let lineView = UIView(frame: CGRect(x: ((5 * (lineCount - 1)) + 8 + (16 * (lineCount - 1))), y: heightCount, width: 16, height: 16))
                    lineView.layer.cornerRadius = 8
                    if line == "Red" {
                        lineView.backgroundColor = ctaRed
                        alertDataViews.append(lineView)
                    } else if line == "Blue" {
                        lineView.backgroundColor = ctaBlue
                        alertDataViews.append(lineView)
                    } else if line == "Brn" {
                        lineView.backgroundColor = ctaBrown
                        alertDataViews.append(lineView)
                    } else if line == "G" {
                        lineView.backgroundColor = ctaGreen
                        alertDataViews.append(lineView)
                    } else if line == "Org" {
                        lineView.backgroundColor = ctaOrange
                        alertDataViews.append(lineView)
                    } else if line == "P"{
                        lineView.backgroundColor = ctaPurple
                        alertDataViews.append(lineView)
                    } else if line == "Pink" {
                        lineView.backgroundColor = ctaPink
                        alertDataViews.append(lineView)
                    } else if line == "Y"{
                        lineView.backgroundColor = ctaYellow
                        alertDataViews.append(lineView)
                    } else {
                        lineView.backgroundColor = .gray
                        let busText = UILabel(frame: CGRect(x: ((5 * (lineCount - 1)) + 8 + (16 * (lineCount - 1))), y: heightCount, width: 16, height: 16))
                        busText.textColor = .white
                        busText.textAlignment = .center
                        busText.text = line
                        if line.count > 2 {
                            busText.font = UIFont(name: "Montserrat-Bold", size: 6.0)
                        } else {
                            busText.font = UIFont(name: "Montserrat-Bold", size: 9.0)
                        }
                        alertDataViews.append(lineView)
                        alertDataViews.append(busText)
                    }
                    lineCount += 1
                }
            }
            heightCount += 22
            let discriptionLabel = UILabel(frame: CGRect(x: 8, y: heightCount, width: Int(dialogViewWidth-16), height: 1))
            discriptionLabel.text = array[i][2] as? String
            discriptionLabel.textColor = notBlack
            discriptionLabel.font = UIFont(name: "Montserrat-Regular", size: 12.0)
            discriptionLabel.textAlignment = .left
            discriptionLabel.lineBreakMode = .byWordWrapping
            discriptionLabel.numberOfLines = 0
            discriptionLabel.sizeToFit()
            heightCount += Int(discriptionLabel.frame.height + 8)
            alertDataViews.append(discriptionLabel)
        }
        return alertDataViews
    }
}
