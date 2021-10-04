import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    //MARK: - @IBOutlets
    
    
    //MARK: - @Variables
    let locationManager = CLLocationManager()
    
    
    //MARK: - Overriden Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
    }
    
    //MARK: - Functions
    
    
    //MARK: - @IBActions


}

//MARK: - Extensions
extension ViewController: CLLocationManagerDelegate{
    
}

