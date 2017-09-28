//
//  MapViewController.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 27/06/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit
import MapKit

// The MapViewController provides functionality for showing found results on the map.
class MapViewController: UIViewController, TheaterModelDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!

    var theaters = [Theater]()
    var model:TheaterModel?
    var locationManager:CLLocationManager?
    var lastKnownLocation:CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set map properties
        mapView.showsUserLocation = true
        
        // Instantiate location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        // Instantiate TheaterModel
        if model == nil {
            model = TheaterModel()
            model?.delegate = self
        }
    
        model?.getTheaters()
    }
    
    
    // Event handler for pressing the location cursor button
    @IBAction func locButtonPressed(_ sender: Any) {
        
        // Check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            
            // Location services are enabled, check authorization status
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                // Permission granted
                locationManager?.startUpdatingLocation()
                
                // Center the map on last location
                if let actualLocation = lastKnownLocation {
                    mapView.setCenter(actualLocation.coordinate, animated: true)
                }
            }
            else if status == .denied || status == .restricted {
                // Doesn't have permission
                // Tell user to check settings
                displaySettingsPopup()
            }
            else if status == .notDetermined {
                // Ask the user for permission
                locationManager?.requestWhenInUseAuthorization()
            }
        }
        else {
            // Location services are turned off
            // Tell user to check settings
            displaySettingsPopup()
        }
    }


    // Theater Model delegate method
    func theaterModel(listOf theaters: [Theater]) {
        self.theaters = theaters
        plotPins()
    }
    
    
    // Take coordinates of each theater and draw its pin on the map
    func plotPins () {
    
        var pinsArray = [MKPointAnnotation]()
        
        for p in theaters {
            
            let pin = MKPointAnnotation()
        
            pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(p.lat), longitude: CLLocationDegrees(p.long))
            pin.title = p.name_ru
            
            mapView.addAnnotation(pin)
            pinsArray.append(pin)
        }
        mapView.showAnnotations(pinsArray, animated: true)
    }
    
    
    // Display settings dialogue to prompt user to check Location Services settings
    func displaySettingsPopup() {
     
        // Create alert controller
        let alertController = UIAlertController(title: "Не могу определить Ваше местоположение!", message: "На Вашем телефоне отключены Службы геолокации, или программе МосТеатр не разрешен доступ к геопозиции. Пожалуйста, проверьте настройки Служб геолокации на Вашем телефоне.", preferredStyle: .alert)
        
        // Create settings button action
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        
        alertController.addAction(settingsAction)
        
        // Create cancel button action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Display alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        let location = locations.last
        
        if let actualLocation = location {
            
            // Center the map only if it's the first time locating the user
            if lastKnownLocation == nil {
                mapView.setCenter(actualLocation.coordinate, animated: true)
            }
            
            // Save the pin
            lastKnownLocation = actualLocation
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // See what the user has chosen
        if status == .denied {
            // Tell user that the app does not have permission. The user can change settings if they want.
            displaySettingsPopup()
            
        }
        else if status == .authorizedAlways || status == .authorizedWhenInUse {
        
            // Permission granted
   //         locationManager?.startUpdatingLocation()
        }
    }
}

