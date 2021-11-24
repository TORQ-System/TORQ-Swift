import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class paramedicHomeViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    
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
    
    //MARK: - Functions
    func showALert(message:String){
        //show alert based on the message that is being paased as parameter
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func goToLoginScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! loginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - @IBActions
    @IBAction func viewRequestsPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "viewRequests") as! requestsViewController
        vc.loggedInCenterEmail = self.loggedinEmail
        print("home: \(String(describing: loggedinEmail))")
        print("home: \(String(describing: vc.loggedInCenterEmail))")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            let userDefault = UserDefaults.standard
            userDefault.setValue(false, forKey: "isUserSignedIn")
            goToLoginScreen()
        } catch let error {
            self.showALert(message: error.localizedDescription)
        }
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
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        location["lon"] = String(describing: longitude!)
        location["lat"] = String(describing: latitude!)
        ref.child("Paramedic").child("S\(loggedinEmail!)/longitude").setValue((String(describing: longitude!)))
        ref.child("Paramedic").child("S\(loggedinEmail!)/latitude").setValue((String(describing: latitude!)))
        ref.child("Paramedic").child("S\(loggedinEmail!)/time").setValue("\(hour):\(minutes):\(seconds)")
        ref.child("Paramedic").child("S\(loggedinEmail!)/date").setValue("\(year):\(month):\(day)")
    }
    
}
