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

    convenience init(stationid: Int) {
        self.init(frame: UIScreen.main.bounds)
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.8
        addSubview(backgroundView)
        
        grabConsumerAlerts(stationid: stationid)
        
        let dialogViewWidth = frame.width-64
        
        //Current Alerts
        let regularAlertsHeader =  UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
        regularAlertsHeader.text = "Current Alerts"
        regularAlertsHeader.textColor = notBlack
        regularAlertsHeader.font = UIFont(name: "Montserrat-Bold", size: 25.0)
        regularAlertsHeader.textAlignment = .left
        
        var alertDataViews: [Any] = []
        var heightOfLast = 0
        
        for i in 0..<regularAlerts.count {
            var lineCount = 1
            for line in regularAlerts[i][2] as! [String] {
                if line != "Pexp" {
                    let lineView = UIView(frame: CGRect(x: ((5 * (lineCount - 1)) + 8 + (16 * (lineCount - 1))), y: 50 + heightOfLast + (22 * i), width: 16, height: 16))
                    lineView.layer.cornerRadius = 8
                    if line == "Red" {
                        lineView.backgroundColor = ctaRed
                    } else if line == "Blue" {
                        lineView.backgroundColor = ctaBlue
                    } else if line == "Brn" {
                        lineView.backgroundColor = ctaBrown
                    } else if line == "G" {
                        lineView.backgroundColor = ctaGreen
                    } else if line == "Org" {
                        lineView.backgroundColor = ctaOrange
                    } else if line == "P"{
                        lineView.backgroundColor = ctaPurple
                    } else if line == "Pink" {
                        lineView.backgroundColor = ctaPink
                    } else {
                        lineView.backgroundColor = ctaYellow
                    }
                    alertDataViews.append(lineView)
                    lineCount += 1
                }
            }
            let discriptionLabel = UILabel(frame: CGRect(x: 8, y: 70 + (22 * i) + heightOfLast, width: Int(dialogViewWidth-16), height: 1))
            discriptionLabel.text = regularAlerts[i][0] as? String
            discriptionLabel.textColor = notBlack
            discriptionLabel.font = UIFont(name: "Montserrat-Regular", size: 12.0)
            discriptionLabel.textAlignment = .left
            discriptionLabel.lineBreakMode = .byWordWrapping
            discriptionLabel.numberOfLines = 0
            discriptionLabel.sizeToFit()
            heightOfLast += Int(discriptionLabel.frame.height + 8)
            alertDataViews.append(discriptionLabel)
            
            
//            let discriptionText = UITextView(frame: CGRect(x: 8, y: 45 + (100 * i), width: Int(dialogViewWidth-16), height: 100))
//            discriptionText.isEditable = false
//            discriptionText.isScrollEnabled = false
//            discriptionText.font = UIFont(name: "Montserrat-Light", size: 12.0)
//            discriptionText.textColor = notBlack
//            alertDataViews.append(discriptionText)
            
        }
        
        var height = 600.0
        
        for view in alertDataViews {
            dialogView.addSubview(view as! UIView)
            //height += Double((view as! UIView).frame.height + 10)
        }
        
        dialogView.addSubview(regularAlertsHeader)
        
        //var dialogViewHeight = runInfoLabel.frame.height + 8 + destinationLabel.frame.height + 8
        //dialogViewHeight += CGFloat(height)
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: Double(frame.width-64), height: height)
        
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 7
        dialogView.clipsToBounds = true
        addSubview(dialogView)
        
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
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
        //Descriptoon, Severity, Impacted Lines
        for result in json!["CTAAlerts"]["Alert"].arrayValue {
            var info: [Any] = []
            
            info.append(result["ShortDescription"].stringValue)
            info.append(Int(result["SeverityScore"].stringValue) ?? 0)
            var linesAffected: [String] = []
            for service in result["ImpactedService"].dictionaryValue["Service"]!.arrayValue {
                if service["ServiceType"].stringValue == "R" {
                    linesAffected.append(service["ServiceId"].stringValue)
                }
            }
            if linesAffected == [] && result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceType"]!.stringValue == "R"{
                linesAffected.append(result["ImpactedService"].dictionaryValue["Service"]!.dictionaryValue["ServiceId"]!.stringValue)
            }
            info.append(linesAffected)
            
            if result["Impact"].stringValue == "Elevator Status" {
                accessibilityAlerts.append(info)
            } else {
                regularAlerts.append(info)
            }
        }
        
        //Insertion Sort for RegularAlerts
        let n = regularAlerts.count
        
        
        for i in 1..<n {
            //print(regularAlerts[i][1])
            let key = regularAlerts[i][1] as! Int
            let keyStuff: [Any] = regularAlerts[i]
            var j = i - 1
            
            while j >= 0 && (regularAlerts[j][1] as! Int) < key {
                regularAlerts[j + 1] = regularAlerts[j]
                j = j-1
            }
            regularAlerts[j + 1][1] = key
            regularAlerts[j + 1] = keyStuff
        }
        print(regularAlerts)
    }
}
