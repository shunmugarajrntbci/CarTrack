//
//  ViewController.swift
//  CabTrack
//
//  Created by RNTBCI45 on 09/03/18.
//  Copyright © 2018 rntbci. All rights reserved.
//

import UIKit
import GoogleMaps
import JLocationKit
import FAPanels

class CabTrackController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    var iTemp:Int = 0
    var marker = GMSMarker()
    var timer = Timer()
    fileprivate var coordinate: CLLocation?
    let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 22.857165, longitude: 77.354613, zoom: 12.0)
    var notes: [[String:String]] = []
    var pauseUpdating: Bool = false
    
    @IBAction func toggleMenu(_ sender: Any) {
        
        let rootController: FAPanelController = UIApplication.shared.windows.first?.rootViewController as! FAPanelController
        rootController.openLeft(animated: true)
        
    }
    @IBAction func zoom(_ sender: UIStepper) {
        updateMapFrame(newLocation: coordinate!, zoom: Float(sender.value))
    }
    @IBOutlet weak var zoomStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.bringSubview(toFront: zoomStepper)
        pageSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pauseUpdating = false
    }
    
    func pageSetUp()  {
        mapView.delegate = self
        mapView.camera = camera
        mapView.settings.compassButton = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addGeotification" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeotificationViewController
            vc.delegate = self
            vc.carLocation = coordinate
            pauseUpdating = true
//        }
    }
}

extension CabTrackController {
    
    //marker move on map view
    func plotCar(location: CLLocation)
    {
        if pauseUpdating {
            return
        }
        updateMapFrame(newLocation: location, zoom: self.mapView.camera.zoom)
        marker.position = location.coordinate
        coordinate = location
        if let _ = marker.icon, let _ = marker.map {
            return
        }
        marker.icon = UIImage(named: "cab.png")
        marker.map = mapView
    }
    

    
    //Zoom map with cordinate
    func updateMapFrame(newLocation: CLLocation, zoom: Float) {
        
        let camera = GMSCameraPosition.camera(withTarget: newLocation.coordinate, zoom: zoom)
        self.mapView.animate(to: camera)
        marker.rotation = newLocation.course
    }
}

extension CabTrackController: AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
       
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        marker.icon = UIImage(named: "AddPin.png")
        marker.infoWindowAnchor = CGPoint.init(x: 0.5, y: 0.2)
        marker.accessibilityLabel = "Beacon"
        let geoCircle = GMSCircle.init(position: coordinate, radius: radius)
        geoCircle.fillColor = UIColor.init(white: 0.7, alpha: 0.25)
        geoCircle.map = mapView
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let jlocation = JLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius, identifier: identifier)
        notes.append([identifier : note])
        delegate?.addRegionMonitoring(location: jlocation)
    }
}


