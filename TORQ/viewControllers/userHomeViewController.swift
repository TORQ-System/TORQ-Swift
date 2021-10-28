import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class userHomeViewController: UIViewController {
    
        
    //MARK: - @IBOutlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var medicalReportContainer: UIView!
    @IBOutlet weak var profileBorader: UIView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var userFullName: UILabel!
    

    //MARK: - Variables
    var userEmail: String?
    var userID: String?
    let locationManager = CLLocationManager()
    let ref = Database.database().reference()
    let services = ["Medical Information","Emergency Contact","View Accidents History"]
    let center = UNUserNotificationCenter.current()
    var user: User? = nil

    
    // MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
        retreieveUser()
        }
        configureNotification()
        registerToNotifications(userID: userID!)
        notifyEmergencyContact(userID: userID!)
        configureLocationManager()
        configureLayout()
    }
    
    //MARK: - Functions
    private func retreieveUser(){
            ref.child("User").observe(.value) { snapshot in
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                    let email = obj.childSnapshot(forPath: "email").value as! String
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    let gender = obj.childSnapshot(forPath: "gender").value as! String
                    let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                    let password = obj.childSnapshot(forPath: "password").value as! String
                    let phone = obj.childSnapshot(forPath:  "phone").value as! String
                    if obj.key == self.userID {
                        self.user = User(dateOfBirth: dateOfBirth,          email: email, fullName: fullName, gender:        gender, nationalID: nationalID, password:      password, phone: phone)
                            self.userFullName.text = fullName
                    }
                }
            }
    }
    
    
     func configureNotification(){
         self.center.delegate = self
        center.getNotificationSettings { setting in
            guard setting.authorizationStatus == .authorized else {
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    guard success else{
                        print("The user has not authorized")
                        return
                    }
                }
                return
            }
        }
    }
    
    private func configureLayout(){
        topView.layer.cornerRadius = 50
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
        imageContainer.layer.cornerRadius = 100
        imageContainer.layer.masksToBounds = true
        profileContainer.layer.cornerRadius = 75
        profileContainer.layer.masksToBounds = true
        profileBorader.layer.borderColor = UIColor(red: 0.201, green: 0.344, blue: 0.584, alpha: 1).cgColor
        profileBorader.layer.borderWidth = 2
        profileBorader.layer.cornerRadius = 80
        medicalReportContainer.layer.cornerRadius = 20
        medicalReportContainer.layer.masksToBounds = true
        medicalReportContainer.backgroundColor = UIColor(red: 0.83921569, green: 0.33333333, blue: 0.42352941, alpha: 1)
        medicalReportContainer.layer.shadowColor = UIColor(red: 0.83921569, green: 0.33333333, blue: 0.42352941, alpha: 1).cgColor
        medicalReportContainer.layer.shadowOffset = CGSize(width: 0, height: 30)
        medicalReportContainer.layer.shadowOpacity = 0.35
        medicalReportContainer.layer.shadowRadius = 50
        medicalReportContainer.layer.masksToBounds =  false
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
    
    func showALert(message:String){
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
    
    @IBAction func menuPressed(_ sender: Any) {
        
    }
    
    
    
}



//MARK: - CLLocationManagerDelegate Extensions

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
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        ref.child("Sensor").child("S\(userID!)/longitude").setValue((String(describing: longitude!)))
        ref.child("Sensor").child("S\(userID!)/latitude").setValue((String(describing: latitude!)))
        ref.child("Sensor").child("S\(userID!)/time").setValue("\(hour):\(minutes):\(seconds)")
        ref.child("Sensor").child("S\(userID!)/date").setValue("\(year):\(month):\(day)")

    }
    
}

//MARK: - UICollectionViewDelegate Extensions
extension userHomeViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = UIViewController()
        
        switch indexPath.row {
        case 0:
            let viewVC = storyboard.instantiateViewController(identifier: "viewMedicalReportViewController") as! viewMedicalReportViewController
            viewVC.modalPresentationStyle = .fullScreen
            viewVC.userID = userID
            viewVC.user = user
            vc = viewVC
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            print("unKnown")
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}




//MARK: - UICollectionViewDataSource Extensions

extension userHomeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "servicesCell", for: indexPath) as! servicesCollectionViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor(red: 0.659, green: 0.835, blue: 0.906, alpha: 1).cgColor
        cell.layer.shadowOffset = CGSize(width: 15, height: 5)  //Here you control x and y
        cell.layer.shadowOpacity = 0.35
        cell.layer.shadowRadius = 10 //Here your control your blur
        cell.layer.masksToBounds =  false
        cell.serviceLabel.text = services[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.serviceImage.image = UIImage(imageLiteralResourceName: "pulse")
        case 1:
            cell.serviceImage.image = UIImage(imageLiteralResourceName: "telephone")
        case 2:
            cell.serviceImage.image = UIImage(imageLiteralResourceName: "clock")
        default:
            print("unknown")
        }
        return cell
    }
}

