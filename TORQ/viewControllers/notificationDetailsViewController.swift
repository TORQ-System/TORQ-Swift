//
//  notificationDetailsViewController.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 25/11/2021.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class notificationDetailsViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var requestStatus: UIView!
    @IBOutlet weak var activeRequest: UIButton!
    @IBOutlet weak var cancelledRequest: UIButton!
    @IBOutlet weak var processedRequest: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var viewLocationButtonView: UIView!
    @IBOutlet weak var cancelButton: UIView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var from: UILabel!
    
    //MARK: - Variables
    var notificationDetails: notification!
    var assignedRequest: Request!
    
    //MARK: - Constants
    let ref = Database.database().reference()
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequest()
        configureDetailsView()
        
        if(notificationDetails.getType() == "emergency"){
            self.ref.child("User").getData(completion:{error, snapshot in
                guard error == nil else { return }
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                    let email = obj.childSnapshot(forPath: "email").value as! String
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    let gender = obj.childSnapshot(forPath: "gender").value as! String
                    let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                    let password = obj.childSnapshot(forPath: "password").value as! String
                    let phone = obj.childSnapshot(forPath:  "phone").value as! String
                    if obj.key == self.notificationDetails.getSender() {
                        print(fullName)
                        DispatchQueue.main.async() {
                            self.from.text = fullName
                        }
                    }
                }
            })
        }
    }
    
    //MARK: - Functions
    func configureMapView(){
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(assignedRequest.getLatitude())!), longitude: CLLocationDegrees(Double(assignedRequest.getLongitude())!)))
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = "Accident"
        annotation.subtitle = "\(notificationDetails.getType())"
        
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func configureDetailsView(){
        detailsView.layer.cornerRadius = 70
        detailsView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        detailsView.layer.shouldRasterize = true
        detailsView.layer.rasterizationScale = UIScreen.main.scale
        detailsView.layer.shadowColor = UIColor.black.cgColor
        detailsView.layer.shadowOffset = CGSize(width: 0, height: -30)
        detailsView.layer.shadowRadius = 40
        detailsView.layer.shadowOpacity = 0.4
        detailsView.layer.masksToBounds = false
        
        notificationTitle.text = notificationDetails.getTitle()
        body.text = notificationDetails.getBody()
        
        if notificationDetails.getType() == "emergency"{
            subtitle.isHidden = true
            //            updateFrom()
            
        } else {
            from.text = "TORQ"
            subtitle.text = notificationDetails.getSubtitle()
        }
        
        date.text = notificationDetails.getDate()
        time.text = notificationDetails.getTime()
        
    }
    
    func configureRequestStatus(){
        detailsView.layer.cornerRadius = 70
        detailsView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        detailsView.layer.shouldRasterize = true
        detailsView.layer.rasterizationScale = UIScreen.main.scale
        detailsView.layer.shadowColor = UIColor.black.cgColor
        detailsView.layer.shadowOffset = CGSize(width: 0, height: -30)
        detailsView.layer.shadowRadius = 40
        detailsView.layer.shadowOpacity = 0.4
        detailsView.layer.masksToBounds = false
    }
    
    func updateFrom(){
        
    }
    
    func getRequest(){
        ref.child("Request").observe(.value) { snapshot in
            for request in snapshot.children{
                let obj = request as! DataSnapshot
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                let request_id = obj.childSnapshot(forPath: "request_id").value as! String
                let rotation = obj.childSnapshot(forPath: "rotation").value as! String
                let sensor_id = obj.childSnapshot(forPath: "sensor_id").value as! String
                let status = obj.childSnapshot(forPath: "status").value as! String
                let time_stamp = obj.childSnapshot(forPath: "time_stamp").value as! String
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                let vib = obj.childSnapshot(forPath: "vib").value as! String
                
                let request = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                
                if (self.notificationDetails.getType() == "wellbeing" && self.notificationDetails.getRequestID() == request.getRequestID()){
                    print(request)
                    self.assignedRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    self.configureMapView()
                    self.configureRequestStatus()
                    
                }
                if (self.notificationDetails.getType() == "emergency" && self.notificationDetails.getSender() == request.getUserID() && request.getStatus() == "0" ){
                    print(request)
                    self.assignedRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    self.configureMapView()
                    self.configureRequestStatus()
                    
                }
            }
        }
    }
    
    //MARK: - @IBActions
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
//MARK: - Extensions
extension notificationDetailsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation)else{
            return nil
        }
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "requestPin")
        if pin == nil {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "requestPin")
            pin?.canShowCallout = true
            pin?.image = UIImage(named: "Vector")
            pin?.frame.size = CGSize(width: 27, height: 40)
        } else{
            pin?.annotation = annotation
        }
        return pin
    }
}
