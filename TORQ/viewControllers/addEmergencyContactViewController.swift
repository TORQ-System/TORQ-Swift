//
//  addEmergencyContactViewController.swift
//  TORQ
//
//  Created by a w on 20/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class addEmergencyContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var emergencyContactFullName: UITextField!
    @IBOutlet weak var emergencyContactPhoneNumber: UITextField!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var errorFullName: UILabel!
    @IBOutlet weak var errorPhoneNumber: UILabel!
    @IBOutlet weak var errorRelationship: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var relationshipButton: UIButton!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var relationshipImageView: UIImageView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var usrID = Auth.auth().currentUser?.uid
    var usrName : String?
    var userInfo = [userInformation]()
    var fullName: String?
    var phoneNumber: String?
    var emergencyMessage: String?
    var selectedRelationship: String?
    var relationship: String?
    var recieverID : String?
    var phoneNumExists : String?
    
    // picker view variables
    var relationships = [
        "Please Select",
        "Mother",
        "Father",
        "Brother",
        "Sister",
        "Aunt",
        "Uncle",
        "Cousin",
        "Spouse",
        "Friend",
    ]
    let screenWidth = UIScreen.main.bounds.width-10
    let screenHeight = UIScreen.main.bounds.height/2
    var selectedRow = 0
    

    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
       
        getUserName()
        
        
        // remove title from drop down button
        dropdownButton.setTitle("", for: .normal)
        
        // hide the error message and add the border
        errorFullName.alpha = 0
        errorPhoneNumber.alpha = 0
        errorRelationship.alpha = 0
        errorMessage.alpha = 0

        // Full Name border
        emergencyContactFullName.setBorder(color: "default", image: UIImage(named: "personDefault")!)
        // phone border
        emergencyContactPhoneNumber.setBorder(color: "default", image: UIImage(named: "phoneDefault")!)
        // relationship button
        relationshipButton.titleLabel?.font =  .systemFont(ofSize: 14)
        // message border
        message.setBorder(color: "default", image: UIImage(named: "messageDefault")!)

    }
    //MARK: - Functions
    
    // getting current user name
    func getUserName(){
        ref.child("User").child(usrID!).observeSingleEvent(of: .value , with: { snapshot in

            guard let dictionary = snapshot.value as? [String:Any] else {
                return
                }
            let user = userInformation(fullName: dictionary["fullName"] as! String,
                                       email: dictionary["email"] as! String,
                                       password: dictionary["password"] as! String,
                                       nationalID: dictionary["nationalID"] as! String,
                                       dateOfBirth: dictionary["dateOfBirth"] as! String,
                                       phone: dictionary["phone"] as! String,
                                       gender: dictionary["gender"] as! String)
            self.userInfo.append(user)
            self.usrName=user.fullName
        })
        print(usrName as Any)
    }
   
    // should go to emergency contacts screen
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    
    // validate form entries
    func validateFields() -> [String: String] {
       
        var errors = ["Empty":"","fullName":"", "phone":"","relationship":"","msg":"","phoneDNE":"","phoneExists":""]
        
        // CASE: empty fields
        if emergencyContactFullName.text == "" && emergencyContactPhoneNumber.text == "" && selectedRow == 0 {
            errors["Empty"] = "Empty Fields"
        }
        
        //CASE: empty or invalid FULL NAME
        if emergencyContactFullName.text == nil || emergencyContactFullName.text == "" {
            errors["fullName"] = "Full Name cannot be empty"
        }
        else if !emergencyContactFullName.text!.isValidName{
            errors["fullName"] = "Full Name should contain two words, and no numbers"
        }
        else if emergencyContactFullName.text!.count <= 2{
            errors["fullName"] = "Full Name must be greater than two characters"
        }
        
        // CASE: empty or invalid PHONE NUMBER
        if emergencyContactPhoneNumber.text == nil || emergencyContactPhoneNumber.text == "" {
            errors["phone"] = "Phone number cannot be empty"
        }
        else if !emergencyContactPhoneNumber.text!.isValidPhone {
            errors["phone"] = "Invalid phone number"
        }
        // CASE: relationship not selected
        if selectedRow == 0 {
            errors["relationship"] = "Relationship cannot be empty"
        }
        // CASE:  msg greater than 60 characters
        if message.text!.count >= 80 {
            errors["msg"] = "message is too long, try to shorten it"
        }
        // check if EmergencyContact node has children in the DB
        ref.child("EmergencyContact").queryOrdered(byChild: "phone").queryEqual(toValue: emergencyContactPhoneNumber.text).observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {
            errors["phoneExists"] = "Phone number have been already added"
            return
                }
            dictionary.forEach({ (key , value) in
             self.phoneNumExists = key
             print("Key \(key), value \(value)")
            })
        })
        
        // check of emergency contact number exists in user table in the database and retrieve its info
        ref.child("EmergencyContact").queryOrdered(byChild: "sender").queryEqual(toValue: usrID).observeSingleEvent(of: .value , with: { snapshot in

            guard let dictionary = snapshot.value as? [String:Any] else {
                errors["phone"] = "The phone number must be registered in TORQ"
                return
                    }
            dictionary.forEach({ (key , value) in
//                 self.recieverID = key
                 print("Key \(key), value \(value)")
            })
        })
        // check if emergency contact has been added previously
        if recieverID != "" || recieverID != nil {
            ref.child("EmergencyContact").queryOrdered(byChild: "phone").queryEqual(toValue: emergencyContactPhoneNumber.text).observeSingleEvent(of: .value, with: { snapshot in
                
                guard let dictionary = snapshot.value as? [String:Any] else {
                    errors["phoneExists"] = "Phone number have been already added"
                    return
                        }
                    dictionary.forEach({ (key , value) in
                     self.phoneNumExists = key
                     print("Key \(key), value \(value)")
                })
            })
        }
        // check emergency contact
        
        if recieverID == "" || recieverID == nil {
            errors["phoneDNE"] = "The phone number must be registered in TORQ"
        }
        if phoneNumExists != "" || phoneNumExists != nil {
            errors["phoneExists"] = "Phone number have been already added"
        }
        
        return errors
    }
    
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        vc.userEmail = Auth.auth().currentUser?.email
        vc.userID = usrID
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func showALert(message:String){
        //show alert based on the message that is being paased as parameter
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    // Go to Emergency Contatcs View After successfull addition
    @IBAction func goToEmergencyContactsScreen(_ sender: Any) {
        
        let errors = validateFields()
        
        // if fields are empty
        guard errors["Empty"] == "" else {
            
            // show error message
            errorFullName.text = "Full Name cannot be empty"
            errorFullName.alpha = 1
            
            errorPhoneNumber.text = "Phone cannot be empty"
            errorPhoneNumber.alpha = 1
            
            errorRelationship.text = "Relationship cannot be empty"
            errorRelationship.alpha = 1
            
            // set borders
            emergencyContactFullName.setBorder(color: "error", image: UIImage(named: "personError")!)
           
            emergencyContactPhoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            
            return
        }
        
        // if full name has an error
        guard errors["fullName"] == "" else {
            //handle the error
            errorFullName.text = errors["fullName"]!
            emergencyContactFullName.setBorder(color: "error", image: UIImage(named: "personError")!)
            errorFullName.alpha = 1
            return
        }
        // if phone number has an error
        guard errors["phone"] == "" else {
            //handle the error
            errorPhoneNumber.text = errors["phone"]!
            emergencyContactPhoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            errorPhoneNumber.alpha = 1
            return
        }
        guard errors["phoneDNE"] == "" else {
            //handle the error
            showALert(message: errors["phoneDNE"]!)
            return
        }
        guard errors["phoneExists"] == "" else {
            //handle the error
            showALert(message: errors["phoneExists"]!)
            return
        }
        // relationship error
        guard errors["relationship"] == "" else {
            //handle the error
            errorRelationship.text = errors["relationship"]!
            errorRelationship.alpha = 1
            relationshipImageView.image = UIImage(named: "relationshipError")
            return
        }
        guard errors["msg"] == "" else {
            errorMessage.text = errors["msg"]
            message.setBorder(color: "error", image: UIImage(named: "messageError")!)
            errorMessage.alpha = 1
            return
        }
        // if msg is empty, then set up TORQ Default msg
        if message.text == "" || message.text == nil {
            message.text = "\(usrName!) had a Car Accident, you are receiving this because \(usrName!) has listed you as an emergency contact"
        }
        
        
        // if no error is detected hide the error view
        errorFullName.alpha = 0
        errorPhoneNumber.alpha = 0
        errorRelationship.alpha = 0
        errorMessage.alpha = 0
       
        //2- caching information
        fullName = emergencyContactFullName.text
        phoneNumber = emergencyContactPhoneNumber.text
        relationship = selectedRelationship
        emergencyMessage = message.text
        
        //3- create user info
        
        let emergencyContact: [String: Any] = [
//            "contactID": ,
            "name": fullName!,
            "phone": phoneNumber!,
            "relation": relationship!,
            "msg": emergencyMessage!,
            "sender": usrID!,
            "sent": "No",
            "reciever": recieverID!,
        ]
        
        
        //4- push info to database
        self.ref.child("EmergencyContact").childByAutoId().setValue(emergencyContact)
        
        //5- alert of success
        let alert = UIAlertController(title: "Emergency Contact Added!", message: "you can delete it anytime from your emergeny contacts list", preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (_) -> Void in
            self.goToHomeScreen()
        }
        alert.addAction(acceptAction)
        self.present(alert, animated: true, completion: nil)
            
        
    }//Go to home screen
    
    // Editing changed functions
    @IBAction func fullNameEditingChanged(_ sender: UITextField) {
        
        let errors = validateFields()
                // change full Name border if  name invalid, and set error msg
               if  errors["fullName"] != "" {
                   // first name invalid
                   emergencyContactFullName.setBorder(color: "error", image: UIImage(named: "personError")!)
                   errorFullName.text = errors["fullName"]!
                   errorFullName.alpha = 1
               }
                else {
                    // full Name valid
                    emergencyContactFullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
                    errorFullName.alpha = 0
               }
    }
    
    @IBAction func phoneNumberEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                
                // change phone border if phone is not valid, and set error msg
               if  errors["phone"] != "" {
                   emergencyContactPhoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
                   errorPhoneNumber.text = errors["phone"]!
                   errorPhoneNumber.alpha = 1
               }
                else {
                    emergencyContactPhoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
                    errorPhoneNumber.alpha = 0
               }
    }
    
    @IBAction func relationshipEditingDidEnd(_ sender: UIButton) {
        let errors = validateFields()
               if  errors["relationship"] != "" {
                   errorRelationship.text = errors["relationship"]!
                   errorRelationship.alpha = 1
                   relationshipImageView.image = UIImage(named: "relationshipError")
                   relationshipButton.titleLabel?.font =  .systemFont(ofSize: 14)
               }
                else {
                    errorRelationship.alpha = 0
                    relationshipImageView.image = UIImage(named: "relationshipValid")
                    relationshipButton.titleLabel?.font =  .systemFont(ofSize: 14)
               }
    }
    
    @IBAction func msgEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
               if  errors["msg"] != "" {
                   message.setBorder(color: "error", image: UIImage(named: "messageError")!)
                   errorMessage.text = errors["msg"]!
                   errorMessage.alpha = 1
               }
                else {
                    message.setBorder(color: "valid", image: UIImage(named: "messageValid")!)
                    errorMessage.alpha = 0
               }
    }
    
    @IBAction func popUpPicker(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select Relationship", message: "", preferredStyle: .actionSheet)
       
        alert.popoverPresentationController?.sourceView = relationshipButton
        alert.popoverPresentationController?.sourceRect = relationshipButton.bounds
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in }))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {
        (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.relationships)[self.selectedRow]
            let name = selected
            self.selectedRelationship = name
            self.relationshipButton.setTitle(name, for: .normal)
            self.relationshipButton.setTitleColor(UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 ), for: .normal)
            self.relationshipButton.titleLabel?.font =  .systemFont(ofSize: 14)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = Array(relationships)[row]
        label.sizeToFit()
        return label
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         relationships.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
}
//MARK: - Extensions
extension addEmergencyContactViewController: UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }
}
