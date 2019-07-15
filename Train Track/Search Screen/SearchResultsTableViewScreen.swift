//
//  SearchResultsTableViewScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/8/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class SearchResultsTableViewScreen: UICollectionViewController {
    
    var filteredResults: [[Any]] = []
    var searchController: UISearchController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchResultsCell", for: indexPath) as! SearchResultsCell
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("here!")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desVC = mainStoryboard.instantiateViewController(withIdentifier: "SearchResultsScreen") as! SearchResultsScreen
        desVC.stationName = filteredResults[indexPath.row][0] as? String ?? "error"
        desVC.stationColors = filteredResults[indexPath.row][2] as? [UIColor] ?? []
        desVC.mapId = Int(filteredResults[indexPath.row][1] as? String ?? "0") ?? 0
        self.navigationController?.pushViewController(desVC, animated: true)
        //self.present(desVC, animated: true, completion: nil)
    }
}
