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
    
    /* STEPS:
     * 1- observe the database for any addition of requests -> detect collisions
     * 2- if a request has not been processed and belongs to the current user -> current user had an accident
     * 3- notify them by sending a notification with actions
     */
    func registerToNotifications(userID: String) {
        
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
                    
                    let userRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    
                    if (userRequest.getUserID()) == userID && (userRequest.getStatus() == "0"){
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


