import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import SCLAlertView

class paramedicHomeViewController: UIViewController {
    
    //MARK: - Variables
    var loggedinEmail: String!
    var location: [String: String] = ["lon":"","lat":""]

    
    //MARK: - Constants
    let locationManager = CLLocationManager()
    let ref = Database.database().reference()
    
    //MARK: - Overriden funtions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
    }
    
    func showALert(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func configureLocationManager(){
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        guard CLLocationManager.locationServicesEnabled() else {
            self.showALert(message: "the location services isn't enabled")
            return
        }
        locationManager.requestAlwaysAuthorization()
    }

}


//MARK: - CLLocationManagerDelegate Extensions

extension paramedicHomeViewController: CLLocationManagerDelegate{
    
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
            showALert(message: "Location access is needed to get your current location")
        default:
            print("unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let longitude = locations.last?.coordinate.longitude
        let latitude = locations.last?.coordinate.latitude
        location["lon"] = String(describing: longitude!)
        location["lat"] = String(describing: latitude!)
        ref.child("Paramedic").child("\(loggedinEmail!)/longitude").setValue((String(describing: longitude!)))
        ref.child("Paramedic").child("\(loggedinEmail!)/latitude").setValue((String(describing: latitude!)))
    }
    
}
