import Foundation
import CoreLocation


struct LocationModel:Equatable {
    
    static func ==(lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.timestamp == rhs.timestamp && lhs.hashString == rhs.hashString
    }
        
    let timestamp: Int // timeIntervalSinceReferenceDate * 1000
    
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



extension Date {
    func toMillisecondsSinceReferenceDate() -> Double {
        return self.timeIntervalSinceReferenceDate * 1000.0
    }
}
    
extension Int {
    func toDate() -> Date {
        return Date(timeIntervalSinceReferenceDate: TimeInterval(self) / 1000)
    }
}
