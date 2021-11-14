//
//  ViewSOSRequestsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 14/11/2021.
//

import UIKit
import Firebase

class ViewSOSRequestsViewController: UIViewController {
    
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Varibales
    var loggedInCenterEmail = Auth.auth().currentUser?.uid
    var center: String?
    var ref = Database.database().reference()
    var sosRequests: [SOSRequest] = []


    
    //MARK: - Overriden Function
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCenter()
    }
    
    //MARK: - Functions
    private func fetchSOSRequests(){
        
        ref.child("Request").queryOrdered(byChild: "time_date").observe(.value) { snapshot in
            self.sosRequests = []
            for request in snapshot.children{
                let obj = request as! DataSnapshot
                let assigned_center = obj.childSnapshot(forPath: "assigned_center").value as! String
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                let sent = obj.childSnapshot(forPath: "sent").value as! String
                let status = obj.childSnapshot(forPath: "status").value as! String
                let time_date = obj.childSnapshot(forPath: "time_date").value as! String
                let time_stamp = obj.childSnapshot(forPath: "time_stamp").value as! String
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                
                if assigned_center == self.center {
                    self.sosRequests.append(SOSRequest(user_id: user_id, user_name: "User", status: status, assignedCenter: assigned_center, sent: sent, longitude: longitude, latitude: latitude))
                    self.tableView.reloadData()
                }
            }
        }
  
        
    }
    
    private func configureCenter(){
        let domainRange = loggedInCenterEmail!.range(of: "@")!
        let centerName = loggedInCenterEmail![..<domainRange.lowerBound]
        center = (SRCACenters.getSRCAInfo(name: String(centerName))["name"] as! String)
        print(center!)
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
        
        return cell
    }


}
