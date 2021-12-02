//
//  viewLiveLocationViewController.swift
//  TORQ
//
//  Created by Norua Alsalem on 29/11/2021.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class viewLiveLocationViewController: UIViewController {
   
    //MARK: - @IBOutlets
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Variables
    var locationManager = CLLocationManager()
    var ref = Database.database().reference()
    var assignedCenter: String?
    var paramedicAnnotation : MKPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchParamedicLocation()
        paramedicAnnotation = MKPointAnnotation()
        self.map.delegate = self
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
//                    self.setView(latitude: Double(latitude)!, longitude: Double(longitude)!)
//                    self.setPinUsingMKPlacemark(latitude: Double(latitude)!, longitude: Double(longitude)!)
                    let coordinates = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
                    self.setLocation(currentParamedicPoints: coordinates)
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
    
    private var isParamedicMarkerSet = false
    
    private func setLocation(currentParamedicPoints : CLLocationCoordinate2D){

        if !isParamedicMarkerSet {
            paramedicAnnotation?.coordinate = currentParamedicPoints
            isParamedicMarkerSet = true
            map.addAnnotation(paramedicAnnotation!)
        } else {
            let angle = angleFromCoordinate(firstCoordinate: paramedicAnnotation!.coordinate, secondCoordinate: currentParamedicPoints)
            
            UIView.animate(withDuration: 2) {
                self.paramedicAnnotation?.coordinate = currentParamedicPoints
            }
            
            //Getting the MKAnnotationView
            let annotationView = self.map.view(for: paramedicAnnotation!)
            
            //Angle for moving the driver
            UIView.animate(withDuration: 1) {
                annotationView?.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            }
            
        }
        
        self.zoomOnAnnotation()
    }
    
    func angleFromCoordinate(firstCoordinate: CLLocationCoordinate2D,
                             secondCoordinate: CLLocationCoordinate2D) -> Double {
        
        let deltaLongitude: Double = secondCoordinate.longitude - firstCoordinate.longitude
        let deltaLatitude: Double = secondCoordinate.latitude - firstCoordinate.latitude
        let angle = (Double.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
        
        if (deltaLongitude > 0) {
            return angle
        } else if (deltaLongitude < 0) {
            return angle + Double.pi
        } else if (deltaLatitude < 0) {
            return Double.pi
        } else {
            return 0.0
        }
        
    }
    
    private func zoomOnAnnotation(){
        let region = MKCoordinateRegion(center: paramedicAnnotation!.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        map.setRegion(region, animated: true)
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
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        self.map.setRegion(region, animated: true)
    }
}
