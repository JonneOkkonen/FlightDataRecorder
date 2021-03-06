//
//  FlightDataTable.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 25/09/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit

class FlightDataTable: UITableViewController, UIViewControllerPreviewingDelegate {
    
    // Notes
    /*
         #Tag's for tableViewCell items
         FlightCount = 1
         AirlineCompanyName = 2
         Departure-Arrival = 3
         AirplaneModel = 4
         FlightDuration = 5
     
         #Segue Names
         flightDataSegue = Segue from start screen to flightData tableView
         flightDataDetails = Segue from tableViewCell to flightDataEditView
         newFlight = Segue from flightData tableView to AddNewFlight
    */
    
    // Outlets
    @IBOutlet weak var flightCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load data from Core Data
        Database.Load()
        // Reload tableView Data
        tableView.reloadData()
        // Remove seperatorLine
        tableView.separatorStyle = .none
        // Update Flight Count
        flightCountLabel.text = String(format: "%04d", Database.FlightDataArray.count)
        // Prefer Large Titles
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Check 3D Touch Support
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: tableView)
        }else {
            print("No 3DTouch Compability")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load data from Core Data
        Database.Load()
        // Reload tableView Data
        tableView.reloadData()
        // Flight Count
        flightCountLabel.text = String(format: "%04d", Database.FlightDataArray.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TableView
    
    // Number of cell's in tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If there is no flight data, display noDataLabel
        if (Database.FlightDataArray.count == 0) {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No flight data"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return Database.FlightDataArray.count
    }
    
    // TableView Cell Content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TableViewCell
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableCell")! as UITableViewCell
        
        // Variables for Cell Labels
        let flightCount = tableViewCell.viewWithTag(1) as? UILabel
        let airlineCompanyName = tableViewCell.viewWithTag(2) as? UILabel
        let airplaneModel = tableViewCell.viewWithTag(3) as? UILabel
        let date = tableViewCell.viewWithTag(4) as? UILabel
        let flightTime = tableViewCell.viewWithTag(5) as? UILabel
        let departureAirport = tableViewCell.viewWithTag(6) as? UILabel
        let arrivalAirport = tableViewCell.viewWithTag(7) as? UILabel
        
        // Instans for current row data in FlightDataArray
        let data = Database.FlightDataArray[indexPath.row]
        
        // Set data to labels
        flightCount?.text = "#" + String(format: "%04d", Database.FlightDataArray.count - indexPath.row)
        airlineCompanyName?.text = data.value(forKeyPath: "airlineCompanyName") as? String
        departureAirport?.text = data.value(forKeyPath: "departureAirportName") as? String
        arrivalAirport?.text = data.value(forKeyPath: "arrivalAirportName") as? String
        airplaneModel?.text = data.value(forKeyPath: "aircraftModel") as? String
        date?.text = data.value(forKeyPath: "date") as? String
        flightTime?.text = data.value(forKeyPath: "flightTime") as? String
        
        // Scale AirlineCompanyName to Fit TextField
        airlineCompanyName?.font = UIFont.boldSystemFont(ofSize: 30)
        airlineCompanyName?.numberOfLines = 0
        airlineCompanyName?.minimumScaleFactor = 0.1
        
        return tableViewCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    // Segue to DetailView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass flightDataDetails to FlightDetailView
        if segue.identifier == "flightDataDetails" {
            // Cell
            let cell = sender as! UITableViewCell
            // IndexPath for selected row
            let indexPath = tableView.indexPath(for: cell)!
            // Variable for segue destination
            let detailSegue = segue.destination as! FlightDetailView
            
            // Change ViewController mode to edit and cell's to indexPath
            detailSegue.mode = "edit"
            detailSegue.indexPath = indexPath
        }
        
        // Pass flightCount to addNewFlight
        if segue.identifier == "newFlight" {
            let segue = segue.destination as! FlightDetailView // Variable for segue destination
            // Change ViewController mode to add
            segue.mode = "add"
        }
    }
    
    // 3D-TOUCH
    
    // Preview View
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return storyboard?.instantiateViewController(withIdentifier: "flightDetailView")
    }
    
    // Final View
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show((storyboard?.instantiateViewController(withIdentifier: "flightDetailView"))!, sender: self)
    }
}
