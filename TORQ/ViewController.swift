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
        guard CLLocationManager.locationServicesEnabled() else {
            //show alert.
            self.showALert(message: "the location services isn't enabled")
            return
        }
        
        
    }
    
    //MARK: - Functions
    func showALert(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    //MARK: - @IBActions


}

//MARK: - Extensions
extension ViewController: CLLocationManagerDelegate{
    
}

