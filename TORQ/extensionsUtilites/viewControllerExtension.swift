//
//  viewControllerExtension.swift
//  TORQ
//
//  Created by Dalal  on 22/10/2021.
//

import Foundation
import UIKit
import Firebase

extension UIViewController {
    
    /* Steps:
     * 1- observe the database for any addition/updates on the requests -> detect collisions
     * 2- if a request has not been processed and belongs to the current user -> current user had an accident
     * 3- notify them by sending a notification with actions and information
     */
    func registerToNotifications(userID: String) {
        
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        
        //different dispatch queue for sender and reciver?
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
                    
                    let userRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    
                    if (userRequest.getUserID()) == userID && (userRequest.getStatus() == "0"){
                        
                        // ref.child("Request").child("Req\(userRequest.getRequestID())").updateChildValues(["status":"2"])
                        
                        var center = UNUserNotificationCenter.current()
                        center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert,.sound, .badge, .carPlay]) { grantedPermisssion, error in
                            guard error == nil else{
                                print(error!.localizedDescription)
                                return
                            }
                            
                            print("has premission been granted: ", grantedPermisssion)
                            
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


extension UIViewController: UNUserNotificationCenterDelegate{
    
    /* Steps:
     * 1- if a notification is fired then deal with each action accordingly
     * 2- user is okay: simply delete the request and proceed - no accident happened
     * 3- user needs immediet help: send the request (keep it) and inform the emergency contacts
     * 4- user does not interact: the request will be sent -not sure what to do-
     */
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let updateQueue = DispatchQueue.init(label: "updateQueue")
        _ = response.notification.request.content.userInfo["userID"] //Could be helpful for the emergency contacts
        let requestID = response.notification.request.content.userInfo["requestID"]
        let ref = Database.database().reference()
        
        updateQueue.sync {
            switch response.actionIdentifier{
            case "OKAY_ACTION": //Delete the node
                ref.child("Request").child("Req\(requestID!)").removeValue()
                break
            case "REQUEST_ACTION":
                print("user wants help")
                //Nouras' logic goes here -> inform the emergency contacts
                break
            default:
                //??
                print("No reply")
            }
            completionHandler()
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
}

