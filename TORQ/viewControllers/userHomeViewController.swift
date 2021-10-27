import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class userHomeViewController: UIViewController {
    
        

    //MARK: - Variables
    var userEmail: String?
    var userID: String?
    let locationManager = CLLocationManager()
    let ref = Database.database().reference()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()

  
    }
    
    //MARK: - Functions
    
    func configureLocationManager(){
        
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
    @IBAction func addEmergencyContactPressed(_ sender: Any){
        goToAddEmergencyContactScreen()
    }
    func goToAddEmergencyContactScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addEmergencyContactViewController") as! addEmergencyContactViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addMedicalReportPressed(_ sender: Any) {
        goToAddMedicalReportScreen()
    }
    func goToAddMedicalReportScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addMedicalReportViewController") as! addMedicalReportViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}

//MARK: - Extensions
extension userHomeViewController: CLLocationManagerDelegate{
    
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
        let time = locations.last?.timestamp
        print("longitude: \(String(describing: longitude!))")
        print("latitude: \(String(describing: latitude!))")
        print("time: \(String(describing: time!))")
        ref.child("Sensor").child("S\(userID!)/longitude").setValue((String(describing: longitude!)))
        ref.child("Sensor").child("S\(userID!)/latitude").setValue((String(describing: latitude!)))
        ref.child("Sensor").child("S\(userID!)/time").setValue((String(describing: time!)))
    }
    
}
