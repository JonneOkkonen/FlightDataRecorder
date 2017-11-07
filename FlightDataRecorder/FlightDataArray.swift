//
//  FlightDataArray.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 31/10/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit
import CoreData

var DataArray: FlightDataArray = FlightDataArray()

class FlightDataArray: NSObject {
    // FlightData Array
    var flightData: [NSManagedObject] = []
    
    // AddFlight and save it to CoreData
    func addFlight(flightCount: Int, airlineCompanyName: String!, date: String!, departureAirportName: String!, departureAirportLat: Double!, departureAirportLng: Double!, arrivalAirportName: String!, arrivalAirportLat: Double!, arrivalAirportLng: Double!, airplaneModel: String!, flightTime: String!, notes: String!)
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        // Entity
        let entity = NSEntityDescription.entity(forEntityName: "FlightData", in: managedContext)!
        // FlightData
        let FlightData = NSManagedObject(entity: entity, insertInto: managedContext)
        // Set Data Values
        FlightData.setValue(airlineCompanyName, forKeyPath: "airlineCompanyName")
        FlightData.setValue(date, forKeyPath: "date")
        FlightData.setValue(departureAirportName, forKeyPath: "departureAirportName")
        FlightData.setValue(departureAirportLat, forKeyPath: "departureAirportLat")
        FlightData.setValue(departureAirportLng, forKeyPath: "departureAirportLng")
        FlightData.setValue(arrivalAirportName, forKeyPath: "arrivalAirportName")
        FlightData.setValue(arrivalAirportLat, forKeyPath: "arrivalAirportLat")
        FlightData.setValue(arrivalAirportLng, forKeyPath: "arrivalAirportLng")
        FlightData.setValue(airplaneModel, forKeyPath: "aircraftModel")
        FlightData.setValue(flightTime, forKeyPath: "flightTime")
        FlightData.setValue(notes, forKeyPath: "notes")
        
        // Try to save data
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    // Load data from CoreData to Array
    func loadArray() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Fetch data from FlightDataEntity
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FlightData")
        
        // Sort TableView Descending
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            flightData = try managedContext.fetch(fetchRequest)
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
