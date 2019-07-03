//
//  AlertsScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 6/27/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class AlertsScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var routesCollectionView: UICollectionView!
    
    var routeStatuses: [String] = []
    let routes = [["Red Line", ctaRed], ["Blue Line", ctaBlue], ["Brown Line", ctaBrown], ["Green Line", ctaGreen], ["Orange Line", ctaOrange], ["Pink Line", ctaPink], ["Purple Line", ctaPurple], ["Yellow Line", ctaYellow]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        routesCollectionView.delegate = self
        routesCollectionView.dataSource = self
        routesCollectionView.isScrollEnabled = false
        
        grabAlertData()
        routesCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.routesCollectionView.frame.width - 40, height:((self.routesCollectionView.frame.height - 70) / 8) - 0.5)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = routesCollectionView.dequeueReusableCell(withReuseIdentifier: "alertCell", for: indexPath) as! AlertScreenCell
        cell.lineLabel.text = routes[indexPath.row][0] as? String
        cell.lineLabel.textColor = routes[indexPath.row][1] as? UIColor
        if routeStatuses[indexPath.row] == "Normal Service" {
            cell.statusIcon.image = UIImage(named: "greencheck")
        } else {
            cell.statusIcon.image = UIImage(named: "warning-icon")
        }
        
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 7
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
        cell.layer.shadowRadius = 1.2
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 7).cgPath
        return cell
    }
    
    //Segue
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desVC = mainStoryboard.instantiateViewController(withIdentifier: "AlertDetails") as! AlertDetails
        desVC.lineName = routes[indexPath.row][0] as! String
        desVC.statusInfo.append(routeStatuses[indexPath.row])
        if routeStatuses[indexPath.row] != "Normal Service" {
            desVC.statusInfo.append(UIImage(named: "warning-icon")!)
        } else {
            desVC.statusInfo.append(UIImage(named: "greencheck")!)
        }
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    

    //*************************
    //PARSE COMSUMER ALERT DATA
    //*************************
    
    func grabAlertData() {
        routeStatuses = []
        let query = "http://www.transitchicago.com/api/1.0/routes.aspx?type=rail&outputType=JSON"
        print(query)
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseAlertData(json: json)
            }
        }
    }
    
    func parseAlertData(json: JSON?){
        for result in json!["CTARoutes"]["RouteInfo"].arrayValue {
            if result["Route"].stringValue != "Purple Line Express" {
                routeStatuses.append(result["RouteStatus"].stringValue)
            }
        }
    }
    
    //*******
    //ACTIONS
    //*******
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
        
    }
    
    
    @IBAction func reload(_ sender: Any) {
        grabAlertData()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.routesCollectionView.alpha = 0
        })
        
        let notificationFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.impactOccurred()
        routesCollectionView.reloadData()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.routesCollectionView.alpha = 1
        })
    }
}
