//
//  MainSearchScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/8/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit
import CoreLocation

class MainSearchScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var redFilter: UIButton!
    @IBOutlet weak var blueFilter: UIButton!
    @IBOutlet weak var brownFilter: UIButton!
    @IBOutlet weak var greenFilter: UIButton!
    @IBOutlet weak var orangeFilter: UIButton!
    @IBOutlet weak var pinkFilter: UIButton!
    @IBOutlet weak var purpleFilter: UIButton!
    @IBOutlet weak var yellowFilter: UIButton!
    @IBOutlet weak var stationsCollectionView: UICollectionView!
    
    var filters: [UIButton] = []
    var colors: [UIColor] = [ctaRed, ctaBlue, ctaBrown, ctaGreen, ctaOrange, ctaPink, ctaPurple, ctaYellow]
    
    var searchBar = UISearchBar()
    var resultSearchController: UISearchController? = nil
    
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
        //Search Bar Setup
        let stationSearchTable = storyboard!.instantiateViewController(withIdentifier: "SearchResultsTableViewScreen") as! SearchResultsTableViewScreen
        resultSearchController = UISearchController(searchResultsController: stationSearchTable)
        resultSearchController?.searchResultsUpdater = stationSearchTable as? UISearchResultsUpdating
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        filters = [redFilter, blueFilter, brownFilter, greenFilter, orangeFilter, pinkFilter, purpleFilter, yellowFilter]
        for i in 0..<filters.count {
            filters[i].backgroundColor = colors[i]
            filters[i].layer.cornerRadius = 32.5
        }
        
        stationsCollectionView.delegate = self
        stationsCollectionView.dataSource = self
        
        grabStationsInLines()
        lineInfo = [redLineStations, blueLineStations, brownLineStations, greenLineStations, orangeLineStations, pinkLineStations, purpleLineStations, yellowLineStations]
        stationsCollectionView.reloadData()

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
        
        
        for result in json![].arrayValue {
            //Checking if station was already tested
            let mapId = result["map_id"].stringValue
            
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
                    
                    //Reset data holders
                    stationInfo = []
                    lines = []
                    stationInfo.append(name)
                    stationInfo.append(mapId)
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(lineInfo[selectedLineIndex])
        return lineInfo[selectedLineIndex].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = stationsCollectionView.dequeueReusableCell(withReuseIdentifier: "stationSearchCell", for: indexPath) as! StationCell
        cell.stationName.text = lineInfo[selectedLineIndex][indexPath.row][0] as? String
        
        for lineView in cell.lineViews {
            lineView.layer.cornerRadius = 10
            lineView.backgroundColor = .white
        }
        
        var count = 0
        for color in lineInfo[selectedLineIndex][indexPath.row][2] as! [UIColor] {
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
    
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
    
    //*******
    //ACTIONS
    //*******
    
    @IBAction func redSelected(_ sender: Any) {
        selectedLineIndex = 0
        stationsCollectionView.reloadData()
    }
    
    @IBAction func blueSelected(_ sender: Any) {
        selectedLineIndex = 1
        stationsCollectionView.reloadData()
    }
    
    @IBAction func brownSelected(_ sender: Any) {
        selectedLineIndex = 2
        stationsCollectionView.reloadData()
    }
    
    @IBAction func greenSelected(_ sender: Any) {
        selectedLineIndex = 3
        stationsCollectionView.reloadData()
    }
    
    @IBAction func orangeSelected(_ sender: Any) {
        selectedLineIndex = 4
        stationsCollectionView.reloadData()
    }
    
    @IBAction func pinkSelected(_ sender: Any) {
        selectedLineIndex = 5
        stationsCollectionView.reloadData()
    }
    
    @IBAction func purpleSelected(_ sender: Any) {
        selectedLineIndex = 6
        stationsCollectionView.reloadData()
    }
    
    @IBAction func yellowSelected(_ sender: Any) {
        selectedLineIndex = 7
        stationsCollectionView.reloadData()
    }
    
    
    
    
    
}
