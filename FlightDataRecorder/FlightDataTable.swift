//
//  FlightDataTable.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 25/09/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit

class FlightDataTable: UITableViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataArray.loadArray() // Load data from Core Data
        tableView.reloadData() // Reload tableView Data
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataArray.loadArray() // Load data from Core Data
        tableView.reloadData() // Reload tableView Data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TableView
    
    // Number of cell's in tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If there is no flight data, display noDataLabel
        if (DataArray.flightData.count == 0) {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No flight data"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return DataArray.flightData.count
    }
    
    // Cell Content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableCell")! as UITableViewCell
        
        // Variables for Cell Labels
        let flightCount = tableViewCell.viewWithTag(1) as? UILabel
        let airlineCompanyName = tableViewCell.viewWithTag(2) as? UILabel
        let arrivalDeparture = tableViewCell.viewWithTag(3) as? UILabel
        let airplaneModel = tableViewCell.viewWithTag(4) as? UILabel
        let flightTime = tableViewCell.viewWithTag(5) as? UILabel
        
        // Print data to Labels
        let data = DataArray.flightData[indexPath.row]
        flightCount?.text = String(format: "%04d", DataArray.flightData.count - indexPath.row)
        airlineCompanyName?.text = data.value(forKeyPath: "airlineCompanyName") as? String
        let arrival = data.value(forKeyPath: "departureAirportName") as? String
        let departure = data.value(forKeyPath: "arrivalAirportName") as? String
        arrivalDeparture?.text =  arrival! + " - " + departure!
        airplaneModel?.text = data.value(forKeyPath: "aircraftModel") as? String
        flightTime?.text = data.value(forKeyPath: "flightTime") as? String
        return tableViewCell
    }
    
    // Segue to DetailView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass flightDataDetails to FlightDetailView
        if segue.identifier == "flightDataDetails" {
            let indexPath = tableView.indexPathForSelectedRow // IndexPath for selected row
            let flightDataArray = DataArray.flightData[(indexPath?.row)!] // Variable for flightDataArray
            let detailSegue = segue.destination as! FlightDetailView // Variable for segue destination

            // Variables for data
            let flightCount = DataArray.flightData.count - (indexPath?.row)!
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
        }
        
        // Pass flightCount to addNewFlight
        if segue.identifier == "newFlight" {
            let count = DataArray.flightData.count // FlightCount
            let segue = segue.destination as! AddNewFlight // Variable for segue destination
            // Pass data forward to AddNewFlight
            segue.flightCountSegue = count
        }
    }
    
}
