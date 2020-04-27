import Foundation
import CoreLocation


struct LocationModel {
    
    let latitude: Double
    
    let longitude: Double
    
    let altitude: Double
    
    let floorLevel: Int?
    
    let horizontalAccuracy: Double
    
    let verticalAccuracy: Double
    
    let timestamp: Double // timeIntervalSinceReferenceDate
    
    
    init(from coreLocation: CLLocation) {
        self.latitude = coreLocation.coordinate.latitude
        self.longitude = coreLocation.coordinate.longitude
        self.altitude = coreLocation.altitude
        self.horizontalAccuracy = coreLocation.horizontalAccuracy
        self.verticalAccuracy = coreLocation.verticalAccuracy
        self.timestamp = coreLocation.timestamp.timeIntervalSinceReferenceDate
        self.floorLevel = coreLocation.floor?.level
    }
    
}
