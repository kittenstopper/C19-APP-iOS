import UIKit

class FirstViewController: UIViewController {
    
    
    
    @IBAction func btnAction(_ sender: Any) {
        LocationManager.instance.startRecordingLocation()
    }
    
    override func viewDidLoad() {
        LocationManager.instance.setDelegate(delegate: self)
    }
    
}


extension FirstViewController: LocationManagerDelegate {
    
    
    func didReceiveLocationUpdate(tenRecentGeohashes: [String]) {
        let newText = tenRecentGeohashes.joined(separator: "\n")
//        self.infoLabel.text = newText
        
    }
    
    
}
