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

    convenience init(stationid: Int) {
        self.init(frame: UIScreen.main.bounds)
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.8
        addSubview(backgroundView)
        
        

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
        var orginized: [Any] = []
        var unorginized: [Int] = []
        
        for result in json!["CTAAlerts"]["Alert"].arrayValue {
            
        }
        
        
    }


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
