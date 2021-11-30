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
    @IBOutlet weak var canceledRequest: UIView!
    @IBOutlet weak var activeRequest: UIView!
    @IBOutlet weak var processedRequest: UIView!
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
    var cancelTap = UITapGestureRecognizer()
    var locationTap = UITapGestureRecognizer()
    var requestChanged = -1
    
    //MARK: - Constants
    let ref = Database.database().reference()
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        requestChanged = -1
        getRequest()
        configureDetailsView()
        configureButtonsView()
        configureTapGesture()
        
        if(notificationDetails.getType() == "emergency"){
            self.ref.child("User").getData(completion:{error, snapshot in
                guard error == nil else { return }
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
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
    func configureTapGesture(){
        /* When the user taps cancel */
        cancelTap = UITapGestureRecognizer(target: self, action: #selector(self.cancelPressed(_:)))
        cancelTap.numberOfTapsRequired = 1
        cancelTap.numberOfTouchesRequired = 1
        cancelButton.addGestureRecognizer(cancelTap)
        cancelButton.isUserInteractionEnabled = true
        
        /* When the user taps view location */
        locationTap = UITapGestureRecognizer(target: self, action: #selector(self.locationPressed(_:)))
        locationTap.numberOfTapsRequired = 1
        locationTap.numberOfTouchesRequired = 1
        viewLocationButtonView.addGestureRecognizer(locationTap)
        viewLocationButtonView.isUserInteractionEnabled = true
    }
    
    func configureButtonsView(){
        /* Adjust the view location button's UI */
        viewLocationButtonView.layer.cornerRadius = 15
        viewLocationButtonView.layer.masksToBounds = true
        viewLocationButtonView.layer.shouldRasterize = true
        viewLocationButtonView.layer.rasterizationScale = UIScreen.main.scale
        viewLocationButtonView.layer.shadowColor = UIColor.black.cgColor
        viewLocationButtonView.layer.shadowOffset = CGSize(width: 1, height: 2)
        viewLocationButtonView.layer.shadowRadius = 5
        viewLocationButtonView.layer.shadowOpacity = 0.25
        viewLocationButtonView.layer.masksToBounds = false
        
        /* Adjust the cancel button's UI */
        let gradient: CAGradientLayer = CAGradientLayer()
        roundView.layer.cornerRadius = 20
        roundView.layer.shouldRasterize = true
        roundView.layer.rasterizationScale = UIScreen.main.scale
        gradient.cornerRadius = 20
        gradient.colors = [UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
                           UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = roundView.bounds
        roundView.layer.insertSublayer(gradient, at: 0)
    }
    
    
    func configureMapView(){
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(assignedRequest.getLatitude())!),
                                                                 longitude: CLLocationDegrees(Double(assignedRequest.getLongitude())!)))
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = "Accident"
        annotation.subtitle = "\(notificationDetails.getType())"
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    @objc func cancelPressed(_ sender: UITapGestureRecognizer) {
        print("cancel")
    }
    
    @objc func locationPressed(_ sender: UITapGestureRecognizer) {
        print("location")
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
            
        } else {
            from.text = "TORQ"
            subtitle.text = notificationDetails.getSubtitle()
        }
        
        date.text = notificationDetails.getDate()
        time.text = notificationDetails.getTime()
        
    }
    
    func configureRequestStatus(){
        /* Set requests radius */
        canceledRequest.layer.cornerRadius = canceledRequest.frame.height/2
        activeRequest.layer.cornerRadius = activeRequest.frame.height/2
        processedRequest.layer.cornerRadius = processedRequest.frame.height/2
        
        /* Set status color and dropshadow */
        switch assignedRequest.getStatus() {
        case "0":
            setBackgroundColor(requestView: activeRequest, type: "blue")
            setBackgroundColor(requestView: canceledRequest, type: "gray")
            setBackgroundColor(requestView: processedRequest, type: "gray")
            break
        case "1":
            setBackgroundColor(requestView: processedRequest, type: "red")
            setBackgroundColor(requestView: activeRequest, type: "gray")
            setBackgroundColor(requestView: canceledRequest, type: "gray")
            break
        case "2":
            setBackgroundColor(requestView: canceledRequest, type: "yellow")
            setBackgroundColor(requestView: activeRequest, type: "gray")
            setBackgroundColor(requestView: processedRequest, type: "gray")
            break
        default:
            break
        }
    }
    func setBackgroundColor(requestView: UIView, type: String){
        let gradient = CAGradientLayer()
        let color: [CGColor]?
        let shadowColor: CGColor?
        
        if(type == "red"){
            color = [UIColor(red: 0.871, green: 0.408, blue: 0.471, alpha: 1).cgColor,
                     UIColor(red: 0.754, green: 0.149, blue: 0.231, alpha: 1).cgColor]
            shadowColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 0.8).cgColor
        } else if(type == "blue"){
            color = [UIColor(red: 0.446, green: 0.667, blue: 0.812, alpha: 1).cgColor,
                     UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor]
            shadowColor = UIColor(red: 0.318, green: 0.506, blue: 0.698, alpha: 0.8).cgColor
        } else if type == "yellow"{
            color = [UIColor(red: 1, green: 0.587, blue: 0, alpha: 1).cgColor,
                     UIColor(red: 0.988, green: 0.762, blue: 0.442, alpha: 1).cgColor]
            shadowColor = UIColor(red: 0.988, green: 0.741, blue: 0.384, alpha: 0.7).cgColor
        } else{
            color = [UIColor.gray.cgColor, UIColor.gray.cgColor]
            shadowColor = UIColor.clear.cgColor
        }
        
        requestView.backgroundColor = nil
        gradient.colors = color!
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = requestView.bounds
        gradient.cornerRadius = requestView.frame.height/2
        requestView.layer.shadowColor = shadowColor!
        requestView.layer.shadowOffset = CGSize(width: 0, height: 0)
        requestView.layer.shadowRadius = 15
        requestView.layer.shadowOpacity = 1
        requestView.layer.masksToBounds = false
        guard requestChanged == 0 else {
            requestView
            requestView.layer.sublayers?[0].removeFromSuperlayer()
            requestView.layer.insertSublayer(gradient, at: 0)
            requestView.setNeedsDisplay()
            return
        }
        requestView.layer.insertSublayer(gradient, at: 0)

 
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
                    self.requestChanged+=1
                }
                if (self.notificationDetails.getType() == "emergency" && self.notificationDetails.getSender() == request.getUserID() && request.getStatus() == "0" ){
                    print(request)
                    self.assignedRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    self.configureMapView()
                    self.configureRequestStatus()
                    self.requestChanged+=1
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
