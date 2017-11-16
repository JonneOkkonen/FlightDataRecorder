//
//  AddNewFlight.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 17/10/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class AddNewFlight: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Outlets
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var flightCount: UILabel!
    @IBOutlet weak var airlineCompanyName: UITextField!
    @IBOutlet weak var aircraftModel: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var departureAirport: UITextField!
    @IBOutlet weak var arrivalAirport: UITextField!
    @IBOutlet weak var flightTime: UITextField!
    @IBOutlet weak var notes: UITextView!
    
    // Segue Variables
    var flightCountSegue: Int!
    
    // Variables
    var departureAirportLat: Double!
    var departureAirportLng: Double!
    var arrivalAirportLat: Double!
    var arrivalAirportLng: Double!
    
    // Structure for GeocodingService JSON Data
    struct GeocodingService:Codable{
        var status:String
        var results:[GeocodingResult]
    }
    
    struct GeocodingResult:Codable{
        struct Geometry:Codable{
            struct Location:Codable{
                let lat:Double
                let lng:Double
            }
            let location:Location
        }
        let formatted_address:String
        let geometry:Geometry
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Write flightCount to textField (number of flight's in array + 1)
        let count = flightCountSegue + 1 // Add one to flightCount
        flightCount.text = String(format: "%04d", count) // Print flightCount value to label
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Actions
    
    // Save new flight to Core Data
    @IBAction func saveButton(_ sender: Any) {
        if (airlineCompanyName.text != "" && aircraftModel.text != "" && date.text != "" && departureAirport.isEnabled == false &&
            arrivalAirport.isEnabled == false && flightTime.text != "" && notes.text != "") {
            DataArray.addFlight(flightCount: Int(flightCount.text!)!, airlineCompanyName: airlineCompanyName.text, date: date.text, departureAirportName: departureAirport.text, departureAirportLat: departureAirportLat, departureAirportLng: departureAirportLng, arrivalAirportName: arrivalAirport.text, arrivalAirportLat: arrivalAirportLat, arrivalAirportLng: arrivalAirportLng, airplaneModel: aircraftModel.text, flightTime: flightTime.text, notes: notes.text)
            
            // Notify user that flight was saved successfully and Empty all fields
            let checkAirport = UIAlertController(title: "Action", message: "Flight was successfully added.", preferredStyle: UIAlertControllerStyle.alert)
            checkAirport.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in
                DataArray.loadArray()
                let count = DataArray.flightData.count + 1
                self.flightCount.text = String(format: "%04d", count)
                self.airlineCompanyName.text = ""
                self.aircraftModel.text = ""
                self.date.text = ""
                self.departureAirport.text = ""
                self.departureAirport.isEnabled = true
                self.departureAirportLat = 0.00
                self.departureAirportLng = 0.00
                self.arrivalAirport.text = ""
                self.arrivalAirport.isEnabled = true
                self.arrivalAirportLat = 0.00
                self.arrivalAirportLng = 0.00
                self.flightTime.text = ""
                self.notes.text = "Notes..."
            }))
            present(checkAirport, animated: true, completion: nil)
        }else {
            let alertController = UIAlertController(title: "Error", message:
                "Fill all fields before saving", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // When view is tapped, close keyboard
    @IBAction func endEditing(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    // When starting Date editing bring datepicker instead of normal keyboard
    @IBAction func dateEditing(_ sender: UITextField) {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    // Update selected date to textField
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "dd.MM.yyyy"
        date.text = dateFormatter.string(from: sender.date)
    }
    
    // When starting FlightTime editing bring timePicker instead of normal keyboard
    @IBAction func flightTimeEditing(_ sender: UITextField) {
        let timePicker:UIDatePicker = UIDatePicker()
        timePicker.datePickerMode = UIDatePickerMode.countDownTimer
        sender.inputView = timePicker
        timePicker.addTarget(self, action: #selector(timePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    // Update selected time to textField
    @objc func timePickerValueChanged(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = DateFormatter.Style.none
        timeFormatter.timeStyle = DateFormatter.Style.short
        timeFormatter.dateFormat = "HH:mm"
        let value = timeFormatter.string(from: sender.date)
        flightTime.text = String(value.prefix(2)) + " h " + String(value.dropFirst(3)) + " min"
    }
    
    // Get Departure Airport Coordinates from Google Geocode Service and pass them to parser
    func getDepartureCoordinates() {
        let airportName = departureAirport.text
        if airportName != nil {
            let url = "http://maps.googleapis.com/maps/api/geocode/json?address=" + airportName! + "&sensor=true"
            Alamofire.request(url).responseJSON(completionHandler: {
                response in
                self.parseData(JSONData: response.data!, airport: "departure")
            })
        }
    }
    
    // Get Arrival Airport Coordinates from Google Geocode Service and pass them to parser
    func getArrivalCoordinates() {
        let airportName = arrivalAirport.text
        if airportName != nil {
            let url = "http://maps.googleapis.com/maps/api/geocode/json?address=" + airportName! + "&sensor=true"
            Alamofire.request(url).responseJSON(completionHandler: {
                response in
                self.parseData(JSONData: response.data!, airport: "arrival")
            })
        }
    }
    
    // Parse JSON Data from Google Geocode Service
    func parseData(JSONData: Data, airport: String) {
        let decoder = JSONDecoder()
        do {
            let obj = try decoder.decode(GeocodingService.self, from: JSONData) // Decode JSON to Structures
            let status = obj.status // Save JSON status to variable
            print("GeocodingService Status: \(status)") // Print status to Debug
            if status == "OK" { // If status 'OK' Continue
                for result in obj.results{
                    // Variables for JSON Data
                    let locationLat = result.geometry.location.lat
                    let locationLng = result.geometry.location.lng
                    let address = result.formatted_address
                    // Print JSON Data to Debug
                    print("LocationLat: \(locationLat)")
                    print("LocationLng: \(locationLng)")
                    print("Address: \(address)")
                    // Ask user to check airport location
                    let checkAirport = UIAlertController(title: "Is the airport location correct?", message: "\(address)\nLat: \(locationLat)\n Lng: \(locationLng)", preferredStyle: UIAlertControllerStyle.alert)
                    checkAirport.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        print("AirportChecker: Yes")
                        if airport == "arrival" {
                            // Print location name to textField
                            self.arrivalAirport.text = address
                            // Disable arrivalAirportField
                            self.arrivalAirport.isEnabled = false
                            // Save arrivalAirport Coordinates to variables
                            self.arrivalAirportLat = locationLat
                            self.arrivalAirportLng = locationLng
                            // Add ArrivalAirport pin to map
                            self.AddArrivalAirport()
                        }
                        if airport == "departure" {
                            // Print location name to textField
                            self.departureAirport.text = address
                            // Disable departureAirportField
                            self.departureAirport.isEnabled = false
                            // Save departureAirport Coordinates to variables
                            self.departureAirportLat = locationLat
                            self.departureAirportLng = locationLng
                            // Add DepartureAirport pin to map
                            self.AddDepartureAirport()
                        }
                    }))
                    // Ask user if the airport is correct
                    checkAirport.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                        print("AirportChecker: No")
                    }))
                    present(checkAirport, animated: true, completion: nil)
                }
            }
        } catch{
            print("\(error)")
        }
    }
    
    // Get Departure Airport Coordinates when textEditingEnds
    @IBAction func departureEditingDidEnd(_ sender: UITextField) {
        getDepartureCoordinates()
    }
    
    // Get Arrival Airport Coordinates when textEditingEnds
    @IBAction func arrivalEditingDidEnd(_ sender: UITextField) {
        getArrivalCoordinates()
    }
    
    // When DepartureAirport is added add pin to map
    func AddDepartureAirport() {
        // MapView Configure
        mapKitView.delegate = self
        mapKitView.showsScale = true
        
        // Departure location Setup
        
        // Add source pin to map
        let sourceAnnotation = MKPointAnnotation()
        
        // Departure Airport Point's location and title
        sourceAnnotation.coordinate = CLLocationCoordinate2D(latitude: departureAirportLat, longitude: departureAirportLng)
        sourceAnnotation.title = departureAirport.text
        mapKitView.addAnnotation(sourceAnnotation)
        
        // Zoom view to fit both points
        mapKitView.showAnnotations(mapKitView.annotations, animated: true)
    }
    
    // When ArrivalAirport is added add pin to map
    func AddArrivalAirport() {
        // MapView Configure
        mapKitView.delegate = self
        mapKitView.showsScale = true
        
        // Arrival location Setup
        
        // Add destination pin to map
        let destAnnotation = MKPointAnnotation()

        // Arrival Airport Point's location and title
        destAnnotation.coordinate = CLLocationCoordinate2D(latitude: arrivalAirportLat, longitude: arrivalAirportLng)
        destAnnotation.title = arrivalAirport.text
        mapKitView.addAnnotation(destAnnotation)
        
        // Zoom view to fit both points
        mapKitView.showAnnotations(mapKitView.annotations, animated: true)
    }
}
