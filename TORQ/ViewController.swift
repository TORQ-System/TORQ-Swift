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
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        guard CLLocationManager.locationServicesEnabled() else {
            //show alert.
            self.showALert(message: "the location services isn't enabled")
            return
        }
        locationManager.requestAlwaysAuthorization()
        
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        
        case .authorizedAlways:
            print("authorizedAlways")
            locationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            locationManager.startUpdatingLocation()
            
        case .denied:
            print("denied")
             showALert(message: "Location access is needed to get your current location")

        case .notDetermined:
            print("notDetermined")

        case .restricted:
            print("restricted")
            
        default:
            print("unknown")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
}
