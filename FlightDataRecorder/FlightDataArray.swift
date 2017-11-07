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

// Structure for FlightData
struct flightDataStruct {
    var flightCount: Int
    var airlineCompanyName: String
    var date: String
    var departureAirportName: String
    var departureAirportLat: Double
    var departureAirportLng: Double
    var arrivalAirportName: String
    var arrivalAirportLat: Double
    var arrivalAirportLng: Double
    var airplaneModel: String
    var flightTime: String
    var notes: String
}

class FlightDataArray: NSObject {
    // FlightData Array
    var flightData: [NSManagedObject] = []
    
    func addFlight(flightCount: Int, airlineCompanyName: String!, date: String!, departureAirportName: String!, departureAirportLat: Double!, departureAirportLng: Double!, arrivalAirportName: String!, arrivalAirportLat: Double!, arrivalAirportLng: Double!, airplaneModel: String!, flightTime: String!, notes: String!)
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "FlightData", in: managedContext)!
        
        let FlightData = NSManagedObject(entity: entity, insertInto: managedContext)

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

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func loadArray() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FlightData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            flightData = try managedContext.fetch(fetchRequest)
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
