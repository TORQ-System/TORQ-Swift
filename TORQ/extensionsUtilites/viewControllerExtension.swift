//
//  viewControllerExtension.swift
//  TORQ
//
//  Created by Norua Alsalem on 19/10/2021.
//

import Foundation
import UIKit
import Firebase

extension UIViewController {
    
    func registerToNotifications(userID: String) {
        
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        let updateQueue = DispatchQueue.init(label: "updateQueue")
        
       searchQueue.sync {
        
        
        ref.child("EmergencyContact").observe(.value) { snapshot in
            for contact in snapshot.children{
                let obj = contact as! DataSnapshot
                let relation = obj.childSnapshot(forPath: "relation").value as! String
                let contactId = obj.childSnapshot(forPath: "contactID").value as! Int
                let name = obj.childSnapshot(forPath: "name").value as! String
                let phone = obj.childSnapshot(forPath: "phone").value as! String
                let senderID = obj.childSnapshot(forPath: "sender").value as! String
                let receiverID = obj.childSnapshot(forPath: "reciever").value as! String
                let sent = obj.childSnapshot(forPath: "sent").value as! String
                let msg = obj.childSnapshot(forPath: "msg").value as! String
                //create a EC object
                let emergencyContact = emergencyContact(name: name, phone_number: phone, senderID:senderID, recieverID: receiverID, sent: sent, contactID: contactId, msg: msg, relation: relation)
                
                if (emergencyContact.getReciverID()) == userID && (emergencyContact.getSent() == "Yes"){
                    //show me notification
                    
                    
                    var center = UNUserNotificationCenter.current()
                    center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.alert,.sound]) { grantedPermisssion, error in
                        guard error == nil else{
                            print(error!.localizedDescription)
                            return
                        }
                        
                    let content = UNMutableNotificationContent()
                        content.title = "ALERT!"
                        content.body = msg
                        
                        
                        let request = UNNotificationRequest(identifier: UUID.init().uuidString, content: content, trigger: nil)
                        
                        center.add(request) { error in
                            guard error == nil else{
                                print(error!.localizedDescription)
                                return
                            }
                        }
                        
                        
                        
                        
                    }
                    
                    self.getAccidentLocation(senderID: emergencyContact.getSenderID())
                    
                    


                    
                    updateQueue.sync {
                        //2- update thier sent attribute form No to Yes.
//                            print(obj.key)
                        
                        ref.child("EmergencyContact").child(obj.key).updateChildValues(["sent": "No"]) {(error, ref) in
                          if let error = error {
                            print("Data could not be saved: \(error.localizedDescription).")
                          } else {
//                                print("Data updated successfully!")
                          }
                        }
                    }
                }
//                    print("printing the global array in : \(self.myContacts)")
            }
        }
    }
}
    func getAccidentLocation (senderID: String) {
        
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        
       searchQueue.sync {
        
        
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
                //create a request object
                let request = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                
                if (request.getUserID()) == senderID && (request.getStatus() == "0"){
                    //get the location
                    let lat = request.getLatitude()
                    let long = request.getLongitude()
//                    print(long)
//                    print(lat)

                }

            }
        }
        
        
    }
}
}


