//
//  viewControllerExtension.swift
//  TORQ
//
//  Created by Dalal  on 22/10/2021.
//

import Foundation
import UIKit
import Firebase
import UserNotifications

extension UIViewController {
    
    func registerToNotifications(userID: String) {
        let ref = Database.database().reference()
        let sendRequestQueue = DispatchQueue.init(label: "sendRequestQueue")
        //different dispatch queue for sender and reciver?
        sendRequestQueue.sync {
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
                    
                    let userRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    
                    if (userRequest.getUserID()) == userID && (userRequest.getStatus() == "0"){
                        var center = UNUserNotificationCenter.current()
                        center = UNUserNotificationCenter.current()
                        //Assign contents
                        let content = UNMutableNotificationContent()
                        content.title = "Are you okay?"
                        content.subtitle =  "We detcted an impact on your veichle"
                        content.body = "Reply within 10s or we will send an ambulance request."
                        content.sound = .default
                        content.categoryIdentifier = "ACTIONS"
                        content.userInfo = ["userID":userID, "requestID":request_id]
                        
                        //Create actions
                        let okayAction = UNNotificationAction(identifier: "OKAY_ACTION", title: "I'm okay", options: UNNotificationActionOptions.init(rawValue: 0))
                        
                        let requestAction = UNNotificationAction(identifier: "REQUEST_ACTION", title: "No, send request", options: UNNotificationActionOptions.init(rawValue: 0))
                        
                        let actionCategory = UNNotificationCategory(identifier: "ACTIONS", actions: [okayAction, requestAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction) //it will get dismissed
                        
                        center.setNotificationCategories([actionCategory])
                        
                        //Notification request
                        let uuid = UUID().uuidString
                        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: nil)
                        
                        // reigester to the notification center
                        
                        center.getNotificationSettings { setting in
                            if setting.authorizationStatus == .authorized{
                                center.add(request) { error in
                                    guard error == nil else{
                                        print(error!.localizedDescription)
                                        return
                                    }
                                    NSLog("sent");
                                }
                            } else {
                                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    guard success else{
                                        print("The user has not authorized")
                                        return
                                    }
                                    center.add(request) { error in
                                        guard error == nil else{
                                            print(error!.localizedDescription)
                                            return
                                        }
                                        NSLog("sent");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func notifyEmergencyContact(userID: String) {
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        let updateQueue = DispatchQueue.init(label: "updateQueue")
        searchQueue.sync {
            ref.child("EmergencyContact").observe(.value) { snapshot in
                for contact in snapshot.children{
                    let obj = contact as! DataSnapshot
                    let relation = obj.childSnapshot(forPath: "relation").value as! String
                    //let contactId = obj.childSnapshot(forPath: "contactID").value as! Int
                    let name = obj.childSnapshot(forPath: "name").value as! String
                    let phone = obj.childSnapshot(forPath: "phone").value as! String
                    let senderID = obj.childSnapshot(forPath: "sender").value as! String
                    let receiverID = obj.childSnapshot(forPath: "reciever").value as! String
                    let sent = obj.childSnapshot(forPath: "sent").value as! String
                    let msg = obj.childSnapshot(forPath: "msg").value as! String
                    //create a EC object
                    let emergencyContact = emergencyContact(name: name, phone_number: phone, senderID:senderID, recieverID: receiverID, sent: sent, contactID: 1, msg: msg, relation: relation)
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
                            content.categoryIdentifier = "ACTIONS"
                            content.title = "ALERT!"
                            content.body = msg
                            content.userInfo = ["userID":userID]
                            
                            //Create actions
                            let showAction = UNNotificationAction(identifier: "SHOW_ACTION", title: "show me the location", options: UNNotificationActionOptions.init(rawValue: 0))
                            
                            let actionCategory = UNNotificationCategory(identifier: "ACTIONS", actions: [showAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction) //it will get dismissed
                            
                            center.setNotificationCategories([actionCategory])
                            
                            
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
                            ref.child("EmergencyContact").child(obj.key).updateChildValues(["sent": "No"]) {(error, ref) in
                                if let error = error {
                                    print("Data could not be saved: \(error.localizedDescription).")
                                } else {
                                    //print("Data updated successfully!")
                                }
                            }
                        }
                    }
                    //print("printing the global array in : \(self.myContacts)")
                }
            }
        }
    }
    
    func getAccidentLocation (senderID: String) -> Void{
        var location: [String: String] = [:]
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        let retrunQueue = DispatchQueue.init(label: "returnQueue")
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
                        let lon = request.getLongitude()
                        location = ["longitude": lon ,"latitude": lat]
                        print(lon)
                        print(lat)
                        retrunQueue.sync {
                            print("from return queue\(location)")
                            self.showMeLocation(location: location)
                        }
                    }
                }
            }
        }
    }
    
    func updateEmergencyContacts(userID: String){
        // we had to create two threads because we can't assure that the update segment of code will always be executed after the searching code segment , to avoid such a situation we created queue for searching and queue for updating that will work Syncronously.
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        let updateQueue = DispatchQueue.init(label: "updateQueue")
        let ref = Database.database().reference()
        
        searchQueue.sync {
            //1-  get my emergency contact.
            ref.child("EmergencyContact").observeSingleEvent(of: .value) { snapshot in
                //                print(snapshot.value as! [String: Any])
                
                for contact in snapshot.children{
                    let obj = contact as! DataSnapshot
                    let relation = obj.childSnapshot(forPath: "relation").value as! String
                    //let contactId = obj.childSnapshot(forPath: "contactID").value as! Int
                    let name = obj.childSnapshot(forPath: "name").value as! String
                    let phone = obj.childSnapshot(forPath: "phone").value as! String
                    let senderID = obj.childSnapshot(forPath: "sender").value as! String
                    let receiverID = obj.childSnapshot(forPath: "reciever").value as! String
                    let sent = obj.childSnapshot(forPath: "sent").value as! String
                    let msg = obj.childSnapshot(forPath: "msg").value as! String
                    //create a EC object
                    let emergencyContact = emergencyContact(name: name, phone_number: phone, senderID:senderID, recieverID: receiverID, sent: sent, contactID: 1, msg: msg, relation: relation)
                    
                    if (emergencyContact.getSenderID()) == userID{
                        //                        print("inside if statement")
                        //add it to the myContacts array
                        //                        self.myContacts.append(emergencyContact)
                        
                        updateQueue.sync {
                            //2- update thier sent attribute form No to Yes.
                            //                            print(obj.key)
                            
                            ref.child("EmergencyContact").child(obj.key).updateChildValues(["sent": "Yes"]) {(error, ref) in
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
                //                print("printing the global array out : \(self.myContacts)")
            }
        }
    }
    
    
    private func showMeLocation(location: [String: String]){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "showAccidentViewController") as! showAccidentViewController
        vc.modalPresentationStyle = .fullScreen
        vc.location = location
        self.present(vc, animated: true, completion: nil)
    }
}


extension UIViewController: UNUserNotificationCenterDelegate{
    
    /* Steps:
     * 1- if a notification is fired then deal with each action accordingly
     * 2- user is okay: simply delete the request and proceed - no accident happened
     * 3- user needs immediet help: send the request (keep it) and inform the emergency contacts
     * 4- user does not interact: the request will be sent -not sure what to do-
     */
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userID = response.notification.request.content.userInfo["userID"] as! String
        let requestID = response.notification.request.content.userInfo["requestID"]
        let ref = Database.database().reference()
        
        switch response.actionIdentifier{
        case "OKAY_ACTION":
            ref.child("Request").child("Req\(requestID!)").updateChildValues(["status":"2"])
            break
        case "REQUEST_ACTION":
            updateEmergencyContacts(userID: userID)
            break
        case "SHOW_ACTION":
            getAccidentLocation(senderID: userID)
            break
        default:
            print("No reply")
        }
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
}

