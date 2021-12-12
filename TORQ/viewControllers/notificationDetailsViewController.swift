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
import SCLAlertView
import FloatingPanel

class notificationDetailsViewController: UIViewController, FloatingPanelControllerDelegate {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Variables
    var notificationDetails: notification!
    var assignedRequest: Request!
    
    //MARK: - Constants
    let ref = Database.database().reference()
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequest()
        
        let floatingPanel = FloatingPanelController()
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -16)
        shadow.radius = 32
        shadow.spread = 16
        appearance.shadows = [shadow]
        
        appearance.cornerRadius = 30
        appearance.backgroundColor = .white
        
        floatingPanel.surfaceView.appearance = appearance
        floatingPanel.delegate = self
        
        guard let detailsCard = storyboard?.instantiateViewController(withIdentifier: "notificationDetailsCardViewController") as? notificationDetailsCardViewController else {
            return
        }
        
        detailsCard.notificationDetails = notificationDetails
        detailsCard.assignedRequest = assignedRequest
        floatingPanel.layout = BottomCustomFloatingPanelLayout()
        floatingPanel.invalidateLayout()
        floatingPanel.set(contentViewController: detailsCard)
        floatingPanel.addPanel(toParent: self)
    }
    
    //MARK: - Functions
    func configureMapView(lat: Double, long: Double){
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long)))
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 1200, longitudinalMeters: 1200)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = "Accident"
        annotation.subtitle = "\(notificationDetails.getType())"
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func getRequest(){
        ref.child("Request").observeSingleEvent(of: .value) { snapshot in
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
                
                if self.notificationDetails.getRequestID() == request_id{
                    self.assignedRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    self.configureMapView(lat: Double(latitude)!, long: Double(longitude)!)
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

class BottomCustomFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(fractionalInset: 0.55, edge: .bottom, referenceGuide: .safeArea),
            .tip:  FloatingPanelLayoutAnchor(fractionalInset: 0.2, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}


