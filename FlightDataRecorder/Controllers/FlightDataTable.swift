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
        Database.loadArray() // Load data from Core Data
        tableView.reloadData() // Reload tableView Data
        tableView.separatorStyle = .none // Remove seperatorLine
        flightCountLabel.text = String(format: "%04d", Database.flightData.count) // Flight Count
        self.navigationController?.navigationBar.prefersLargeTitles = true // Prefer Large Titles
        
        // Check 3D Touch Support
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: tableView)
        }else {
            print("No 3DTouch Compability")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Database.loadArray() // Load data from Core Data
        tableView.reloadData() // Reload tableView Data
        flightCountLabel.text = String(format: "%04d", Database.flightData.count) // Flight Count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TableView
    
    // Number of cell's in tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If there is no flight data, display noDataLabel
        if (Database.flightData.count == 0) {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No flight data"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return Database.flightData.count
    }
    
    // Cell Content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableCell")! as UITableViewCell
        
        // Variables for Cell Labels
        let flightCount = tableViewCell.viewWithTag(1) as? UILabel
        let airlineCompanyName = tableViewCell.viewWithTag(2) as? UILabel
        let airplaneModel = tableViewCell.viewWithTag(3) as? UILabel
        let date = tableViewCell.viewWithTag(4) as? UILabel
        let flightTime = tableViewCell.viewWithTag(5) as? UILabel
        let departureAirport = tableViewCell.viewWithTag(6) as? UILabel
        let arrivalAirport = tableViewCell.viewWithTag(7) as? UILabel
        
        // Print data to Labels
        let data = Database.flightData[indexPath.row]
        flightCount?.text = "#" + String(format: "%04d", Database.flightData.count - indexPath.row)
        airlineCompanyName?.text = data.value(forKeyPath: "airlineCompanyName") as? String
        airlineCompanyName?.adjustsFontSizeToFitWidth = true
        let departure = data.value(forKeyPath: "departureAirportName") as? String
        let arrival = data.value(forKeyPath: "arrivalAirportName") as? String
        departureAirport?.text = departure
        arrivalAirport?.text =  arrival!
        airplaneModel?.text = data.value(forKeyPath: "aircraftModel") as? String
        date?.text = data.value(forKeyPath: "date") as? String
        flightTime?.text = data.value(forKeyPath: "flightTime") as? String
        return tableViewCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    // Segue to DetailView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass flightDataDetails to FlightDetailView
        if segue.identifier == "flightDataDetails" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)! // IndexPath for selected row
            let flightDataArray = Database.flightData[(indexPath.row)] // Variable for flightDataArray
            let detailSegue = segue.destination as! FlightDetailView // Variable for segue destination

            // Variables for data
            let flightCount = Database.flightData.count - (indexPath.row)
            let airlineCompanyName = flightDataArray.value(forKeyPath: "airlineCompanyName")
            let date = flightDataArray.value(forKeyPath: "date")
            let departureAirport = flightDataArray.value(forKeyPath: "departureAirportName")
            let departureAirportLat = flightDataArray.value(forKeyPath: "departureAirportLat")
            let departureAirportLng = flightDataArray.value(forKeyPath: "departureAirportLng")
            let arrivalAirport = flightDataArray.value(forKeyPath: "arrivalAirportName")
            let arrivalAirportLat = flightDataArray.value(forKeyPath: "arrivalAirportLat")
            let arrivalAirportLng = flightDataArray.value(forKeyPath: "arrivalAirportLng")
            let airplaneModel = flightDataArray.value(forKeyPath: "aircraftModel")
            let flightTime = flightDataArray.value(forKeyPath: "flightTime")
            let notes = flightDataArray.value(forKeyPath: "notes")
            let arrayIndex = indexPath.row
            
            // Pass data forward to FlightDetailView
            detailSegue.flightCountSegue = flightCount
            detailSegue.airlineCompanyNameSegue = airlineCompanyName as! String
            detailSegue.dateSegue = date as! String
            detailSegue.departureAirportSegue = departureAirport as! String
            detailSegue.departureAirportLatSegue = departureAirportLat as! Double
            detailSegue.departureAirportLngSegue = departureAirportLng as! Double
            detailSegue.arrivalAirportSegue = arrivalAirport as! String
            detailSegue.arrivalAirportLatSegue = arrivalAirportLat as! Double
            detailSegue.arrivalAirportLngSegue = arrivalAirportLng as! Double
            detailSegue.aircraftModelSegue = airplaneModel as! String
            detailSegue.flightTimeSegue = flightTime as! String
            detailSegue.notesSegue = notes as! String
            detailSegue.arrayIndex = arrayIndex
        }
        
        // Pass flightCount to addNewFlight
        if segue.identifier == "newFlight" {
            let count = Database.flightData.count // FlightCount
            let segue = segue.destination as! AddNewFlight // Variable for segue destination
            // Pass data forward to AddNewFlight
            segue.flightCountSegue = count
        }
    }
    
    // 3D Touch
    
    // Preview View
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return storyboard?.instantiateViewController(withIdentifier: "flightDetailView")
    }
    
    // Final View
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show((storyboard?.instantiateViewController(withIdentifier: "flightDetailView"))!, sender: self)
    }
    
}
