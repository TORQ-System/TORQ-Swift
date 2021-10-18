//
//  SceneDelegate.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 01/10/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        triggerLocalNotification(title: "Are you okay?", body: "We detcted an impact on your veichle, reply within 10s or we will send an ambulance request.")
    }
    
}

extension SceneDelegate{
    
    func triggerLocalNotification(title: String, body: String){
        
        //Assign contents
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "okayCategory"
        
        //Create actions
        let okayAction = UNNotificationAction(identifier: "okay_action", title: "I'm okay", options: UNNotificationActionOptions.init(rawValue: 0))
        
        let requestAction = UNNotificationAction(identifier: "request_action", title: "No, send request", options: UNNotificationActionOptions.init(rawValue: 0))
        
        let actionCategory = UNNotificationCategory(identifier: "okayCategory", actions: [okayAction, requestAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction) //it will get dismissed
        
        
        UNUserNotificationCenter.current().setNotificationCategories([actionCategory])
        
        //Trigger (time-based) - should be when a child is added from the database
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        //Notification request
        
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        // reigester to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil{
                NSLog("no error found")
            }
            else{
                print("error found: ", error!.localizedDescription)
            }
        }
    }
}
