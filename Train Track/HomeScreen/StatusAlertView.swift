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
    }
}
