//
//  ViewSOSRequestsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 14/11/2021.
//

import UIKit
import Firebase
import CoreLocation

class ViewSOSRequestsViewController: UIViewController {
    
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Varibales
    var loggedInCenterEmail = Auth.auth().currentUser?.email
    var center:[String: Any]?
    var ref = Database.database().reference()
    var sosRequests: [SOSRequest] = []


    
    //MARK: - Overriden Function
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCenter()
        fetchSOSRequests()
    }
    
    //MARK: - Functions
    private func fetchSOSRequests(){
        
        ref.child("SOSRequests").queryOrdered(byChild: "time_date").observe(.value) { snapshot in
            self.sosRequests = []
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
                    self.sosRequests.append(SOSRequest(user_id: user_id, user_name: "User", status: status, assignedCenter: assigned_center, sent: sent, longitude: longitude, latitude: latitude,timeDate: time_date))
                    self.tableView.reloadData()
                }
            }
        }
  
        
    }
    
    private func configureCenter(){
        let domainRange = loggedInCenterEmail!.range(of: "@")!
        let centerName = loggedInCenterEmail![..<domainRange.lowerBound]
        center = SRCACenters.getSRCAInfo(name: String(centerName))
        print("SRCA Center info: \(String(describing: center))")
    }
    
    
    //MARK: - @IBActions
    
    
}

//MARK: -
extension ViewSOSRequestsViewController: UITableViewDelegate{
    
}

extension ViewSOSRequestsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sosRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sosCell") as! sosRequestTableViewCell
        
        //1- distance circle view:
        let distanceShadowLayer = CAShapeLayer()
        distanceShadowLayer.path = UIBezierPath(roundedRect: cell.distanceView.bounds, cornerRadius: cell.distanceView.layer.frame.width/2).cgPath
        distanceShadowLayer.fillColor = UIColor.white.cgColor
        distanceShadowLayer.shadowColor = UIColor.black.cgColor
        distanceShadowLayer.shadowPath = distanceShadowLayer.path
        distanceShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        distanceShadowLayer.shadowOpacity = 0.2
        distanceShadowLayer.shadowRadius = 3
        cell.distanceView.layer.insertSublayer(distanceShadowLayer, at: 0)
        
        //2- gender circle view:
        let genderShadowLayer = CAShapeLayer()
        genderShadowLayer.path = UIBezierPath(roundedRect: cell.genderView.bounds, cornerRadius: cell.genderView.layer.frame.width/2).cgPath
        genderShadowLayer.fillColor = UIColor.white.cgColor
        genderShadowLayer.shadowColor = UIColor.black.cgColor
        genderShadowLayer.shadowPath = genderShadowLayer.path
        genderShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        genderShadowLayer.shadowOpacity = 0.2
        genderShadowLayer.shadowRadius = 3
        cell.genderView.layer.insertSublayer(genderShadowLayer, at: 0)

        

        
        


        
        
        
        
        
        //configuring the information of the cell
        
        
        
        let centerLocation = CLLocation(latitude: CLLocationDegrees(center!["latitude"] as! Double), longitude: CLLocationDegrees(center!["longitude"] as! Double))
        let distance = centerLocation.distance(from: CLLocation(latitude: CLLocationDegrees(sosRequests[indexPath.row].getLatitude())!, longitude: CLLocationDegrees(CLLocationDegrees(sosRequests[indexPath.row].getLongitude())!)))
        
        cell.name.text = "User Name"
        
        cell.distanceLabel.text = "\(Double(round(10*(distance/1000))/10)) Km"
        cell.status.text = "Active"
        cell.occuredAt.text = sosRequests[indexPath.row].getTimeDate()
        
        cell.ageLabel.text = "age"
        cell.genderLabel.text = "gender"

        return cell
    }


}
