import UIKit
import CoreLocation
import FirebaseDatabase

class ViewController: UIViewController {
    
    //MARK: - @IBOutlets
    
    
    //MARK: - @Variables
    let locationManager = CLLocationManager()
    let ref = Database.database().reference()
    let uID = "cj5oOVZ8Rrbzw3rqhKRsvLIWgZV2"
    
    
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
        let longitude = locations.last?.coordinate.longitude
        let latitude = locations.last?.coordinate.latitude
        let time = locations.last?.timestamp
        print("longitude: \(String(describing: longitude!))")
        print("latitude: \(String(describing: latitude!))")
        print("time: \(String(describing: time!))")
        ref.child("Sensor").child("Sensor1/longitude").setValue((String(describing: longitude!)))
        ref.child("Sensor").child("Sensor1/latitude").setValue((String(describing: latitude!)))
        ref.child("Sensor").child("Sensor1/time").setValue((String(describing: time!)))
    }
    
}

