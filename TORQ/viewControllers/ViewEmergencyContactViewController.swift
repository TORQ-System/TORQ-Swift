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
    var eContacts: [emergencyContact] = []
    
    //MARK: - Overriden function
    override func viewDidLoad() {
        super.viewDidLoad()
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
                
                if (emergencyContact.getSenderID()) == userID){
                    self.eContacts.append(emergencyContact)
                }
                 
                
             }
          }
       }
    }
}

extension ViewEmergencyContactViewController: UICollectionViewDataSource{
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eContacts.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ECCollectionViewCell
        
        

        
        return cell
    }
}

//func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//
//let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Identifier", forIndexPath: indexPath) as! YourCustomcell
//
//cell.imageView.image = UIImage(named: arryImage[indexPath.item] as String)
//
//return cell
//}
//func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
//   if indexPath.item == 0 {
//       //Code to add
//   }else{
//
//   }
//}

