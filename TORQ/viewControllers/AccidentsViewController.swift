import UIKit
import MapKit
import Firebase

class AccidentsViewController: UIViewController {

    //MARK: - Varibales
    var ref = Database.database().reference()
    var accidentRequests: [Request] = []
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Overriden Functions
    override func viewWillAppear(_ animated: Bool) {
        retreiveAccidents()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        print("view did load\(accidentRequests)")
    }
    
    //MARK: - Functions
    private func retreiveAccidents(){
        
        let fetchQueue = DispatchQueue.init(label: "fetch")
        fetchQueue.sync {
            ref.child("Request").observe(.value) { snapshot in
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
                    print(request)
                    self.accidentRequests.append(request)
                }
            }
            print(accidentRequests)
        }
    }
    
    //MARK: - @IBActions
}


   //MARK: - Map View Delegate Extension
extension AccidentsViewController: MKMapViewDelegate{
    
}
