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
        
        var ref = Database.database().reference()
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
                    
                    let center = UNUserNotificationCenter.current()
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
}


