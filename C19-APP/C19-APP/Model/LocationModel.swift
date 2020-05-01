import Foundation
import CoreLocation


struct LocationModel {
    
    let timestamp: Int // timeIntervalSinceReferenceDate
    
    let hashString: String
    
    var precision: Int {
        get {
            hashString.count
        }
    }
    
    init(from loc: CLLocation, length: Int) {
        self.hashString = loc.coordinate.geohash(length: length)
        self.timestamp = Int(loc.timestamp.timeIntervalSinceReferenceDate)
    }
    
    init(from timestamp: Int, geohash: String) {
        self.hashString = geohash
        self.timestamp = timestamp
    }
        
}
