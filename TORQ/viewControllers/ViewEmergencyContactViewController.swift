import UIKit
import FirebaseDatabase
import SCLAlertView

class ViewEmergencyContactViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var contacts: UICollectionView!
    @IBOutlet weak var noAdded: UILabel!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var userEmail: String?
    var userID: String?
    var eContacts: [emergencyContact] = []
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(contentViewCornerRadius: 15,buttonCornerRadius: 7,hideWhenBackgroundViewIsTapped: true)
    
    //MARK: - Overriden function
    override func viewDidLoad() {
        self.eContacts = []
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showEmergencyContacts(userID: userID!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.eContacts = []
        showEmergencyContacts(userID: userID!)
    }
    
    func showEmergencyContacts(userID: String) {
        
        let ref = Database.database().reference()
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        
        searchQueue.sync {
            ref.child("EmergencyContact").observe(.childAdded) { snapshot in
                
                let obj = snapshot.value as! [String: Any]
                let name = obj["name"] as! String
                let relation = obj["relation"] as! String
                let phone = obj["phone"] as! String
                let senderID = obj["sender"] as! String
                let receiverID = obj["reciever"] as! String
                let msg = obj["msg"] as! String
                let sent = obj["sent"] as! String
                
                let emergencyContact = emergencyContact(name: name, phone_number: phone, senderID:senderID, recieverID: receiverID, sent: sent, contactID: 1, msg: msg, relation: relation)
                
                if ( emergencyContact.getSenderID() == userID ) {
                    self.eContacts.append(emergencyContact)
                    self.contacts.reloadData()
                }
            }
        }
        print(self.eContacts)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deletefunc(senderr:UIButton){
        let phone = "\(self.eContacts[senderr.tag].getPhoneNumber())"
        
        let alertView = SCLAlertView(appearance: self.apperance)
        alertView.addButton("Delete", backgroundColor: self.redUIColor){
            self.ref.child("EmergencyContact").observeSingleEvent(of: .value, with: { snapshot in
                for EC in snapshot.children{
                    let obj = EC as! DataSnapshot
                    let msg = obj.childSnapshot(forPath: "msg").value as! String
                    let phoneNum = obj.childSnapshot(forPath: "phone").value as! String
                    let name = obj.childSnapshot(forPath: "name").value as! String
                    let reciever = obj.childSnapshot(forPath: "reciever").value as! String
                    let sender = obj.childSnapshot(forPath: "sender").value as! String
                    let relation = obj.childSnapshot(forPath: "relation").value as! String
                    let sent = obj.childSnapshot(forPath: "sent").value as! String
                    
                    print("print flag: \((sender == self.userID) && (phone == phoneNum)))")
                    if (sender == self.userID) && (phone == phoneNum) {
                        _ = emergencyContact(name: name, phone_number: phoneNum, senderID: sender, recieverID: reciever, sent: sent, contactID: 1, msg: msg, relation: relation)
                        //delete it from the array.
                        self.eContacts.remove(at:senderr.tag)
                        //                            self.contacts.reloadData()
                        self.ref.child("EmergencyContact").child(obj.key).removeValue()
                        self.contacts.reloadData()
                        //                            self.dismiss(animated: true, completion: nil)
                    }
                    //                        self.contacts.reloadData()
                }
                //            self.contacts.reloadData()
            })
            //        contacts.reloadData()
        }
        alertView.showCustom("Are you sure?", subTitle: "We will delete your your emergency contact.", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Cancel", animationStyle: SCLAnimationStyle.topToBottom)
    }
}

extension ViewEmergencyContactViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if ( indexPath.row == eContacts.count ){
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "addEmergencyContactViewController") as! addEmergencyContactViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
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
        return CGSize(width: 160, height: 160)
    }
}




