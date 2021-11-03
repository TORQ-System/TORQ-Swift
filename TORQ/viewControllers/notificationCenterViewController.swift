//
//  notificationCenterViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit
import Firebase

class notificationCenterViewController: UIViewController {
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var userID: String?
    var wellbeing: [notification] = []
    var emergency: [notification] = []
    var all: [notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classifyNotifications(userID: userID!)
        // Do any additional setup after loading the view.
    }
    
    // fetch all notifications from database and assign it to its appropriate array
     
    func classifyNotifications (userID: String) {
        
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        
        searchQueue.sync {
        ref.child("Notification").observe(.childAdded) { snapshot in
            
            let obj = snapshot.value as! [String: Any]
            let title = obj["title"] as! String
            let subtitle = obj["subtitle"] as! String
            let body = obj["body"] as! String
            let type = obj["type"] as! String
            let date = obj["date"] as! String
            let sender = obj["sender"] as! String
            let receiver = obj["receiver"] as! String
            let time = obj["time"] as! String
            
            let alert = notification(title: title, subtitle: subtitle, body:body, date: date, time: time, type: type, sender: sender, receiver: receiver)
            
            if (  alert.getReceiver() == userID && alert.getType() == "wellbeing" ) {
                self.wellbeing.append(alert)
                self.all.append(alert)
                // reload data
            }
            
            if ( alert.getReceiver() == userID &&  alert.getType() == "emergency" ) {
                self.emergency.append(alert)
                self.all.append(alert)
                // reload data
            }
        }
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
