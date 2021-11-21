import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import SCLAlertView

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
    @IBOutlet weak var medicalQR: UIImageView!
    @IBOutlet weak var rotation: UILabel!
    @IBOutlet weak var vib: UILabel!
    @IBOutlet weak var coordinate: UILabel!
    @IBOutlet weak var temprature: UILabel!
    @IBOutlet weak var lastLoggedIn: UILabel!
    

    //MARK: - Variables
    var userEmail: String?
    var userID: String?
    let locationManager = CLLocationManager()
    let ref = Database.database().reference()
    let services = ["Medical Information","Emergency Contact","View Accidents History","SOS Request"]
    let center = UNUserNotificationCenter.current()
    var user: User? = nil
    var location: [String: String] = ["lon":"","lat":""]
    var sensor: Sensor?
    
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)

    
    // MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            retreieveUser()
            retrieveSensorInfo()
            getTemprature()

        }
        configureNotification()
        registerToNotifications(userID: userID!)
        notifyEmergencyContact(userID: userID!)
        configureLocationManager()
        configureLayout()
    }
    
    //MARK: - Functions
    private func medicalQRCode(){
        let dic = ["First Name: ":"Noura","Last Name":"Alsulayfih"]
        do {
            let jsonData = try JSONEncoder().encode(dic)
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(jsonData, forKey: "inputMessage")
                let transfrom = CGAffineTransform(scaleX: 10, y: 10)
                
                if let output = filter.outputImage?.transformed(by: transfrom){
                    medicalQR.image = UIImage(ciImage: output)
                }else{
                    print("output is nil")

                }
            }else{
                print("filter is nil")
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    
    
    private func getTemprature(){
        let url = URL(string: "https://samples.openweathermap.org/data/2.5/weather?id=108410&appid=8604f94e4b02f8cc4277f8cdd151721d")!
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let error = error {
                print("error")
                print(error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
            }

            guard let data = data else {
                print("data")
                print(error!.localizedDescription)
                return
            }

            guard let dictionaryObj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("dictionaryObj")
                print(error!.localizedDescription)
                return
            }
            if let main = dictionaryObj["main"] as? [String: Any], let temp = main["temp"] {
                DispatchQueue.main.async {
                    let celsiusTemp = (temp as! Double) - 273.15
                    let t = Measurement(value: celsiusTemp , unit: UnitTemperature.celsius)
                    self.temprature.text = "\(t)"
                    print("temp: \(celsiusTemp)")
                }
            }
            print("end")
        }).resume()
    }
    
    
    private func retrieveSensorInfo(){
        ref.child("Sensor").observe(.value) { snapshot in
            for sensor in snapshot.children{
                let obj = sensor as! DataSnapshot
                let vib = obj.childSnapshot(forPath: "Vib").value as! String
                let x = obj.childSnapshot(forPath: "X").value as! String
                let y = obj.childSnapshot(forPath: "Y").value as! String
                let z = obj.childSnapshot(forPath: "Z").value as! String
                let date = obj.childSnapshot(forPath: "date").value as! String
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                let time = obj.childSnapshot(forPath:  "time").value as! String
                let sensorID = obj.key
//                print("S\(String(describing: self.userID!))")
                if sensorID == "S\(String(describing: self.userID!))" {
                    self.vib.text = "\(vib) Hz"
                    if y == "1023" {
                        self.rotation.text = "Yes"

                    }else{
                        self.rotation.text = "No"

                    }
                    let lat = Double(latitude)!
                    let divisor = pow(10.0, Double(6))
                    let latt = round(lat * divisor) / divisor //rounded latitude
                    
                    let lon = Double(longitude)!
                    let divisorr = pow(10.0, Double(6))
                    let lonn = round(lon * divisorr) / divisorr //rounded longitude
                    
                    
                    self.coordinate.text = "\(lonn), \(latt)"
//                    let newDate = date.replacingOccurrences(of: ":", with: "/")
                    self.sensor = Sensor(vib: vib, x: x, y: y, z: z, date: date, latitude: latitude, longitude: latitude, time: time)
                }else{
//                    print("no sensor")
                }
                
            }
        }
    }
    
    
    
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
        location["lon"] = String(describing: longitude!)
        location["lat"] = String(describing: latitude!)
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
            let viewVC = storyboard.instantiateViewController(identifier: "ViewEmergencyContactViewController") as! ViewEmergencyContactViewController
            viewVC.modalPresentationStyle = .fullScreen
            viewVC.userID = userID
            vc = viewVC
            break
        case 3:
            let viewVC = storyboard.instantiateViewController(identifier: "SOSRequestViewController") as! SOSRequestViewController
            viewVC.modalPresentationStyle = .fullScreen
            viewVC.longitude = location["lon"]
            viewVC.latitude = location["lat"]
            vc = viewVC
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
        cell.layer.shadowRadius = 10
        cell.layer.masksToBounds =  false
        cell.serviceLabel.text = services[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.serviceImage.image = UIImage(imageLiteralResourceName: "pulse")
        case 1:
            cell.serviceImage.image = UIImage(imageLiteralResourceName: "telephone")
        case 2:
            cell.serviceImage.image = UIImage(imageLiteralResourceName: "clock")
        case 3:
            cell.serviceImage.image = UIImage(imageLiteralResourceName: "sos")
        default:
            print("unknown")
        }
        return cell
    }
}

