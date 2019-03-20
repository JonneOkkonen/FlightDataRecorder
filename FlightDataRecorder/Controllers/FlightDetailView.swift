//
//  FlightDetailView.swift
//  FlightDataRecorder
//
//  Created by Jonne Okkonen on 26/09/2017.
//  Copyright © 2017 Jonne Okkonen. All rights reserved.
//

import UIKit
import MapKit

class FlightDetailView: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Outlets
    @IBOutlet var mapKitView: MKMapView!
    @IBOutlet weak var flightCount: UILabel!
    @IBOutlet weak var airlineCompanyName: UITextField!
    @IBOutlet weak var aircraftModel: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var departureAirport: UITextField!
    @IBOutlet weak var arrivalAirport: UITextField!
    @IBOutlet weak var flightTime: UITextField!
    @IBOutlet weak var detailViewTitle: UINavigationItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet weak var notes: UITextView!
    
    // Segue Variables
    var mode: String!
    var indexPath: IndexPath!
    
    // Variables
    var _departureAirport: String!
    var departureAirportLat: Double!
    var departureAirportLng: Double!
    var _arrivalAirport: String!
    var arrivalAirportLat: Double!
    var arrivalAirportLng: Double!
    var arrayIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup View for correct mode
        switch mode {
        case "add":
            // ConfigureView for adding flight
            configureViewForAdd()
            // Set ViewController Title
            detailViewTitle.title = "New flight"
            // Print flightCount value to label
            flightCount.text = String(format: "%04d", Database.FlightDataArray.count + 1)
        case "edit":
            // Change button title to Edit
            actionButton.title = "Edit"
            // ConfigureView for editing flight
            configureViewForEdit()
            // Configure MapView
            ConfigureMapView()
        default:
            // Change button title to Edit
            actionButton.title = "Edit"
        }
        // Change mapKitView corner radius
        mapKitView.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ACTIONS

    // Change enabled status from textfields with edit-button
    @IBAction func actionButton(_ sender: Any) {
        // Edit Flight Mode
        if(mode == "edit") {
            if airlineCompanyName.isEnabled == true {
                actionButton.title = "Edit" // Change button title to Edit
                
                // Change Textfields Enabled state to false
                airlineCompanyName.isEnabled = false
                aircraftModel.isEnabled = false
                date.isEnabled = false
                departureAirport.isEnabled = false
                arrivalAirport.isEnabled = false
                flightTime.isEnabled = false
                notes.isEditable = false
                
                // Ask user to if he want's to save changes
                let checkAirport = UIAlertController(title: "Notification", message: "Would you like to save changes?", preferredStyle: UIAlertController.Style.alert)
                checkAirport.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    print("SaveChangesChecker: Yes")
                    self.SaveChanges()
                }))
                checkAirport.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("SaveChangesChecker: No")
                }))
                present(checkAirport, animated: true, completion: nil)
            }else if airlineCompanyName.isEnabled == false {
                actionButton.title = "Save" // Change button title to Save
                
                // Change Textfields Enabled state to true
                airlineCompanyName.isEnabled = true
                aircraftModel.isEnabled = true
                date.isEnabled = true
                departureAirport.isEnabled = true
                arrivalAirport.isEnabled = true
                flightTime.isEnabled = true
                notes.isEditable = true
            }
        }
        // Add Flight Mode
        if(mode == "add") {
            AddFlight()
        }
    }
    
    // When view is tapped, close keyboard
    @IBAction func endEditing(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    // VIEW SETUP
    
    // When starting FlightTime editing bring timePicker instead of normal keyboard
    @IBAction func flightTimeEditing(_ sender: UITextField) {
        let timePicker:UIDatePicker = UIDatePicker()
        timePicker.datePickerMode = UIDatePicker.Mode.countDownTimer
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
    
    // When starting Date editing bring datepicker instead of normal keyboard
    @IBAction func dateEditing(_ sender: UITextField) {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
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
    
    // Get Departure Airport Coordinates when textEditingEnds
    @IBAction func departureEditingDidEnd(_ sender: UITextField) {
        getAirportCoordinates(airportName: departureAirport.text!, airport: "departure")
    }
    
    // Get Arrival Airport Coordinates when textEditingEnds
    @IBAction func arrivalEditingDidEnd(_ sender: UITextField) {
        getAirportCoordinates(airportName: arrivalAirport.text!, airport: "arrival")
    }
    
    // Configure View for Editing Flight
    func configureViewForEdit() {
        let flightDataArray = Database.FlightDataArray[(indexPath.row)] // Variable for flightDataArray
        
        // Get Data from CoreData to variables
        _departureAirport = flightDataArray.value(forKeyPath: "departureAirportName") as? String
        departureAirportLat = flightDataArray.value(forKeyPath: "departureAirportLat") as? Double
        departureAirportLng = flightDataArray.value(forKeyPath: "departureAirportLng") as? Double
        _arrivalAirport = flightDataArray.value(forKeyPath: "arrivalAirportName") as? String
        arrivalAirportLat = flightDataArray.value(forKeyPath: "arrivalAirportLat") as? Double
        arrivalAirportLng = flightDataArray.value(forKeyPath: "arrivalAirportLng") as? Double
        arrayIndex = indexPath.row
        
        // Get Data from CoreData to Fields
        detailViewTitle.title = "Flight " + String(format: "%04d", Database.FlightDataArray.count - (indexPath.row))
        flightCount.text = String(format: "%04d", Database.FlightDataArray.count - (indexPath.row))
        date.text = flightDataArray.value(forKeyPath: "date") as? String
        airlineCompanyName.text = flightDataArray.value(forKeyPath: "airlineCompanyName") as? String
        aircraftModel.text = flightDataArray.value(forKeyPath: "aircraftModel") as? String
        departureAirport.text = flightDataArray.value(forKeyPath: "departureAirportName") as? String
        arrivalAirport.text = flightDataArray.value(forKeyPath: "arrivalAirportName") as? String
        flightTime.text = flightDataArray.value(forKeyPath: "flightTime") as? String
        notes.text = flightDataArray.value(forKeyPath: "notes") as? String
    }
    
    // Configure View for Adding Flight
    func configureViewForAdd() {
        actionButton.title = "Save" // Change button title to Save
        // Change Textfields Enabled state to true
        airlineCompanyName.isEnabled = true
        aircraftModel.isEnabled = true
        date.isEnabled = true
        departureAirport.isEnabled = true
        arrivalAirport.isEnabled = true
        flightTime.isEnabled = true
        notes.isEditable = true
    }
    
    // MAPVIEW
    
    // Configure MapView
    func ConfigureMapView() {
        // MapView Configure
        mapKitView.delegate = self
        mapKitView.showsScale = true
        
        // Variables
        var sourceCoordinates: CLLocationCoordinate2D!
        var destCoordinates: CLLocationCoordinate2D!
        
        // Departure/Arrival location Setup
        
        // Check if there is departureAirportCoordinates
        if(departureAirportLat != nil && departureAirportLng != nil) {
            
            // Set Coordinates
            sourceCoordinates = CLLocationCoordinate2D(latitude: departureAirportLat, longitude: departureAirportLng)
            
            // Add Source point to map
            let sourceAnnotation = MKPointAnnotation()
            
            // Departure Airport Point's location and title
            sourceAnnotation.coordinate = CLLocationCoordinate2D(latitude: departureAirportLat, longitude: departureAirportLng)
            sourceAnnotation.title = _departureAirport
            mapKitView.addAnnotation(sourceAnnotation) // Add Point to map
        }
        
        // Check if there is arrivalAirportCoordinates
        if(arrivalAirportLat != nil && arrivalAirportLng != nil) {
            
            // Set Coordinates
            destCoordinates = CLLocationCoordinate2D(latitude: arrivalAirportLat, longitude: arrivalAirportLng)
            
            // Add Destination point to map
            let destAnnotation = MKPointAnnotation()
            
            // Arrival Airport Point's location and title
            destAnnotation.coordinate = CLLocationCoordinate2D(latitude: arrivalAirportLat, longitude: arrivalAirportLng)
            destAnnotation.title = _arrivalAirport
            mapKitView.addAnnotation(destAnnotation) // add Point to map
        }
        
        // Only Draw polyline if both airports are set
        if(departureAirportLng != nil && departureAirportLat != nil &&
            arrivalAirportLng != nil && arrivalAirportLat != nil) {
            // Draw polyline between points
            var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]() // Points array
            points.append(sourceCoordinates) // Add Source coordinates to array
            points.append(destCoordinates) // Add Destination coordinates to array
            let polyline = MKPolyline(coordinates: &points, count: points.count) // Draw polyline
            mapKitView.addOverlay(polyline) // Add polyline to map
        }
        
        // Zoom view to fit both points
        mapKitView.showAnnotations(mapKitView.annotations, animated: true)
    }
    
    // Polyline Renderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue // Polyline Color
        renderer.lineWidth = 3.0 // Polyline Width
        return renderer
    }
    
    // Get airport coordinates from Apple Geocode Service
    func getAirportCoordinates(airportName: String, airport: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(airportName) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lng = placemark?.location?.coordinate.longitude
            print("Airport: \(airport) Lat: \(lat!), Lon: \(lng!)")
            
            // Ask user to check airport location
            let checkAirport = UIAlertController(title: "Is the airport location correct?", message: "\(airportName)\nLat: \(lat!)\n Lng: \(lng!)", preferredStyle: UIAlertController.Style.alert)
            checkAirport.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                print("AirportChecker: Yes")
                if airport == "arrival" {
                    // Print location name to textField
                    self.arrivalAirport.text = airportName
                    // Disable arrivalAirportField
                    self.arrivalAirport.isEnabled = false
                    // Save arrivalAirport Coordinates to variables
                    self.arrivalAirportLat = lat
                    self.arrivalAirportLng = lng
                    // Clear polyline
                    self.mapKitView.removeOverlays(self.mapKitView.overlays)
                    // Clear Pins from map
                    self.mapKitView.removeAnnotations(self.mapKitView.annotations)
                    // ConfigureMapView
                    self.ConfigureMapView()
                }
                if airport == "departure" {
                    // Print location name to textField
                    self.departureAirport.text = airportName
                    // Disable departureAirportField
                    self.departureAirport.isEnabled = false
                    // Save departureAirport Coordinates to variables
                    self.departureAirportLat = lat
                    self.departureAirportLng = lng
                    // Clear polyline
                    self.mapKitView.removeOverlays(self.mapKitView.overlays)
                    // Clear Pins from map
                    self.mapKitView.removeAnnotations(self.mapKitView.annotations)
                    // ConfigureMapView
                    self.ConfigureMapView()
                }
            }))
            // Ask user if the airport is correct
            checkAirport.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                print("AirportChecker: No")
            }))
            self.present(checkAirport, animated: true, completion: nil)
        }
    }
    
    // CoreData
    
    // Update values to CoreData
    func SaveChanges() {
        // Check that fields are filled
        if (airlineCompanyName.text != "" && aircraftModel.text != "" && date.text != "" &&
            departureAirport.isEnabled == false && arrivalAirport.isEnabled == false &&
            flightTime.text != "" && notes.text != "") {
                    // Save Changes to CoreData
                    Database.Update(index: arrayIndex, airlineCompanyName: airlineCompanyName.text, date: date.text, departureAirportName: departureAirport.text, departureAirportLat: departureAirportLat, departureAirportLng: departureAirportLng, arrivalAirportName: arrivalAirport.text, arrivalAirportLat: arrivalAirportLat, arrivalAirportLng: arrivalAirportLng, airplaneModel: aircraftModel.text, flightTime: flightTime.text, notes: notes.text)
        }else {
            Notifications.Alert(message: "Fill all fields before saving", context: self)
        }
    }
    
    // Add flight to CoreData
    func AddFlight() {
        if (airlineCompanyName.text != "" && aircraftModel.text != "" && date.text != "" && departureAirport.isEnabled == false &&
            arrivalAirport.isEnabled == false && flightTime.text != "" && notes.text != "") {
            Database.Add(flightCount: Int(flightCount.text!)!, airlineCompanyName: airlineCompanyName.text, date: date.text, departureAirportName: departureAirport.text, departureAirportLat: departureAirportLat, departureAirportLng: departureAirportLng, arrivalAirportName: arrivalAirport.text, arrivalAirportLat: arrivalAirportLat, arrivalAirportLng: arrivalAirportLng, airplaneModel: aircraftModel.text, flightTime: flightTime.text, notes: notes.text)
            
            // Notify user that flight was saved successfully and Empty all fields
            let checkAirport = UIAlertController(title: "Action", message: "Flight was successfully added.", preferredStyle: UIAlertController.Style.alert)
            checkAirport.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in
                Database.Load()
                let count = Database.FlightDataArray.count + 1
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
                // Clear polyline
                self.mapKitView.removeOverlays(self.mapKitView.overlays)
                // Clear Pins from map
                self.mapKitView.removeAnnotations(self.mapKitView.annotations)
            }))
            present(checkAirport, animated: true, completion: nil)
        }else {
            Notifications.Alert(message: "Fill all fields before saving", context: self)
        }
    }
}
