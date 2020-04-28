import Foundation
import CoreLocation
import os


class LocationManager: NSObject {
    
    private var locations: [LocationModel] = []
    
    static var instance = LocationManager()
    
    private var coreLocationManager = CLLocationManager()
    
    private var locationServicesEnabled: Bool {
        get {
            return CLLocationManager.locationServicesEnabled()
        }
    }
    
    private var locationServicesAuthorized: Bool {
        get {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways:
                return true
            default:
                return false
            }
        }
    }
    
    override private init() {
        super.init()
        coreLocationManager.delegate = self
    }
    
    
    
    func startRecordingLocation() {
        if !locationServicesAuthorized {
            coreLocationManager.requestAlwaysAuthorization()
        }
        coreLocationManager.startUpdatingLocation()
        

        // setup database

    }
    
    
    func stopRecordingLocation() {
        coreLocationManager.startUpdatingLocation()
    }
    
}



extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            os_log("Authorization granted")
            startRecordingLocation()
        default:
            os_log("Authorization for usealways denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.locations.append(LocationModel(from: location))
        }
    }

    
}
