//
//  AppDelegate.swift
//  CabTrack
//
//  Created by RNTBCI45 on 09/03/18.
//  Copyright © 2018 rntbci. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuthUI
//import SwiftLocation
import GoogleMaps
import JLocationKit
import FAPanels

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var ref: DocumentReference?
    var db : Firestore? = nil
    var window: UIWindow?
    var cabTrackController: CabTrackController!
    var locationList: [JLocation] = []
    let locationManager: LocationManager = LocationManager()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        db = Firestore.firestore()
        subscriptLocation()
        setupSideMenu()
        GMSServices.provideAPIKey("AIzaSyDYQ277wkxR988NFV5fejnhyil50-tH-w8")
        return true
    }
    
    func setupSideMenu() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let leftMenuVC: LeftMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        
        cabTrackController = mainStoryboard.instantiateViewController(withIdentifier: "CenterVC1") as! CabTrackController
        let centerNavVC = UINavigationController(rootViewController: cabTrackController)
        
        //  Set the Panel controllers with just two lines of code
        let rootController: FAPanelController = window?.rootViewController as! FAPanelController
        _ = rootController.center(centerNavVC).left(leftMenuVC)
        rootController.leftPanelPosition = .front
    }
}

extension AppDelegate {
    func updateDatabase(latitude: Float, longitude: Float, course: Float) {
        let userID = "NQiT317h54YClAKGU1ev"
        ref = db?.collection("Position").document(userID)
        // Set the "capital" field of the city 'DC'
        ref?.updateData([
            "Location" : [latitude, longitude, course]
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func subscriptLocation() {
        locationManager.requestAccess = .requestAlwaysAuthorization
        
        locationManager.getLocation(detectStyle: .UpdatingLocation, distanceFilter: 1, locationAccuracy: .Best, detectFrequency: 1, completion: { (loc) in
            DispatchQueue.main.async {
                print("New location received: \(loc)")
                self.cabTrackController?.plotCar(location: loc.currentLocation)
            }
            let lat = Float(loc.currentLocation.coordinate.latitude)
            let long = Float(loc.currentLocation.coordinate.longitude)
            let course = Float(loc.currentLocation.course)
            self.updateDatabase(latitude: lat, longitude: long, course: course)
        }, error: { (error) in
            //optional
        }
        )
    }
    
    func subscribeRegion() {
        
        locationManager.regionNotify(notifyStyle: .MonitoringRegion, locations: locationList, completion: { (region) in
            print(region.regionState.description())
            
        }, error: { (error) in
        }
        )
    }
    
    func addRegionMonitoring(location: JLocation) {
        let item:JLocation = JLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: location.locationRadius, identifier: location.locationIdentifier)
        locationList.append(item)
        subscribeRegion()
    }
}

