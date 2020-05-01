import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var qrImg: UIImageView!
    
    @IBAction func btnClick(_ sender: Any) {
        let dataString = DataStorageManager.shared.getHistoricalData()
        let qrCode = generateQRCode(from: dataString)
        self.qrImg.image = qrCode
    }
    
    
    fileprivate func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    

}

