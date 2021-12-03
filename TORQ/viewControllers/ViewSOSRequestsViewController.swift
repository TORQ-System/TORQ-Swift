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
    @IBOutlet weak var noLabel: UILabel!
    
    //MARK: - Varibales
    var loggedInCenterEmail = Auth.auth().currentUser?.email
    var center:[String: Any]?
    var ref = Database.database().reference()
    var usersInfo: [ [User:String] ] = [[:]]
    var users: [User] = []
    var allSosRequests: [SOSRequest] = []
    var activeRequests: [SOSRequest] = []
    var processedRequests: [SOSRequest] = []
    var cancelledRequests: [SOSRequest] = []
    var all = false
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
        //fetching sos requests from the database
        let requestsQueue = DispatchQueue.init(label: "requestsQueue")
        let usersQueue = DispatchQueue.init(label: "usersQueue")
        _ = requestsQueue.sync {
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
                        let sosRequest = SOSRequest(user_id: user_id,status: status, assignedCenter: assigned_center, sent: sent, longitude: longitude, latitude: latitude,timeDate: time_date)
                        self.allSosRequests.append(sosRequest)
                        switch status {
                        case "Cancelled":
                            self.cancelledRequests.append(sosRequest)
                            break
                        case "1":
                            self.activeRequests.append(sosRequest)
                            break
                        case "Processed":
                            self.processedRequests.append(sosRequest)
                            break
                        default:
                            print("unknown status")
                        }
                    }
                }
                usersQueue.sync {
                    self.fetchUsers()
                }
            }
        }
    }
    
    private func fetchUsers(){
        // getting the user's information of sos requests
        let usersQueue = DispatchQueue.init(label: "usersQueue")
        _=usersQueue.sync {
            ref.child("User").observe(.value) { snapshot in
                self.users = []
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                    let email = obj.childSnapshot(forPath: "email").value as! String
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    let gender = obj.childSnapshot(forPath: "gender").value as! String
                    let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                    let password = obj.childSnapshot(forPath: "password").value as! String
                    let phone = obj.childSnapshot(forPath: "phone").value as! String

                    let user = User(dateOfBirth: dateOfBirth, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password: password, phone: phone)
                    
                    for req in self.allSosRequests {
                        if req.getUserID() == obj.key {
                            self.usersInfo.append([user:obj.key])
//                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                }
                print("usersInfo: \(self.usersInfo)")
            }
        }
    }
    
    private func configureCenter(){
        //get the center information = name , long , lat
        let domainRange = loggedInCenterEmail!.range(of: "@")!
        let centerName = loggedInCenterEmail![..<domainRange.lowerBound]
        center = SRCACenters.getSRCAInfo(name: String(centerName))
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
        activeButton.layer.cornerRadius = 15
        activeButton.titleEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        activeButton.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
        
        //3- processed button
        processedButton.layer.cornerRadius = 15
        processedButton.titleEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        processedButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.30)

        //4- cancelled button
        cancelButton.layer.cornerRadius = 15
        cancelButton.titleEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        cancelButton.backgroundColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 0.30)
    }
    
    func goToLoginScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! loginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func goToLocation (sender:CustomTapGestureRecognizer) {
        // clicking on view location view conyroller after clicking on the map
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
        vc.latitude = sender.lat
        vc.longitude = sender.long
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func viewDetails(sender: viewSOSRequestsDetails) {
        // clicking on view location view conyroller after clicking on the map
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewSOSRequestDetailsViewController") as! viewSOSRequestDetailsViewController
        vc.sosRequester = sender.userID
        vc.sosRequestName = sender.userName
        vc.sosRequestTime = sender.requestTime
        vc.sosRequestAge = sender.requesterAge
        if processed {
            vc.sosRequestStatus = "Processed"
        }else if active {
            vc.sosRequestStatus = "Active"
        }else{
            vc.sosRequestStatus = "Cancelled"
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    class CustomTapGestureRecognizer: UITapGestureRecognizer {
        var long: Double?
        var lat: Double?
    }
    
    class viewSOSRequestsDetails: UITapGestureRecognizer {
        var userName: String?
        var requestTime: String?
        var userID: String?
        var requesterAge: Int?
        
    }
    
    //MARK: - @IBActions
    @IBAction func activeButton(_ sender: Any) {
        active = true
        processed = false
        cancelled = false
        tableView.reloadData()
        activeButton.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
        processedButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.30)
        cancelButton.backgroundColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 0.30)
    }
    
    @IBAction func processedButton(_ sender: Any) {
        active = false
        processed = true
        cancelled = false
        tableView.reloadData()
        activeButton.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 0.30)
        processedButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        cancelButton.backgroundColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 0.30)
    }
    
    @IBAction func cancelledButton(_ sender: Any) {
        active = false
        processed = false
        cancelled = true
        tableView.reloadData()
        activeButton.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 0.30)
        processedButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.30)
        cancelButton.backgroundColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let userDefault = UserDefaults.standard
            userDefault.setValue(false, forKey: "isUserSignedIn")
            goToLoginScreen()
        } catch let error {
            print (error.localizedDescription)
        }
    }
    
    
    
}

//MARK: - UITableViewDelegate
extension ViewSOSRequestsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }

    
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
        
        if count == 0 {
            self.noLabel.alpha = 1
            if active {
                self.noLabel.text = "There are not any Active SOS request"
            }else if processed {
                self.noLabel.text = "There are not any Processed SOS request"
            }else{
                self.noLabel.text = "There are not any Cancelled SOS request"
            }
        }else{
            self.noLabel.alpha = 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        
        //5- map view:
        cell.mapView.layer.cornerRadius = 20
//        cell.mapView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
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
        
        
        //7- status label:
        cell.status.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        if active {
            cell.status.text = "Active"
        }else if processed{
            cell.status.text = "processed"
        }else{
            cell.status.text = "cancelled"
        }

        //8- occuredAt label:
        cell.occuredAt.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        let domainRange = array[indexPath.row].getTimeDate().range(of: " ")!
        let time = array[indexPath.row].getTimeDate()[domainRange.lowerBound...]
        cell.occuredAt.text = "\(time)"

        //9- distance label:
        cell.distanceLabel.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        let centerLocation = CLLocation(latitude: CLLocationDegrees(center!["latitude"] as! Double), longitude: CLLocationDegrees(center!["longitude"] as! Double))
        let distance = centerLocation.distance(from: CLLocation(latitude: CLLocationDegrees(array[indexPath.row].getLatitude())!, longitude: CLLocationDegrees(CLLocationDegrees(array[indexPath.row].getLongitude())!)))
        cell.distanceLabel.text = "\(Double(round(10*(distance/1000))/10)) Km"
        
        //10-getting the user information
        print("array: \(array)")
        var userInfo: [User:String]?
        for info in usersInfo {
            if info != [:] {
                if array[indexPath.row].getUserID() == info.first?.value {
                    userInfo = info
                }
            }
        }
        let userObject = userInfo?.keys
        
        //11- gender label:
        cell.genderLabel.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        cell.genderLabel.text = "\(String(describing: userObject!.first!.getGender()))"
        
        //12- age label:
        cell.ageLabel.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: Date(String(userObject!.first!.getDateOfBirth())))
        let now = calendar.dateComponents([.year, .month, .day], from: Date())
        let ageComponents = calendar.dateComponents([.year], from: components, to: now)
        let age = ageComponents.year!
        cell.ageLabel.text = "\(age)"
        
        //13- name label:
        cell.name.text = "\(String(describing: userObject!.first!.getFullName()))"
        
        //14- view deatils button
        let buttonTap = viewSOSRequestsDetails(target: self, action: #selector(viewDetails(sender:)))
        buttonTap.userID = array[indexPath.row].getUserID()
        buttonTap.userName = userObject!.first!.getFullName()
        buttonTap.requesterAge = age
        buttonTap.requestTime = String(time)
        cell.viewDetailsButton.addGestureRecognizer(buttonTap)
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
