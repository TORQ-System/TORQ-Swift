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
    @IBOutlet weak var addECButton: UIButton!
    @IBOutlet weak var noContacts: UILabel!
    
    @IBOutlet weak var noAdded: UILabel!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var userEmail: String?
    var userID: String?
    var eContacts: [emergencyContact] = []
    
    //MARK: - Overriden function
    override func viewDidLoad() {
        super.viewDidLoad()
        showEmergencyContacts(userID: userID!)
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
               // let contactId = obj.childSnapshot(forPath: "contactID").value as! Int
                let name = obj.childSnapshot(forPath: "name").value as! String
                let phone = obj.childSnapshot(forPath: "phone").value as! String
                let senderID = obj.childSnapshot(forPath: "sender").value as! String
                let receiverID = obj.childSnapshot(forPath: "reciever").value as! String
                let sent = obj.childSnapshot(forPath: "sent").value as! String
                let msg = obj.childSnapshot(forPath: "msg").value as! String
                //create a EC object
                let emergencyContact = emergencyContact(name: name, phone_number: phone, senderID:senderID, recieverID: receiverID, sent: sent, contactID: 1, msg: msg, relation: relation)
                
                if ( emergencyContact.getSenderID() == userID ) {
                    self.eContacts.append(emergencyContact)
                    self.contacts.reloadData()
                }
                 
                
             }
          }
       }
        print(self.eContacts)
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @objc func deletefunc(sender:UIButton){
        print("tr")
        let phone = "\(self.eContacts[sender.tag].getPhoneNumber())"
        print(phone)

        self.ref.child("EmergencyContact").queryOrdered(byChild: "phone").observe(.childAdded, with: {(snapchot) in
            if let dec = snapchot.value as? [String:Any]{
                if (dec["phone"] as! String == phone){
                   self.ref.child("EmergencyContact").child(snapchot.key).removeValue()
                    self.contacts.reloadData()
                    print(snapchot.key)
                }
            }
        
        })}
}

extension ViewEmergencyContactViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if ( indexPath.row == eContacts.count ){
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(identifier: "add Emergency contact page identifier") as! AddEmergencyContactViewController
//            vc.userID = userID
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
        }
    }
    
}

    

extension ViewEmergencyContactViewController: UICollectionViewDataSource{
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eContacts.count + 1
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        
        if ( eContacts.count == 0 ) {
            noAdded.alpha = 1
        } else{
            noAdded.alpha = 0
        }
        
        while ( indexPath.row < eContacts.count ){
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ECCollectionViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1).cgColor
        cell.layer.shadowOpacity = 1
        cell.layer.shadowRadius = 70
        cell.layer.shadowOffset = CGSize(width: 5, height: 5)
        cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        cell.name.text = "\(eContacts[indexPath.row].getName())"
        cell.name.numberOfLines = 2
        cell.phone.text = "\(eContacts[indexPath.row].getPhoneNumber())"
        cell.relation.text = "\(eContacts[indexPath.row].getRelation())"
            
            cell.deleteECButton.tag = indexPath.row
            cell.deleteECButton.addTarget(self, action: #selector(deletefunc), for: .touchUpInside)
        return cell
        }
        
            let add = collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath as IndexPath)
            add.layer.cornerRadius = 10
            
            return add
    
}
}

extension ViewEmergencyContactViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 158, height: 158)
    }

    
}




