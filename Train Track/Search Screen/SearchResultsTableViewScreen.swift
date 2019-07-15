//
//  SearchResultsTableViewScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/8/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class SearchResultsTableViewScreen: UITableViewController {
    
    var filteredResults: [[Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsCell", for: indexPath) as! SearchResultsCell
        cell.stationLabel.text = filteredResults[indexPath.row][0] as? String
        
        let lineViews = [cell.firstLineView, cell.secondLineView, cell.thirdLineView, cell.fourthLineView, cell.fifthLineView, cell.sixthLineView]
        
        for view in lineViews {
            view?.backgroundColor = .white
            view?.layer.cornerRadius = 13
        }

        for i in 0..<(filteredResults[indexPath.row][2] as! [UIColor]).count {
            lineViews[i]?.backgroundColor = (filteredResults[indexPath.row][2] as! [UIColor])[i]
        }
        
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 7
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.2)
        cell.layer.shadowRadius = 1.2
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius: 7).cgPath
        
        return cell
    }

}
