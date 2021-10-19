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
    var myContacts: [emergencyContact] = []

    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        registerToNotifications(userID: userID!)

  
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
    
    
    //MARK: - @IBActions
    
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
    
    @IBAction func sendNotification(_ sender: Any) {

        // we had to create two threads because we can't assure that the update segment of code will always be executed after the searching code segment , to avoid such a situation we created queue for searching and queue for updating that will work Syncronously.
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        let updateQueue = DispatchQueue.init(label: "updateQueue")
        
        searchQueue.sync {
            //1-  get my emergency contact.
            self.ref.child("EmergencyContact").observeSingleEvent(of: .value) { snapshot in
//                print(snapshot.value as! [String: Any])
                                
                for contact in snapshot.children{
                    let obj = contact as! DataSnapshot
                    let relation = obj.childSnapshot(forPath: "relation").value as! String
                    let contactId = obj.childSnapshot(forPath: "contactID").value as! Int
                    let name = obj.childSnapshot(forPath: "name").value as! String
                    let phone = obj.childSnapshot(forPath: "phone").value as! String
                    let senderID = obj.childSnapshot(forPath: "sender").value as! String
                    let receiverID = obj.childSnapshot(forPath: "reciever").value as! String
                    let sent = obj.childSnapshot(forPath: "sent").value as! String
                    let msg = obj.childSnapshot(forPath: "msg").value as! String
                    //create a EC object
                    let emergencyContact = emergencyContact(name: name, phone_number: phone, senderID:senderID, recieverID: receiverID, sent: sent, contactID: contactId, msg: msg, relation: relation)
                    
                    if (emergencyContact.getSenderID()) == self.userID{
//                        print("inside if statement")
                        //add it to the myContacts array
//                        self.myContacts.append(emergencyContact)
                        
                        updateQueue.sync {
                            //2- update thier sent attribute form No to Yes.
//                            print(obj.key)
                            
                            self.ref.child("EmergencyContact").child(obj.key).updateChildValues(["sent": "Yes"]) {(error, ref) in
                              if let error = error {
                                print("Data could not be saved: \(error.localizedDescription).")
                              } else {
//                                print("Data updated successfully!")
                              }
                            }
                        }
                    }
//                    print("printing the global array in : \(self.myContacts)")
                }
//                print("printing the global array out : \(self.myContacts)")
            }
        }
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
//        print("longitude: \(String(describing: longitude!))")
//        print("latitude: \(String(describing: latitude!))")
//        print("time: \(String(describing: time!))")
        ref.child("Sensor").child("S\(userID!)/longitude").setValue((String(describing: longitude!)))
        ref.child("Sensor").child("S\(userID!)/latitude").setValue((String(describing: latitude!)))
        ref.child("Sensor").child("S\(userID!)/time").setValue((String(describing: time!)))
    }
    
}
