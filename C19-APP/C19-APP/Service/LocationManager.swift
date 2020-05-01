import Foundation
import CoreLocation
import os


protocol LocationManagerDelegate: AnyObject {
    
    func didReceiveLocationUpdate(tenRecentGeohashes: [String])
}

struct LocationManagerConfiguration {
    static let capacity: Int = 10
}


class LocationManager: NSObject {
    
    private var recordingLocation: Bool = false
    
    private var geohashes: [String] = [] {
        didSet {
            if (geohashes.count > LocationManagerConfiguration.capacity) {
                geohashes = geohashes.suffix(10)
            }
            self.delegate?.didReceiveLocationUpdate(tenRecentGeohashes: geohashes)
        }
    }
    
    private weak var delegate: LocationManagerDelegate?
    
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
    
    
    func setDelegate(delegate: LocationManagerDelegate) {
        self.delegate = delegate
    }

    
    func startRecordingLocation() {
        recordingLocation = true
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
            if recordingLocation {
                coreLocationManager.startUpdatingLocation()
            }
        default:
            os_log("Authorization for usealways denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.geohashes.append(
                Geohash.encode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, length: 8)
            )
        }
    }

    
}
