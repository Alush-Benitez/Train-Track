//
//  Globals.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/11/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import Foundation

//**********************************
//FUNCS FOR TRAIN TRACKER DATA SETUP
//**********************************

//PARSE TRAIN TRACKER DATA

func grabTrainTrackerData(mapid: Double) -> [[Any]] {
    let query = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=167e3f6b5d0646889964748acf3bcc58&mapid=" + String(Int(mapid)) + "&outputType=JSON"
    if let url = URL(string: query) {
        if let data = try? Data(contentsOf: url) {
            let json = try! JSON(data: data)
            return parseTrainTrackerData(json: json)
        }
    }
    return []
}

func parseTrainTrackerData(json: JSON?) -> [[Any]] {
    var trainTrackerData: [[Any]] = []
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
    return trainTrackerData
}

//*************************
//PARSE CONSUMER ALERT DATA
//*************************

func grabAlertData(stationid: Int) -> String {
    let query = "http://www.transitchicago.com/api/1.0/routes.aspx?stationid=" + String(Int(stationid)) + "&outputType=JSON"
    print(query)
    if let url = URL(string: query) {
        if let data = try? Data(contentsOf: url) {
            let json = try! JSON(data: data)
            return parseAlertData(json: json)
        }
    }
    return ""
}

func parseAlertData(json: JSON?) -> String {
    var alertCount = 0
    var alertString = ""
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
    } else if alertCount != 1 {
        alertString = "Multiple Alerts"
    }
    return alertString
}

//*********
//VARIABLES
//*********

var selectedFilter = 8
var favoriteStations: [[Any]] = []
var favoriteMapids: [Int] = []
