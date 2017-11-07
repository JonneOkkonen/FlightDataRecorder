//
//  ViewController.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 25/09/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit

class StartView: UIViewController {
    
    // Outlets
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var flightCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainButton.layer.cornerRadius = 5 // Change FlightData button corner radius
        //DataArray.loadArray()
        flightCount.text = String(format: "%04d", DataArray.flightData.count) // Flight Count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataArray.loadArray()
        flightCount.text = String(format: "%04d", DataArray.flightData.count) // Flight Count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

