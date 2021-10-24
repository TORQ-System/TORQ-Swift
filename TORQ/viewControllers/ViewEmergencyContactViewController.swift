//
//  ViewEmergencyContactViewController.swift
//  TORQ
//
//  Created by Norua Alsalem on 17/10/2021.
//

import UIKit
import FirebaseDatabase

class ViewEmergencyContactViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var contacts: UICollectionView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var userEmail: String?
    var userID: String?
    
    //MARK: - Overriden function
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (view.frame.size.width - 10 ) / 2
        let layout = contacts.collectionViewLayout as!  UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        // Do any additional setup after loading the view.
    }
    
    func showEmergencyContacts(userID: String) {
        
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        
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
                
                if (emergencyContact.getSenderID()) == userID) {
                    //show me my contacts
                    
            
                 
                }
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
