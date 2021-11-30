//
//  viewLiveLocationViewController.swift
//  TORQ
//
//  Created by Norua Alsalem on 29/11/2021.
//

import UIKit
import MapKit
import Firebase

class viewLiveLocationViewController: UIViewController {
   
    //MARK: - @IBOutlets
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Variables
    var locationManager = CLLocationManager()
    var ref = Database.database().reference()
    var assignedCenter: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchParamedicLocation()
    }
    
    
    //MARK: - Functions
    
    private func fetchParamedicLocation(){
        
        let Queue = DispatchQueue.init(label: "Queue")
        
        Queue.sync {
            
            ref.child("Paramedic").observe(.value) { snapshot in
                
                for coords in snapshot.children{
                    
                    let obj = coords as! DataSnapshot
                    if ( obj.key == self.assignedCenter ) {
                    let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                    let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                    self.setView(latitude: Double(latitude)!, longitude: Double(longitude)!)
                    self.setPinUsingMKPlacemark(latitude: Double(latitude)!, longitude: Double(longitude)!)
                    }
                    
//reload gose here
                }
                
            }
        }
    }
    
    func setPinUsingMKPlacemark(latitude: Double, longitude: Double) {
        
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)))
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = "Paramedic"
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 12000, longitudinalMeters: 12000)
        map.setRegion(coordinateRegion, animated: true)
        map.addAnnotation(annotation)
    }
    
    func setView(latitude: Double, longitude: Double) {
        let viewRegion = MKCoordinateRegion.init(center: .init(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), latitudinalMeters: 800, longitudinalMeters: 800)
        map.setRegion(viewRegion, animated: true)
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - Map View Delegate Extension
extension viewLiveLocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation)else{
            return nil
        }
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "accidentPin")
        if pin == nil {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "accidentPin")
            pin?.canShowCallout = true
            pin?.image = UIImage(named: "Vector-1")
        }else{
            pin?.annotation = annotation
        }
        return pin
    }
}
