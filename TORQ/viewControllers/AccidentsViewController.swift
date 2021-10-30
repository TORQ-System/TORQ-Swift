import UIKit
import MapKit
import Firebase

class AccidentsViewController: UIViewController {

    //MARK: - Varibales
    var ref = Database.database().reference()
    var accidentRequests: [Request] = []
    var locationManager = CLLocationManager()
    var longitude: Double = 0
    var latitude: Double = 0
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Overriden Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        retreiveAccidents()
//        print("view did load\(accidentRequests)")
    }
    
    //MARK: - Functions
    private func retreiveAccidents() -> Void{
        
        DispatchQueue.global(qos: .background).sync{
            ref.child("Request").observe(.value) { snapshot in
                print(snapshot.value!)
                for req in snapshot.children{
                    let obj = req as! DataSnapshot
                    let userID = obj.childSnapshot(forPath: "user_id").value as! String
                    let sensorID = obj.childSnapshot(forPath: "sensor_id").value as! String
                    let requestID = obj.childSnapshot(forPath: "request_id").value as! String
                    let timeStamp = obj.childSnapshot(forPath: "time_stamp").value as! String
                    let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                    let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                    let vib = obj.childSnapshot(forPath: "vib").value as! String
                    let rotation = obj.childSnapshot(forPath: "rotation").value as! String
                    let status = obj.childSnapshot(forPath: "status").value as! String
                    let request = Request(user_id: userID, sensor_id: sensorID, request_id: requestID, dateTime: timeStamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    self.accidentRequests.append(request)
                }
                print("printing after for: \(self.accidentRequests)")
                self.showMyLocation()
            }
        }
    }
    
    
    func setPinUsingMKPlacemark() {
        
        for r in self.accidentRequests {
            let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(r.getLatitude())!, longitude: CLLocationDegrees(r.getLongitude())!))
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = "Accident"
            annotation.subtitle = "if you're near them help!"
            mapView.addAnnotation(annotation)
        }
    }
    
    
    private func showMyLocation(){
        let viewRegion = MKCoordinateRegion.init(center: .init(latitude: CLLocationDegrees(locationManager.location!.coordinate.latitude), longitude: CLLocationDegrees(locationManager.location!.coordinate.longitude)), latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(viewRegion, animated: true)
        setPinUsingMKPlacemark()
    }
    
    //MARK: - @IBActions
}


   //MARK: - Map View Delegate Extension
extension AccidentsViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation)else{
            return nil
        }
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "accidentView")
        if pin == nil {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "accidentView")
            pin?.canShowCallout = true
        }else{
            pin?.annotation = annotation
        }
        let img = UIImageView(image: UIImage(named: "pin"))
        img.tintColor = .blue
        pin?.image = img.image
//        pin?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pin
    }
    
    
    
}

//MARK: - CLLocationManagerDelegate Extension
extension AccidentsViewController: CLLocationManagerDelegate{
    
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
        self.longitude = longitude!.magnitude
        self.latitude = latitude!.magnitude
    }
    
}
