import UIKit

class FirstViewController: UIViewController {
    
    
    @IBAction func btnAction(_ sender: Any) {
        LocationManager.instance.startRecordingLocation()
        DBHelper.shared.pruneOldRecords()
    }
    
    override func viewDidLoad() {
        LocationManager.instance.setDelegate(delegate: self)
    }
    
}


extension FirstViewController: LocationManagerDelegate {
    
    
    func didReceiveLocationUpdate(tenRecentGeohashes: [String]) {
        // Do nothing
    }
    
    
}
