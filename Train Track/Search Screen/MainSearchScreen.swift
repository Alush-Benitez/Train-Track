//
//  MainSearchScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/8/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit
import CoreLocation

class MainSearchScreen: UICollectionViewController, UISearchResultsUpdating {
    
    var filters: [UIButton] = []
    var colors: [UIColor] = [ctaRed, ctaBlue, ctaBrown, ctaGreen, ctaOrange, ctaPink, ctaPurple, ctaYellow]
    
    var searchBar = UISearchBar()
    var resultSearchController: UISearchController? = nil
    
    var filteredStations: [[Any]] = []
    
    var allStations: [[Any]] = []
    var redLineStations: [[Any]] = []
    var blueLineStations: [[Any]] = []
    var brownLineStations: [[Any]] = []
    var greenLineStations: [[Any]] = []
    var orangeLineStations: [[Any]] = []
    var pinkLineStations: [[Any]] = []
    var purpleLineStations: [[Any]] = []
    var yellowLineStations: [[Any]] = []
    
    var lineInfo: [[[Any]]] = []
    var selectedLineIndex = 0
    
    var blueLineMapIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib.init(nibName: "NearbyStationCell", bundle: nil), forCellWithReuseIdentifier: "NearbyStationCell")
        //Search Bar Setup
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController?.searchResultsUpdater = self
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        resultSearchController?.obscuresBackgroundDuringPresentation = false
        
        resultSearchController?.searchResultsUpdater = self
        resultSearchController?.searchBar.placeholder = "Find A Station"
        resultSearchController?.searchBar.setShowsCancelButton(false, animated: false)
        grabStationsInLines()
        lineInfo = [redLineStations, blueLineStations, brownLineStations, greenLineStations, orangeLineStations, pinkLineStations, purpleLineStations, yellowLineStations]
        collectionView.reloadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(MainSearchScreen.filtersTapped(_:)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        //collectionView.reloadData()
    }
    
    //***************
    //SHOWING FILTERS
    //***************
    
    @objc func filtersTapped(_ sender:UIBarButtonItem!) {
//        let alert = FiltersAlertView()
//        alert.show(animated: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "FiltersScreen") as! FiltersScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
    //****************
    //SEARCH BAR STUFF
    //****************
    
    func searchBarIsEmpty() -> Bool {
        return resultSearchController?.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStations = []
        var stationList: [[Any]] = []
        if selectedFilter == 8 {
            stationList = allStations
        } else {
            stationList = lineInfo[selectedFilter]
        }
        for station in stationList {
            var stationName = (station[0] as! String)
            if stationName == "O'Hare" {
                stationName = "o'hare"
            }
            stationName = stationName.lowercased().typographized(language: "en")
            if stationName.contains(searchText.lowercased()){
                filteredStations.append(station)
            }
        }
        collectionView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func isFiltering() -> Bool {
        return resultSearchController!.isActive && !searchBarIsEmpty()
    }
    
    //***********************
    //PARSE STATION INFO DATA
    //***********************
    
    func grabStationsInLines() {
        let query = "https://data.cityofchicago.org/resource/8mj8-j3c4.json"
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parseStationInfo(json: json)
            }
        }
    }
    
    func parseStationInfo(json: JSON?){
        var testedIds: [String] = []
        var stationInfo: [Any] = []
        var lines: [UIColor] = []
        
        stationInfo.append(json![].arrayValue[0].dictionaryValue["station_name"]!.stringValue)
        stationInfo.append(json![].arrayValue[0].dictionaryValue["map_id"]!.stringValue)
        stationInfo.append(json![].arrayValue[0].dictionaryValue["ada"]!.boolValue)
        
        
        for result in json![].arrayValue {
            //Checking if station was already tested
            let mapId = result["map_id"].stringValue
            let accessibility = result["ada"].boolValue
            var name = result["station_name"].stringValue
            if name == "Harold Washington Library-State/Van Buren" {
                name = "Harold Washington Library"
            }
            
            for id in testedIds {
                if mapId != id{
                    //New station found
                    stationInfo.append(lines)
                    
                    if lines.contains(ctaRed) {
                        redLineStations.append(stationInfo)
                    }
                    if lines.contains(ctaBlue) {
                        blueLineStations.append(stationInfo)
                    }
                    if lines.contains(ctaGreen) {
                        greenLineStations.append(stationInfo)
                    }
                    if lines.contains(ctaBrown) {
                        brownLineStations.append(stationInfo)
                    }
                    if lines.contains(ctaPurple)  {
                        purpleLineStations.append(stationInfo)
                    }
                    if lines.contains(ctaYellow) {
                        yellowLineStations.append(stationInfo)
                    }
                    if lines.contains(ctaPink) {
                        pinkLineStations.append(stationInfo)
                    }
                    if lines.contains(ctaOrange) {
                        orangeLineStations.append(stationInfo)
                    }
                    if lines.count != 0 {
                        allStations.append(stationInfo)
                    }
                    
                    //Reset data holders
                    stationInfo = []
                    lines = []
                    stationInfo.append(name)
                    stationInfo.append(mapId)
                    stationInfo.append(accessibility)
                    testedIds = [mapId]
                    
                }
            }
            
            testedIds.append(mapId)
            
            if result["red"].boolValue && !lines.contains(ctaRed) {
                lines.append(ctaRed)
            }
            if result["blue"].boolValue && !lines.contains(ctaBlue) && !blueLineMapIds.contains(mapId) {
                lines.append(ctaBlue)
                blueLineMapIds.append(mapId)
            }
            if result["g"].boolValue && !lines.contains(ctaGreen) {
                lines.append(ctaGreen)
            }
            if result["brn"].boolValue && !lines.contains(ctaBrown) {
                lines.append(ctaBrown)
            }
            if (result["p"].boolValue || result["pexp"].boolValue) && !lines.contains(ctaPurple)  {
                lines.append(ctaPurple)
            }
            if result["y"].boolValue && !lines.contains(ctaYellow) {
                lines.append(ctaYellow)
            }
            if result["pnk"].boolValue && !lines.contains(ctaPink) {
                lines.append(ctaPink)
            }
            if result["o"].boolValue && !lines.contains(ctaOrange) {
                lines.append(ctaOrange)
            }
        }
        
        //For the last data entry
        stationInfo.append(lines)
        if lines.contains(ctaRed) {
            redLineStations.append(stationInfo)
        }
        if lines.contains(ctaBlue) {
            blueLineStations.append(stationInfo)
        }
        if lines.contains(ctaGreen) {
            greenLineStations.append(stationInfo)
        }
        if lines.contains(ctaBrown) {
            brownLineStations.append(stationInfo)
        }
        if lines.contains(ctaPurple)  {
            purpleLineStations.append(stationInfo)
        }
        if lines.contains(ctaYellow) {
            yellowLineStations.append(stationInfo)
        }
        if lines.contains(ctaPink) {
            pinkLineStations.append(stationInfo)
        }
        if lines.contains(ctaOrange) {
            orangeLineStations.append(stationInfo)
        }
        
    }
    
    //*********************
    //COLLECTION VIEW SETUP
    //*********************

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return lineInfo[selectedLineIndex].count
        if isFiltering() {
            return filteredStations.count
        } else {
            if selectedFilter == 8 {
                return allStations.count
            } else {
                return lineInfo[selectedFilter].count
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyStationCell", for: indexPath) as! NearbyStationCell
        var station: [Any] = []
        if isFiltering() {
            station = filteredStations[indexPath.row]
        } else {
            if selectedFilter == 8 {
                station = allStations[indexPath.row]
            } else {
                station = lineInfo[selectedFilter][indexPath.row]
            }
        }
        
        cell.nearbyStationLabel.text = station[0] as? String
        cell.distanceLabel.isHidden = true
        for lineView in cell.lineViews {
            lineView.layer.cornerRadius = 13
            lineView.backgroundColor = .white
        }
        
        var count = 0
        
        for color in station[3] as! [UIColor] {
            cell.lineViews[count].backgroundColor = color
            count += 1
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var station: [Any] = []
        if isFiltering() {
            station = filteredStations[indexPath.row]
        } else {
            if selectedFilter == 8 {
                station = allStations[indexPath.row]
            } else {
                station = lineInfo[selectedFilter][indexPath.row]
            }
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desVC = mainStoryboard.instantiateViewController(withIdentifier: "SearchResultsScreen") as! SearchResultsScreen
        desVC.stationName = station[0] as? String ?? "error"
        desVC.stationColors = station[3] as? [UIColor] ?? []
        desVC.mapId = Int(station[1] as? String ?? "0") ?? 0
        desVC.accessibility = station[2] as? Bool ?? false
        self.navigationController?.pushViewController(desVC, animated: true)
        
    }
    
    
    //*******
    //ACTIONS
    //*******
    
    @IBAction func searchUnwindSegue(unwindSegue: UIStoryboardSegue){
        collectionView.reloadData()
        if isFiltering() {
            updateSearchResults(for: resultSearchController!)
        }
    }
}
