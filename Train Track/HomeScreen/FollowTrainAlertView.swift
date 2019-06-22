//
//  FollowTrainAlertView.swift
//  Chi Transit
//
//  Created by Alush Benitez on 6/11/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import Foundation
import UIKit

class FollowTrainAlertView: UIView, PopUpAnimation {
    var backgroundView = UIView()
    var dialogView = UIView()
    
    var nextStationsData: [[Any]] = []
    
    convenience init(runNumber: Int, color: UIColor, destination: String, colorString: String) {
        self.init(frame: UIScreen.main.bounds)
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.8
        addSubview(backgroundView)
        
        grabNextStations(runNumber: runNumber)
        
        let dialogViewWidth = frame.width-64
        
        var newDestination = ""
        
        if destination == "Loop" {
            newDestination = "The Loop"
        } else {
            newDestination = destination
        }
        //StationName, countdownTime, isApp, isDly
        
        let runInfoLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 15))
        runInfoLabel.text = colorString + " Line Run #" + String(runNumber) + " to"
        runInfoLabel.textAlignment = .left
        runInfoLabel.textColor = .white
        runInfoLabel.font = UIFont(name: "Montserrat-Light", size: 15.0)
        let destinationLabel = UILabel(frame: CGRect(x: 8, y: runInfoLabel.frame.height, width: dialogViewWidth-16, height: 55))
        destinationLabel.text = newDestination
        destinationLabel.textAlignment = .left
        destinationLabel.textColor = .white
        destinationLabel.font = UIFont(name: "Montserrat-Bold", size: 30.0)
        
        let backgroundColorView = UIView(frame: CGRect(x: 0, y: 0, width: dialogViewWidth, height: 70))
        backgroundColorView.backgroundColor = color
        
        
        var nextStationsDataViews: [Any] = []
        var count = 1
        for station in nextStationsData {
            let nextStationLabel = UILabel(frame: CGRect(x: 8, y: 35 + (count * 40), width: Int(dialogViewWidth-75), height: 30))
            nextStationLabel.text = station[0] as? String
            nextStationLabel.textColor = notBlack
            nextStationLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
            nextStationsDataViews.append(nextStationLabel)
            let timeEstimateLabel = UILabel(frame: CGRect(x: Int(dialogViewWidth - 75), y: 35 + (count * 40), width: Int(67), height: 30))
            timeEstimateLabel.textColor = notBlack
            timeEstimateLabel.textAlignment = .right
            timeEstimateLabel.text = (station[1] as! String) + " min"
            timeEstimateLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
            nextStationsDataViews.append(timeEstimateLabel)
            count += 1
        }
        
        var height = 0.0
        
        for view in nextStationsDataViews {
            dialogView.addSubview(view as! UIView)
            height += Double((view as! UIView).frame.height + 10)
        }
        height /= 2.0
        height += 72
        
        if nextStationsDataViews.count == 0 {
            let noDataLabel = UILabel(frame: CGRect(x: 8, y: 38 + (count * 40), width: Int(dialogViewWidth), height: 30))
            noDataLabel.text = "Data is Unavalible"
            noDataLabel.textColor = notBlack
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20.0)
            height = 120
            dialogView.addSubview(noDataLabel)
        }
        
        dialogView.addSubview(backgroundColorView)
        dialogView.addSubview(runInfoLabel)
        dialogView.addSubview(destinationLabel)
        
        
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
    
    //***********
    //SETUP STUFF
    //***********
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
    func grabNextStations(runNumber: Int) {
        let query = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx?key=167e3f6b5d0646889964748acf3bcc58&runnumber=" + String(runNumber) + "&outputType=JSON"
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseNextStations(json: json)
            }
        }
    }
    
    
    //************
    //DATA PARSING
    //************
    
    func parseNextStations(json: JSON?){
        
        nextStationsData = []
        
        //StationName, countdownTime, isApp, isDly
        for result in json!["ctatt"]["eta"].arrayValue {
            var info: [Any] = []
            if result["staNm"].stringValue == "Harold Washington Library-State/Van Buren" {
                info.append("Harold Washington Library")
            } else {
                info.append(result["staNm"].stringValue)
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
            
            info.append(result["isApp"].boolValue)
            info.append(result["isDly"].boolValue)
            
            nextStationsData.append(info)
            info = []
            
        }
        
        print(nextStationsData)
    }
    
    
    
    
}
