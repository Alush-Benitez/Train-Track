//
//  FiltersScreen.swift
//  Chi Transit
//
//  Created by Alush Benitez on 7/24/19.
//  Copyright © 2019 Alush Benitez. All rights reserved.
//

import UIKit

class FiltersScreen: UIViewController {
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var brownButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var buttons: [UIButton] = []
    var colors: [UIColor] = [ctaRed, ctaBlue, ctaBrown, ctaGreen, ctaOrange, ctaPink, ctaPurple, ctaYellow]

    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [redButton, blueButton, brownButton, greenButton, orangeButton, pinkButton, purpleButton, yellowButton]
        
        for i in 0..<buttons.count {
            buttons[i].layer.cornerRadius = 65
            if selectedFilter == 8 || selectedFilter == i {
                buttons[i].backgroundColor = colors[i]
            } else {
                buttons[i].backgroundColor = .gray
            }
        }
        
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 4, height: 9)
        backgroundView.layer.shadowRadius = 9
        backgroundView.layer.shadowOpacity = 1.0
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.shadowPath = UIBezierPath(roundedRect: backgroundView.bounds, cornerRadius: 20).cgPath
        
    }
    
    //*******
    //ACTIONS
    //*******

    @IBAction func redPressed(_ sender: Any) {
        if selectedFilter != 0 {
            selectedFilter = 0
            buttons[selectedFilter].backgroundColor = ctaRed
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func bluePressed(_ sender: Any) {
        if selectedFilter != 1 {
            selectedFilter = 1
            buttons[selectedFilter].backgroundColor = ctaBlue
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func brownPressed(_ sender: Any) {
        if selectedFilter != 2 {
            selectedFilter = 2
            buttons[selectedFilter].backgroundColor = ctaBrown
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func greenPressed(_ sender: Any) {
        if selectedFilter != 3 {
            selectedFilter = 3
            buttons[selectedFilter].backgroundColor = ctaGreen
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func orangePressed(_ sender: Any) {
        if selectedFilter != 4 {
            selectedFilter = 4
            buttons[selectedFilter].backgroundColor = ctaOrange
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func pinkPressed(_ sender: Any) {
        if selectedFilter != 5 {
            selectedFilter = 5
            buttons[selectedFilter].backgroundColor = ctaPink
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func purplePressed(_ sender: Any) {
        if selectedFilter != 6 {
            selectedFilter = 6
            buttons[selectedFilter].backgroundColor = ctaPurple
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func yellowPressed(_ sender: Any) {
        if selectedFilter != 7 {
            selectedFilter = 7
            buttons[selectedFilter].backgroundColor = ctaYellow
            for i in 0..<buttons.count {
                if i != selectedFilter {
                    buttons[i].backgroundColor = .gray
                }
            }
        } else {
            selectedFilter = 8
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = colors[i]
            }
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
    }
    
    
    
}
