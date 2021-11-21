//
//  editEmergencyContactViewController.swift
//  TORQ
//
//  Created by a w on 04/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class editEmergencyContactViewController: UIViewController {
   
    //MARK: - @IBOutlets
    @IBOutlet weak var emergencyContactFullName: UITextField!
    @IBOutlet weak var emergencyContactPhoneNumber: UITextField!
    @IBOutlet weak var relationTextField: UITextField!
    @IBOutlet weak var errorFullName: UILabel!
    @IBOutlet weak var errorPhoneNumber: UILabel!
    @IBOutlet weak var errorRelationship: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var roundGradientView: UIView!
    @IBOutlet weak var msgTextView: UITextView!
    
    //MARK: - Variables
    // DB reference
    var ref = Database.database().reference()
    
    // current user varibles
    var usrID = Auth.auth().currentUser?.uid
    var usrName : String?
    var currentUserPhone: String?
    
    // arrays
    var usersArray: [userInfo] = []
    
    // emergency contact varibles
    var fullName: String?
    var phoneNumber: String?
    var emergencyMessage: String?
    var selectedRelationship: String?
    var relationship: String?
    var newRecieverID : String?
    
    // to hold passed array and emergency contact
//    var passedReceiverID : String?
    var emContact: emergencyContact?
    var emergencyContactArray: [emergencyContact] = []
    
   // tap gesture variable
    var tap = UITapGestureRecognizer()
    
    // varibles to hold previously added info
    var ecKey: String?
    var oldFullName: String?
    var oldPhoneNumber: String?
    var oldRelationship: String?
    var oldMsg: String?
    
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
    var selectedRow = 0
    var pickerView = UIPickerView()
    
    //MARK: - Constants
    let screenWidth = UIScreen.main.bounds.width-10
    let screenHeight = UIScreen.main.bounds.height/2
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance(
        showCloseButton: false,
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
   
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInputs()
        getEmergencyContactInfo()
        getUserInfo()
        configureButtonView()
        configureTapGesture()
    
    }
    
    //MARK: - Functions
    
    func configureInputs(){
       
        // hide the error message and add the border
        errorFullName.alpha = 0
        errorPhoneNumber.alpha = 0
        errorRelationship.alpha = 0
        errorMessage.alpha = 0
        
        // Full Name border
        emergencyContactFullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
        emergencyContactFullName.clearsOnBeginEditing = false
        // phone border
        emergencyContactPhoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
        emergencyContactPhoneNumber.clearsOnBeginEditing = false
        // relationship border
        relationTextField.setBorder(color: "valid", image: UIImage(named: "relationshipValid")!)
        // picker view
        setUpRelationshipPickerView()
        // msg text view
        configureMsgTextView()
    }
    func configureButtonView(){
            roundGradientView.layer.cornerRadius = 20
            roundGradientView.layer.shouldRasterize = true
            roundGradientView.layer.rasterizationScale = UIScreen.main.scale
            
            let gradient: CAGradientLayer = CAGradientLayer()
            
            gradient.cornerRadius = 20
            gradient.colors = [
                UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
                UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor
            ]
            
            gradient.locations = [0, 1]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.frame = roundGradientView.bounds
            roundGradientView.layer.insertSublayer(gradient, at: 0)
    }
    func configureTapGesture(){
            tap = UITapGestureRecognizer(target: self, action: #selector(self.saveClicked(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            buttonView.addGestureRecognizer(tap)
            buttonView.isUserInteractionEnabled = true
        }
    
    // get emergency contact information and set up text fields
    func getEmergencyContactInfo(){
        
        self.ref.child("EmergencyContact").observeSingleEvent(of: .value, with: { snapshot in
                    for EC in snapshot.children{
                        let obj = EC as! DataSnapshot
                        let sender = obj.childSnapshot(forPath: "sender").value as! String
                        let phone = obj.childSnapshot(forPath: "phone").value as! String
                        if sender == self.usrID && phone == self.emContact!.getPhoneNumber(){
                            // need the key in order to update the information later
                            self.ecKey = obj.key
                        }
                    }
        })
                    self.oldFullName = emContact!.getName()
                    self.oldPhoneNumber = emContact!.getPhoneNumber()
                    self.oldRelationship = emContact!.getRelation()
                    self.oldMsg = emContact!.getMsg()
                    // set up text fields
                    self.emergencyContactFullName.text = self.oldFullName
                    self.emergencyContactPhoneNumber.text = self.oldPhoneNumber
                    self.relationTextField.text = self.oldRelationship
                    self.msgTextView.text = self.oldMsg

    }
    // getting current user name & phone in order to set up default msg and to validate phone number
    func getUserInfo(){
        ref.child("User").observe(.value) { snapshot in
            for user in snapshot.children{
                let obj = user as! DataSnapshot
                let userID = obj.key
                let phone = obj.childSnapshot(forPath:  "phone").value as! String
                let fullName = obj.childSnapshot(forPath:  "fullName").value as! String
                let user = userInfo(userID: userID, phone: phone)
            
                self.usersArray.append(user)
                
                if userID == self.usrID {
                    self.currentUserPhone = phone
                    self.usrName = fullName
                }
            }
        }
    }
    func setUpRelationshipPickerView(){
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closePicker))
        toolbar.setItems([btnDone], animated: true)
        
        relationTextField.inputView = pickerView
        relationTextField.inputAccessoryView = toolbar
    }
    @objc func closePicker(){
        relationTextField.text = relationships[selectedRow]
        view.endEditing(true)
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func configureMsgTextView(){
        // disable scrolling
        msgTextView.isScrollEnabled = false
        // Round the corners.
        msgTextView.layer.masksToBounds = true

        // Set the size of the roundness.
        msgTextView.layer.cornerRadius = 10

        // Set the thickness of the border.
        msgTextView.layer.borderWidth = 1.5

        // Set the border color to blue.
        msgTextView.layer.borderColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 ).cgColor
        
        // set up placeholder
        msgTextView.text = "Message (Optional)"
        // blue text  color
        msgTextView.textColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 )
        //  set up padding
        msgTextView.textContainerInset = UIEdgeInsets(top: 10,left: 25,bottom: 10,right: 5);
    }
    
    // validate form entries
    func validateFields() -> [String: String] {
        
        var errors = ["Empty":"","fullName":"", "phone":"","relationship":"","msg":"","notUpdated":""]
        
        // CASE: empty fields
        if emergencyContactFullName.text?.trimWhiteSpace() == "" && emergencyContactPhoneNumber.text == "" && selectedRow == 0 {
            errors["Empty"] = "Empty Fields"
        }
        // CASE: user did not update any of the fields
        if emergencyContactFullName.text == oldFullName && emergencyContactPhoneNumber.text == oldPhoneNumber && relationTextField.text == oldRelationship && msgTextView.text == oldMsg {
            errors["notUpdated"] = "You have not updated any information"
        }
        
        //CASE: empty or invalid FULL NAME
        if emergencyContactFullName.text?.trimWhiteSpace() == nil || emergencyContactFullName.text == "" {
            errors["fullName"] = "Full Name cannot be empty"
        }
        else if !emergencyContactFullName.text!.trimWhiteSpace().isValidName{
            errors["fullName"] = "Full Name should contain two words, and no numbers"
        }
        
        // CASE: empty or invalid PHONE NUMBER
        if emergencyContactPhoneNumber.text == nil || emergencyContactPhoneNumber.text == "" {
            errors["phone"] = "Phone number cannot be empty"
        }
        else if !emergencyContactPhoneNumber.text!.isValidPhone {
            errors["phone"] = "Invalid phone number"
        }
        // CASE: relationship not selected
        if selectedRow == 0 && relationTextField.text != oldRelationship {
            errors["relationship"] = "Relationship cannot be empty"
        }
        // CASE: msg greater than 80 characters
        if msgTextView.text!.count >= 135 {
            errors["msg"] = "message is too long, try shortening it"
        }
        
        return errors
    }
    func validateEmergencyPhoneNumber()-> [String: String]{
        var errors = ["phoneMatch":"","phoneDNE":"","phoneExists":""]
        
        // CASE1: Emergency phone match current user phone
        for user in usersArray {
            if user.getUserID() == usrID {
                currentUserPhone = user.getPhone()
                if emergencyContactPhoneNumber.text == currentUserPhone {
                    errors["phoneMatch"] = "Emergency phone cannot be the same as yours"
                }
            }
        }
        
        // CASE2: checking if emergency contact number exists in user table in the database
        for user in usersArray {
            if user.getPhone() == emergencyContactPhoneNumber.text && user.getPhone() != currentUserPhone {
                newRecieverID = user.getUserID()
                print("recieverID: \(newRecieverID!)")
            }
        }
        
        if newRecieverID == "" || newRecieverID == nil {
            errors["phoneDNE"] = "The phone number must be registered in TORQ"
        }
    
        // CASE3: check if user have added phone number before (to ensure there are no duplicates)
        for ec in emergencyContactArray {
            if emergencyContactPhoneNumber.text != oldPhoneNumber {
            if ec.getSenderID() == usrID && ec.getPhoneNumber() == emergencyContactPhoneNumber.text {
                errors["phoneExists"] = "Phone number have been already added"
                newRecieverID = ""
            }
          }
        }
        return errors
        
    }
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    // Go to Emergency Contatcs View After successful update
    @objc func saveClicked(_ sender: UITapGestureRecognizer) {
        let errors = validateFields()
        let phone_errors = validateEmergencyPhoneNumber()
        
//        if(errors["fullName"] != "" || errors["phone"] != "" || errors["relationship"] != "" || errors["msg"] != "" || errors["Empty"] != "") {
//            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "Make sure you entered all fields correctly" , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
//        }
        // if fields are not updated
        guard errors["notUpdated"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "You have not updated any information yet!", color: self.redUIColor, icon: alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        
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
            
            relationTextField.setBorder(color: "error", image: UIImage(named: "relationshipError")!)
            
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
        // chack if phone number equals current user number
        guard phone_errors["phoneMatch"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: phone_errors["phoneMatch"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        // phone number is not registered in TORQ
        guard phone_errors["phoneDNE"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: phone_errors["phoneDNE"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        // Phone has been added before
        guard phone_errors["phoneExists"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: phone_errors["phoneExists"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        // relationship error
        guard errors["relationship"] == "" else {
            //handle the error
            errorRelationship.text = errors["relationship"]!
            errorRelationship.alpha = 1
            relationTextField.setBorder(color: "error", image: UIImage(named: "relationshipError")!)
            return
        }
        guard errors["msg"] == "" else {
            errorMessage.text = errors["msg"]
            // set text color to red
            msgTextView.textColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
            // set border color to red
            msgTextView.layer.borderColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 ).cgColor
            errorMessage.alpha = 1
            return
        }
        
        // if msg is empty, then set up TORQ Default msg
        if msgTextView.text?.trimWhiteSpace() == "" || msgTextView.text == nil || msgTextView.text == "Message (Optional)" {
            msgTextView.text = "\(usrName!) had a Car Accident, you are receiving this because \(usrName!) has listed you as an emergency contact"
        }
        
        // if no error is detected hide the error view
        errorFullName.alpha = 0
        errorPhoneNumber.alpha = 0
        errorRelationship.alpha = 0
        errorMessage.alpha = 0
        
        //2- caching information
        fullName = emergencyContactFullName.text!.trimWhiteSpace()
        phoneNumber = emergencyContactPhoneNumber.text
        relationship = relationTextField.text
        emergencyMessage = msgTextView.text!.trimWhiteSpace()
        
        //3- create Emergency Contact info
        let emergencyContact: [String: Any] = [
            "name": fullName!,
            "phone": phoneNumber!,
            "relation": relationship!,
            "msg": emergencyMessage!,
            "sender": usrID!,
            "sent": "No",
            "reciever": newRecieverID!,
        ]
        
        //4- push info to database
        self.ref.child("EmergencyContact").child(ecKey!).updateChildValues(emergencyContact)
        
        //5- alert of success
        let alertView = SCLAlertView(appearance: self.apperanceWithoutClose)
        
        alertView.addButton("Got it!", backgroundColor: self.blueUIColor){
            self.dismiss(animated: true, completion: nil)
        }
        alertView.showCustom("Success!", subTitle: "Your emergency contact has been updated successfully", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
        
    }
    
    // Editing changed functions
    @IBAction func fullNameEditingChanged(_ sender: UITextField) {
        
        let errors = validateFields()
        // change full Name border if  name invalid, and set error msg
        if  errors["fullName"] != "" {
            // full Name invalid
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
    
    @IBAction func relationshipEditingDidEnd(_ sender: UITextField) {
        let errors = validateFields()
        if  errors["relationship"] != "" {
            relationTextField.setBorder(color: "error", image: UIImage(named: "relationshipError")!)
            errorRelationship.text = errors["relationship"]!
            errorRelationship.alpha = 1
        }
        else {
            relationTextField.setBorder(color: "valid", image: UIImage(named: "relationshipValid")!)
            errorRelationship.alpha = 0
        }
    }
    
    
    } // editEmergencyContactViewCont
                                                              
//MARK: - Extensions
extension editEmergencyContactViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    
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
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        relationTextField.text = relationships[row]
    }
}
extension editEmergencyContactViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if msgTextView.text == "Message (Optional)" {
            msgTextView.text = ""
            // blue text  color
            msgTextView.textColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 )
            // blue border
            msgTextView.layer.borderColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 ).cgColor
            // hide error view
            errorMessage.alpha = 0
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            msgTextView.resignFirstResponder()
        }
        return self.textLimit(existingText: textView.text, newText: text, limit: 135)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            msgTextView.text = "Message (Optional)"
            // gray placeholder text color
            msgTextView.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
            // gray border color
            msgTextView.layer.borderColor = UIColor( red: 163/255, green: 161/255, blue:161/255, alpha: 1.0 ).cgColor
            // hide error view
            errorMessage.alpha = 0
            
        }
        else if textView.text!.count >= 135 {
            errorMessage.text = "message is too long, try shortening it"
            // set text color to red
            msgTextView.textColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
            // set border color to red
            msgTextView.layer.borderColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 ).cgColor
            errorMessage.alpha = 1
        } else {
            // blue text  color
            msgTextView.textColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 )
            // blue border
            msgTextView.layer.borderColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 ).cgColor
            // hide error view
            errorMessage.alpha = 0
        }
    }
}
