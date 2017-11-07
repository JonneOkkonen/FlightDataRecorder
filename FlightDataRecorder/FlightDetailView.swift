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
    var flightCountSegue: Int!
    var airlineCompanyNameSegue: String!
    var aircraftModelSegue: String!
    var dateSegue: String!
    var departureAirportSegue: String!
    var departureAirportLatSegue: Double!
    var departureAirportLngSegue: Double!
    var arrivalAirportSegue: String!
    var arrivalAirportLatSegue: Double!
    var arrivalAirportLngSegue: Double!
    var flightTimeSegue: String!
    var notesSegue: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView() // Print segue data to fields
        ConfigureMapView() // Configure MapView
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
        }else if airlineCompanyName.isEnabled == false {
            editButton.title = "Done" // Change button title to Done
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
        flightTime.text = String(value.characters.prefix(2)) + " h " + String(value.characters.dropFirst(3)) + " min"
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
        // Print segue data to fields
        detailViewTitle.title = "Flight " + String(format: "%04d", flightCountSegue)
        flightCount.text = String(format: "%04d", flightCountSegue)
        date.text = dateSegue
        airlineCompanyName.text = airlineCompanyNameSegue
        aircraftModel.text = aircraftModelSegue
        departureAirport.text = departureAirportSegue
        arrivalAirport.text = arrivalAirportSegue
        flightTime.text = flightTimeSegue
        notes.text = notesSegue
    }
    
    func ConfigureMapView() {
        // MapView Configure
        mapKitView.delegate = self
        mapKitView.showsScale = true
        
        // Departure/Arrival location Setup
        
        // Variables for coordinates
        let sourceCoordinates = CLLocationCoordinate2D(latitude: departureAirportLatSegue, longitude: departureAirportLngSegue)
        let destCoordinates = CLLocationCoordinate2D(latitude: arrivalAirportLatSegue, longitude: arrivalAirportLngSegue)
        
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
        sourceAnnotation.coordinate = CLLocationCoordinate2D(latitude: departureAirportLatSegue, longitude: departureAirportLngSegue)
        sourceAnnotation.title = departureAirportSegue
        mapKitView.addAnnotation(sourceAnnotation)
        
        // Arrival Airport Point's location and title
        destAnnotation.coordinate = CLLocationCoordinate2D(latitude: arrivalAirportLatSegue, longitude: arrivalAirportLngSegue)
        destAnnotation.title = arrivalAirportSegue
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
}
