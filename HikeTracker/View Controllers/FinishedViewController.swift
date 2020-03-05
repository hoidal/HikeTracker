//
//  FinishedViewController.swift
//  HikeTracker
//
//  Created by Sam Hoidal on 3/4/20.
//  Copyright © 2020 Sam Hoidal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class FinishedViewController: UIViewController {
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var altitudeGainLabel: UILabel!
    @IBOutlet weak var altitudeLossLabel: UILabel!
    @IBOutlet weak var mapTypeControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var timeElapsed = 0
    var distanceTravelled = Measurement(value: 0, unit: UnitLength.meters)
    var polylineCoordinates: [CLLocation] = []
    var altitudeGain = 0
    var altitudeLoss = 0
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFinalView()
    }
   
    func initializeFinalView() {
        let formattedDistance = FormatDisplay.distance(distanceTravelled)
        let formattedTime = FormatDisplay.time(timeElapsed)
        let formattedPace = FormatDisplay.pace(distance: distanceTravelled, seconds: timeElapsed, outputUnit: UnitSpeed.minutesPerMile)
               
        totalTimeLabel.text = "\(formattedTime)"
        totalDistanceLabel.text = "\(formattedDistance)"
        averagePaceLabel.text = "\(formattedPace)"
        altitudeGainLabel.text = "\(altitudeGain)"
        altitudeLossLabel.text = "\(altitudeLoss)"
       
        loadMap()
    }
   
    func loadMap() {
        let region = mapRegion()
       
        mapView.delegate = self
        mapView.setRegion(region!, animated: true)
        renderPolyline()
        renderAnnotations()
    }
   
    func mapRegion() -> MKCoordinateRegion? {
        let latitudes = polylineCoordinates.map { location -> Double in
            return location.coordinate.latitude
        }
       
        let longitudes = polylineCoordinates.map { location -> Double in
            return location.coordinate.longitude
        }
       
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLon = longitudes.max()!
        let minLon = longitudes.min()!

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                         longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                 longitudeDelta: (maxLon - minLon) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
   
    func renderPolyline() {
        let hikeCoordinates = polylineCoordinates.map { location -> CLLocationCoordinate2D  in
            return location.coordinate
        }
       
        let hikePolyline = MKPolyline(coordinates: hikeCoordinates, count: hikeCoordinates.count)
       
        mapView.addOverlay(hikePolyline)
    }
   
    func renderAnnotations() {
        let startLocation = MKPointAnnotation()
        startLocation.title = "Start"
        startLocation.subtitle = "Start"
        startLocation.coordinate = polylineCoordinates.first!.coordinate
        mapView.addAnnotation(startLocation)
       
        let endLocation = MKPointAnnotation()
        endLocation.title = "End"
        endLocation.subtitle = "End"
        endLocation.coordinate = polylineCoordinates.last!.coordinate
        mapView.addAnnotation(endLocation)
    }
    
    
    @IBAction func viewChanged(_ sender: UISegmentedControl) {
        switch mapTypeControl.selectedSegmentIndex
            {
            case 0:
                mapView.mapType = .standard
            case 1:
                mapView.mapType = .satellite
            case 2:
                mapView.mapType = .hybrid
            default:
                break
            }
    }
    
    
}


extension FinishedViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let lineRenderer = MKPolylineRenderer(polyline: polyline)
        lineRenderer.strokeColor = .systemBlue
        lineRenderer.lineWidth = 4
        return lineRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")

        guard let annotationName = annotation.title else {return nil}


        if annotationName == "Start" {
            annotationView.pinTintColor = UIColor.green
        } else if annotationName == "End" {
            annotationView.pinTintColor = UIColor.red
        }
        return annotationView
    }
}
