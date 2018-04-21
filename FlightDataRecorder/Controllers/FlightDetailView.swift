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
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var notes: UITextView!
    
    // Segue Variables
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
        configureView() // Print segue data to fields
        ConfigureMapView() // Configure MapView
        mapKitView.layer.cornerRadius = 5 // Change mapKitView corner radius
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Functions

    // Change enabled status from textfields with edit-button
    @IBAction func editButton(_ sender: Any) {
        if airlineCompanyName.isEnabled == true {
            editButton.title = "Edit" // Change button title to Edit
            // Change Textfields Enabled state to false
            airlineCompanyName.isEnabled = false
            aircraftModel.isEnabled = false
            date.isEnabled = false
            departureAirport.isEnabled = false
            arrivalAirport.isEnabled = false
            flightTime.isEnabled = false
            notes.isEditable = false
            // Ask user to if he want's to save changes
            let checkAirport = UIAlertController(title: "Notification", message: "Would you like to save changes?", preferredStyle: UIAlertControllerStyle.alert)
            checkAirport.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                print("SaveChangesChecker: Yes")
                self.saveChanges()
            }))
            checkAirport.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                print("SaveChangesChecker: No")
            }))
                present(checkAirport, animated: true, completion: nil)
        }else if airlineCompanyName.isEnabled == false {
            editButton.title = "Save" // Change button title to Save
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
    
    // When view is tapped, close keyboard
    @IBAction func endEditing(_ sender: Any) {
        self.view.endEditing(true)
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
    
    func configureView() {
        let flightDataArray = Database.flightData[(indexPath.row)] // Variable for flightDataArray
        
        _departureAirport = flightDataArray.value(forKeyPath: "departureAirportName") as! String
        departureAirportLat = flightDataArray.value(forKeyPath: "departureAirportLat") as! Double
        departureAirportLng = flightDataArray.value(forKeyPath: "departureAirportLng") as! Double
        _arrivalAirport = flightDataArray.value(forKeyPath: "arrivalAirportName") as! String
        arrivalAirportLat = flightDataArray.value(forKeyPath: "arrivalAirportLat") as! Double
        arrivalAirportLng = flightDataArray.value(forKeyPath: "arrivalAirportLng") as! Double
        arrayIndex = indexPath.row
        
        // Print segue data to fields
        detailViewTitle.title = "Flight " + String(format: "%04d", Database.flightData.count - (indexPath.row))
        flightCount.text = String(format: "%04d", Database.flightData.count - (indexPath.row))
        date.text = flightDataArray.value(forKeyPath: "date") as? String
        airlineCompanyName.text = flightDataArray.value(forKeyPath: "airlineCompanyName") as? String
        aircraftModel.text = flightDataArray.value(forKeyPath: "aircraftModel") as? String
        departureAirport.text = flightDataArray.value(forKeyPath: "departureAirportName") as? String
        arrivalAirport.text = flightDataArray.value(forKeyPath: "arrivalAirportName") as? String
        flightTime.text = flightDataArray.value(forKeyPath: "flightTime") as? String
        notes.text = flightDataArray.value(forKeyPath: "notes") as? String
    }
    
    func ConfigureMapView() {
        // MapView Configure
        mapKitView.delegate = self
        mapKitView.showsScale = true
        
        // Departure/Arrival location Setup
        
        // Variables for coordinates
        let sourceCoordinates = CLLocationCoordinate2D(latitude: departureAirportLat, longitude: departureAirportLng)
        let destCoordinates = CLLocationCoordinate2D(latitude: arrivalAirportLat, longitude: arrivalAirportLng)
        
        // Draw polyline between points
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]() // Points array
        points.append(sourceCoordinates) // Add Source coordinates to array
        points.append(destCoordinates) // Add Destination coordinates to array
        let polyline = MKPolyline(coordinates: &points, count: points.count) // Draw polyline
        mapKitView.add(polyline) // Add polyline to map
        
        // Add source/destination points to map
        let sourceAnnotation = MKPointAnnotation()
        let destAnnotation = MKPointAnnotation()
        
        // Departure Airport Point's location and title
        sourceAnnotation.coordinate = CLLocationCoordinate2D(latitude: departureAirportLat, longitude: departureAirportLng)
        sourceAnnotation.title = _departureAirport
        mapKitView.addAnnotation(sourceAnnotation)
        
        // Arrival Airport Point's location and title
        destAnnotation.coordinate = CLLocationCoordinate2D(latitude: arrivalAirportLat, longitude: arrivalAirportLng)
        destAnnotation.title = _arrivalAirport
        mapKitView.addAnnotation(destAnnotation)
        
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
            let checkAirport = UIAlertController(title: "Is the airport location correct?", message: "\(airportName)\nLat: \(lat!)\n Lng: \(lng!)", preferredStyle: UIAlertControllerStyle.alert)
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
    
    // Get Departure Airport Coordinates when textEditingEnds
    @IBAction func departureEditingDidEnd(_ sender: UITextField) {
        getAirportCoordinates(airportName: departureAirport.text!, airport: "departure")
    }
    
    // Get Arrival Airport Coordinates when textEditingEnds
    @IBAction func arrivalEditingDidEnd(_ sender: UITextField) {
        getAirportCoordinates(airportName: arrivalAirport.text!, airport: "arrival")
    }
    
    // Update values to coreData
    func saveChanges() {
        // Check that fields are filled
        if (airlineCompanyName.text != "" && aircraftModel.text != "" && date.text != "" &&
            departureAirport.isEnabled == false && arrivalAirport.isEnabled == false &&
            flightTime.text != "" && notes.text != "") {
                    // Save Changes to CoreData
                    Database.updateCoreData(index: arrayIndex, airlineCompanyName: airlineCompanyName.text, date: date.text, departureAirportName: departureAirport.text, departureAirportLat: departureAirportLat, departureAirportLng: departureAirportLng, arrivalAirportName: arrivalAirport.text, arrivalAirportLat: arrivalAirportLat, arrivalAirportLng: arrivalAirportLng, airplaneModel: aircraftModel.text, flightTime: flightTime.text, notes: notes.text)
        }else {
            Notifications.alertView(message: "Fill all fields before saving", context: self)
        }
    }
}
