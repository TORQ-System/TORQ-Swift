//
//  ViewSOSRequestsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 14/11/2021.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class ViewSOSRequestsViewController: UIViewController {
    

    //MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var processedButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activeButton: UIButton!
    
    //MARK: - Varibales
    var loggedInCenterEmail = Auth.auth().currentUser?.email
    var center:[String: Any]?
    var ref = Database.database().reference()
    var users: [User] = []
    var activeRequests: [SOSRequest] = []
    var processedRequests: [SOSRequest] = []
    var cancelledRequests: [SOSRequest] = []
    var active = true
    var processed = false
    var cancelled = false
    


    //MARK: - Overriden Function
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        configureCenter()
        fetchSOSRequests()
    }
    
    //MARK: - Functions
    private func fetchSOSRequests(){
        ref.child("SOSRequests").queryOrdered(byChild: "time_date").observe(.value) { snapshot in
            self.activeRequests = []
            self.processedRequests = []
            self.cancelledRequests = []
            for request in snapshot.children{
                let obj = request as! DataSnapshot
                let assigned_center = obj.childSnapshot(forPath: "assigned_center").value as! String
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                let sent = obj.childSnapshot(forPath: "sent").value as! String
                let status = obj.childSnapshot(forPath: "status").value as! String
                let time_date = obj.childSnapshot(forPath: "time_date").value as! String
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                
                if assigned_center == self.center!["name"] as! String {
                    
                    let sosRequest = SOSRequest(user_id: user_id, user_name: "User", status: status, assignedCenter: assigned_center, sent: sent, longitude: longitude, latitude: latitude,timeDate: time_date)
                    
                    switch status {
                    case "cancelled":
                        self.cancelledRequests.append(sosRequest)
                        break
                    case "1":
                        self.activeRequests.append(sosRequest)
                        break
                    case "processed":
                        self.processedRequests.append(sosRequest)
                        break
                    default:
                        print("unknown status")
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
//    private func fetchUsers(){
//        ref.child("User").observe(.value) { snapshot in
//            self.users = []
//            for user in snapshot.children{
//                let obj = user as! DataSnapshot
//                let assigned_center = obj.childSnapshot(forPath: "assigned_center").value as! String
//                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
//                let longitude = obj.childSnapshot(forPath: "longitude").value as! String
//                let sent = obj.childSnapshot(forPath: "sent").value as! String
//                let status = obj.childSnapshot(forPath: "status").value as! String
//                let time_date = obj.childSnapshot(forPath: "time_date").value as! String
//                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
//
//                if assigned_center == self.center!["name"] as! String {
//                    self.sosRequests.append(SOSRequest(user_id: user_id, user_name: "User", status: status, assignedCenter: assigned_center, sent: sent, longitude: longitude, latitude: latitude,timeDate: time_date))
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
    
    private func configureCenter(){
        let domainRange = loggedInCenterEmail!.range(of: "@")!
        let centerName = loggedInCenterEmail![..<domainRange.lowerBound]
        center = SRCACenters.getSRCAInfo(name: String(centerName))
        print("SRCA Center info: \(String(describing: center))")
    }
    
    private func layoutViews(){
        //1- background view
        backgroundView.layer.cornerRadius = 30
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundView.frame
        gradientLayer.colors =  [
            UIColor(red: 0.102, green: 0.157, blue: 0.345, alpha: 1).cgColor,
            UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0.98, c: -0.75, d: 1.6, tx: 0.38, ty: -0.77))
        gradientLayer.bounds = backgroundView.bounds.insetBy(dx: -0.5*backgroundView.bounds.size.width, dy: -0.5*backgroundView.bounds.size.height)
        gradientLayer.position = backgroundView.center
        backgroundView.layer.addSublayer(gradientLayer)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        //2- active button
        activeButton.layer.cornerRadius = 10
        
        //3- processed button
        processedButton.layer.cornerRadius = 10
        
        //3- cancelled button
        cancelButton.layer.cornerRadius = 10
        
    }
    
    @objc func goToLocation (sender:CustomTapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
        vc.latitude = sender.lat
        vc.longitude = sender.long
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    class CustomTapGestureRecognizer: UITapGestureRecognizer {
        var long: Double?
        var lat: Double?
    }
    
    //MARK: - @IBActions
    @IBAction func activeButton(_ sender: Any) {
        active = true
        processed = false
        cancelled = false
        tableView.reloadData()
    }
    
    @IBAction func processedButton(_ sender: Any) {
        active = false
        processed = true
        cancelled = false
        tableView.reloadData()
    }
    
    @IBAction func cancelledButton(_ sender: Any) {
        active = false
        processed = false
        cancelled = true
        tableView.reloadData()
    }
    
}

//MARK: - UITableViewDelegate
extension ViewSOSRequestsViewController: UITableViewDelegate{
    
}

extension ViewSOSRequestsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 10
        
        // if "Active" option is selected
        if active{
            count = activeRequests.count
        }
        
        // if "processed" option is selected
        else if processed {
            count = processedRequests.count
        }
        
        // if "cancelled" option is selected
        else if cancelled {
            count = cancelledRequests.count
        }
        print("count: \(count)")
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sosCell") as! sosRequestTableViewCell
        
        //1- which filter option is choosed:
        let array: [SOSRequest]
        if processed {
            array = processedRequests
        }else if cancelled {
            array = cancelledRequests
        } else {
            array = activeRequests
        }
        
        //2- distance circle view:
        let distanceShadowLayer = CAShapeLayer()
        distanceShadowLayer.path = UIBezierPath(roundedRect: cell.distanceView.bounds, cornerRadius: cell.distanceView.layer.frame.width/2).cgPath
        distanceShadowLayer.fillColor = UIColor.white.cgColor
        distanceShadowLayer.shadowColor = UIColor.darkGray.cgColor
        distanceShadowLayer.shadowPath = distanceShadowLayer.path
        distanceShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        distanceShadowLayer.shadowOpacity = 0.15
        distanceShadowLayer.shadowRadius = 5
        cell.distanceView.layer.insertSublayer(distanceShadowLayer, at: 0)
        
        //3- gender circle view:
        let genderShadowLayer = CAShapeLayer()
        genderShadowLayer.path = UIBezierPath(roundedRect: cell.genderView.bounds, cornerRadius: cell.genderView.layer.frame.width/2).cgPath
        genderShadowLayer.fillColor = UIColor.white.cgColor
        genderShadowLayer.shadowColor = UIColor.darkGray.cgColor
        genderShadowLayer.shadowPath = genderShadowLayer.path
        genderShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        genderShadowLayer.shadowOpacity = 0.15
        genderShadowLayer.shadowRadius = 5.0
        cell.genderView.layer.insertSublayer(genderShadowLayer, at: 0)
        
        //4- age circle view:
        let ageShadowLayer = CAShapeLayer()
        ageShadowLayer.path = UIBezierPath(roundedRect: cell.ageView.bounds, cornerRadius: cell.ageView.layer.frame.width/2).cgPath
        ageShadowLayer.fillColor = UIColor.white.cgColor
        ageShadowLayer.shadowColor = UIColor.darkGray.cgColor
        ageShadowLayer.shadowPath = ageShadowLayer.path
        ageShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        ageShadowLayer.shadowOpacity = 0.15
        ageShadowLayer.shadowRadius = 5.0
        cell.ageView.layer.insertSublayer(ageShadowLayer, at: 0)
        
        //5- map view:
        cell.mapView.layer.cornerRadius = 20
        cell.mapView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(array[indexPath.row].getLatitude())!), longitude: CLLocationDegrees(Double(array[indexPath.row].getLongitude())!)))
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 12000, longitudinalMeters: 12000)
        cell.mapView.setRegion(coordinateRegion, animated: true)
        cell.mapView.addAnnotation(annotation)
        let tap = CustomTapGestureRecognizer(target: self, action: #selector(goToLocation(sender:)))
        tap.lat = Double(array[indexPath.row].getLatitude())!
        tap.long = Double(array[indexPath.row].getLongitude())!
        cell.mapView.addGestureRecognizer(tap)
        
        //6- view details button:
        cell.viewDetailsButton.backgroundColor = nil
        cell.viewDetailsButton.layoutIfNeeded()
        let gradientLayerr = CAGradientLayer()
        gradientLayerr.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayerr.startPoint = CGPoint(x: 0, y: 0)
        gradientLayerr.endPoint = CGPoint(x: 1, y: 0)
        gradientLayerr.frame = cell.viewDetailsButton.bounds
        gradientLayerr.cornerRadius = cell.viewDetailsButton.frame.height/2
        gradientLayerr.shadowColor = UIColor.darkGray.cgColor
        gradientLayerr.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayerr.shadowRadius = 5.0
        gradientLayerr.shadowOpacity = 0.3
        gradientLayerr.masksToBounds = false
        cell.viewDetailsButton.layer.insertSublayer(gradientLayerr, at: 0)
        cell.viewDetailsButton.contentVerticalAlignment = .center
        
        //7- status label:
        cell.status.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        
        //8- occuredAt label:
        cell.occuredAt.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        
        //9- distance label:
        cell.distanceLabel.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        
        //10- gender label:
        cell.genderLabel.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        
        //11- age label:
        cell.ageLabel.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        
        //configuring the information of the cell
        let centerLocation = CLLocation(latitude: CLLocationDegrees(center!["latitude"] as! Double), longitude: CLLocationDegrees(center!["longitude"] as! Double))
        let distance = centerLocation.distance(from: CLLocation(latitude: CLLocationDegrees(array[indexPath.row].getLatitude())!, longitude: CLLocationDegrees(CLLocationDegrees(array[indexPath.row].getLongitude())!)))
        cell.name.text = "Noura Alsulayfih"
        cell.distanceLabel.text = "\(Double(round(10*(distance/1000))/10)) Km"
        cell.status.text = "Active"
//        cell.occuredAt.text = sosRequests[indexPath.row].getTimeDate()
        cell.ageLabel.text = "21"
        cell.genderLabel.text = "female"
        return cell
    }


}

//MARK: - MKMapViewDelegate
extension ViewSOSRequestsViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation)else{
            return nil
        }
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "sosPin")
        if pin == nil {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "sosPin")
            pin?.canShowCallout = true
            pin?.image = UIImage(named: "Vector")
        }else{
            pin?.annotation = annotation
        }
        return pin
    }
}