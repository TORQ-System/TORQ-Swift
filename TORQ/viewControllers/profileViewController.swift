//
//  profileViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit
import Firebase

class profileViewController: UIViewController {
    
    var userID: String?
    let ref = Database.database().reference()
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            retreieveUser()
        }
        
        
        
        

    }
    
    
    private func retreieveUser(){
            ref.child("User").observe(.value) { snapshot in
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                    let email = obj.childSnapshot(forPath: "email").value as! String
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    let gender = obj.childSnapshot(forPath: "gender").value as! String
                    let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                    let password = obj.childSnapshot(forPath: "password").value as! String
                    let phone = obj.childSnapshot(forPath:  "phone").value as! String
                    if obj.key == self.userID {
                        self.user = User(dateOfBirth: dateOfBirth,          email: email, fullName: fullName, gender:        gender, nationalID: nationalID, password:      password, phone: phone)
                        DispatchQueue.main.async {
                            //update UI here
                            
                        }
                    }
                }
            }
    }
}
