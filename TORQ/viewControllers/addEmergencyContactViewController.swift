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
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var usrID = Auth.auth().currentUser?.uid
    var fullName: String?
    var phoneNumber: String?
    var emergencyMessage: String?
    var selectedRelationship: String?
    var relationship: String?
    var recieverID : String?
    
    // picker view variables
    var relationships = [
        "please select",
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
    
    // getting current user name

    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // relationship border
//        relationship.setBorder(color: "default", image: UIImage(named: "relationshipDefault")!)
        
        // message border
        message.setBorder(color: "default", image: UIImage(named: "messageDefault")!)

    }
    //MARK: - Functions
    // should go to emergency contacts screen
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    
    // validate form entries
    func validateFields() -> [String: String] {
       
        var errors = ["Empty":"","fullName":"", "phone":"","relationship":"","msg":""]
        
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
        
        // check of emergency contact number exists in user table in the database and retrieve its info
        ref.child("User").queryOrdered(byChild: "phone").queryEqual(toValue: emergencyContactPhoneNumber.text).observeSingleEvent(of: .value , with: { snapshot in

            guard let dictionary = snapshot.value as? [String:Any] else {
                errors["phone"] = "The phone number must be registered in TORQ"
                return
                    }
            dictionary.forEach({ (key , value) in
                 self.recieverID = key
                 print("Key \(key), value \(value)")
            })
        })
        if recieverID == "" || recieverID == nil {
            errors["phone"] = "The phone number must be registered in TORQ"
        }
        // CASE: relationship not selected
        if selectedRow == 0 {
            errors["relationship"] = "Relationship cannot be empty"
        }
        
        // CASE:  msg greater than 60 characters
        if message.text!.count >= 60 {
            errors["msg"] = "message is too long, try to shorten it"
        }
        
        return errors
    }
//      Bad try
//    func checkPhoneNumber() -> Bool{
//        var flag = true
//        let searchQueue = DispatchQueue.init(label: "searchQueue")
//
//        searchQueue.sync {
//            //1-  check if  phone number  exists.
//            ref.child("User").queryOrdered(byChild: "phone").queryEqual(toValue: emergencyContactPhoneNumber.text).observeSingleEvent(of: .value , with: { snapshot in
//                guard let dictionary = snapshot.value as? [String:Any] else {
//                    flag = false
//                    return
//                    }
//                    dictionary.forEach({ (key , value) in
//                        self.recieverID = key
//                        Swift.print("Key \(key), value \(value)")
//                })
//            })
//
//        }
//        return flag
//    }
    
    
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        vc.userEmail = Auth.auth().currentUser?.email
        vc.userID = usrID
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
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
//        guard checkPhoneNumber() == true else {
//            errorPhoneNumber.text = "The phone number must be registered in TORQ"
//            emergencyContactPhoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
//            errorPhoneNumber.alpha = 1
//            return
//        }
        // relationship error
        guard errors["relationship"] == "" else {
            //handle the error
            errorRelationship.text = errors["relationship"]!
            errorRelationship.alpha = 1
            return
        }
        guard errors["msg"] == "" else {
            errorMessage.text = errors["msg"]
            message.setBorder(color: "error", image: UIImage(named: "messageError")!)
            errorMessage.alpha = 1
            return
        }
        // if msg is empty
        if message.text == "" || message.text == nil {
            message.text = "-- had a Car Accident, you are receiving this because -- has listed you as an emergency contact"
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
        let acceptAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
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
                
//                if recieverID == "" {
//                    emergencyContactPhoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
//                    errorPhoneNumber.text = "The phone number must be registered in TORQ"
//                    errorPhoneNumber.alpha = 1
//                }
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
               }
                else {
                    errorRelationship.alpha = 0
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
