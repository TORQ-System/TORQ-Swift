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
    
    //MARK: - Variables
    var notificationDetails: notification!
    var assignedRequest: Request!
    
    //MARK: - Constants
    let ref = Database.database().reference()
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequest()
        print(notificationDetails!)
        // Do any additional setup after loading the view.
        configureDetailsView()
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
                }
                if (self.notificationDetails.getType() == "emergency" && self.notificationDetails.getSender() == request.getUserID() && request.getStatus() == "0" ){
                    print(request)
                    self.assignedRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    self.configureMapView()
                }
            }
        }
    }
    
    //MARK: - @IBActions
    
    
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
