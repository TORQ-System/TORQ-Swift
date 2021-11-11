import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class addEmergencyContactViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var emergencyContactFullName: UITextField!
    @IBOutlet weak var emergencyContactPhoneNumber: UITextField!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var errorFullName: UILabel!
    @IBOutlet weak var errorPhoneNumber: UILabel!
    @IBOutlet weak var errorRelationship: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var relationTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var usrID = Auth.auth().currentUser?.uid
    var usrName : String?
    var userInfo: User?
    var recieverInfo: User?
    var eContact = [emergencyContact]()
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
    var selectedRow = 0
    var pickerView = UIPickerView()
    var phoneMatch : String?
    
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
       
        getUserName()
        configureInputs()
    
    }
    //MARK: - Functions
    
    func configureInputs(){
        // hide the error message and add the border
        errorFullName.alpha = 0
        errorPhoneNumber.alpha = 0
        errorRelationship.alpha = 0
        errorMessage.alpha = 0
        
        // Full Name border
        emergencyContactFullName.setBorder(color: "default", image: UIImage(named: "personDefault")!)
        emergencyContactFullName.clearsOnBeginEditing = false
        // phone border
        emergencyContactPhoneNumber.setBorder(color: "default", image: UIImage(named: "phoneDefault")!)
        emergencyContactPhoneNumber.clearsOnBeginEditing = false
        // relationship border
        relationTextField.setBorder(color: "default", image: UIImage(named: "relationshipDefault")!)
        
        // picker view
        setUpRelationshipPickerView()
        
        // message border
        message.setBorder(color: "default", image: UIImage(named: "messageDefault")!)
        message.clearsOnBeginEditing = false
    }
    
    func setUpRelationshipPickerView(){
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closePicker))
        toolbar.setItems([btnDone], animated: true)
        
        relationTextField.inputView = pickerView
        relationTextField.inputAccessoryView = toolbar
    }
    @objc func closePicker(){
        relationTextField.text = relationships[selectedRow]
        view.endEditing(true)
    }
    // getting current user name
    func getUserName(){
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
                if obj.key == self.usrID {
                    self.userInfo = User(dateOfBirth: dateOfBirth, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password: password, phone: phone)
                    self.usrName = fullName
                    self.phoneMatch = phone
                }
            }
        }
    }
    
    // should go to emergency contacts screen
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    
    // validate form entries
    func validateFields() -> [String: String] {
        
        var errors = ["Empty":"","fullName":"", "phone":"","relationship":"","msg":"","phoneMatch":"","phoneDNE":""]
        
        // CASE: empty fields
        if emergencyContactFullName.text?.trimWhiteSpace() == "" && emergencyContactPhoneNumber.text == "" && selectedRow == 0 {
            errors["Empty"] = "Empty Fields"
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
        if selectedRow == 0 {
            errors["relationship"] = "Relationship cannot be empty"
        }
        // CASE: msg greater than 150 characters
        if message.text!.count >= 150 {
            errors["msg"] = "message is too long, try to shorten it"
        }
        
        // Emergency phone match current user phone
        if phoneMatch == emergencyContactPhoneNumber.text {
            errors["phoneMatch"] = "Emergency phone cannot be the same as yours"
        }
        // check if emergency contact number exists in user table in the database and retrieve its info
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
                if phone == self.emergencyContactPhoneNumber.text {
                    self.recieverInfo = User(dateOfBirth: dateOfBirth, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password: password, phone: phone)
                    self.recieverID = obj.key
                    print("Reciever ID: \(obj.key)")
                }
            }
        }
        if recieverID == "" || recieverID == nil {
            errors["phoneDNE"] = "The phone number must be registered in TORQ"
        }
        
        return errors
    }
//    func validatePhoneField()-> [String: String] {
//
//        var phone_errors = ["phoneDNE":""]
//
//        // check if emergency contact number exists in user table in the database and retrieve its info
//        ref.child("User").observe(.value) { snapshot in
//            for user in snapshot.children{
//                let obj = user as! DataSnapshot
//                let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
//                let email = obj.childSnapshot(forPath: "email").value as! String
//                let fullName = obj.childSnapshot(forPath: "fullName").value as! String
//                let gender = obj.childSnapshot(forPath: "gender").value as! String
//                let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
//                let password = obj.childSnapshot(forPath: "password").value as! String
//                let phone = obj.childSnapshot(forPath:  "phone").value as! String
//                if phone == self.emergencyContactPhoneNumber.text {
//                    self.recieverInfo = User(dateOfBirth: dateOfBirth, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password: password, phone: phone)
//                    self.recieverID = obj.key
//                    print("Reciever ID: \(obj.key)")
//                }
//            }
//        }
//        if recieverID == "" || recieverID == nil {
//            phone_errors["phoneDNE"] = "The phone number must be registered in TORQ"
//        }
////        print("Reciever ID outside snapshot: \(String(describing: recieverID))")
//
//        return phone_errors
//
//    }
    
     func validatePhoneFieldTwo() -> [String: String]{
        var phone_errors = ["phoneExists":""]
        
        // Check if phone number has been already added
        ref.child("EmergencyContact").observe(.value) { snapshot in
            for contact in snapshot.children{
                let obj = contact as! DataSnapshot
                let relation = obj.childSnapshot(forPath: "relation").value as! String
                let contactId = 0
                let name = obj.childSnapshot(forPath: "name").value as! String
                let phone = obj.childSnapshot(forPath: "phone").value as! String
                let senderID = obj.childSnapshot(forPath: "sender").value as! String
                let receiverID = obj.childSnapshot(forPath: "reciever").value as! String
                let sent = obj.childSnapshot(forPath: "sent").value as! String
                let msg = obj.childSnapshot(forPath: "msg").value as! String
                //create a EC object
                let emergencyContact = emergencyContact(name: name, phone_number: phone, senderID:senderID, recieverID: receiverID, sent: sent, contactID: contactId, msg: msg, relation: relation)

                if (emergencyContact.getSenderID()) == self.usrID && (emergencyContact.getPhoneNumber() == self.emergencyContactPhoneNumber.text){
                    self.phoneNumExists = emergencyContact.getPhoneNumber()
                    phone_errors["phoneExists"] = "Phone number have been already added"
                }
                
             }
        }

        if phoneNumExists != nil {
            phone_errors["phoneExists"] = "Phone number have been already added"
        }
        
        return phone_errors
        
    }
    
    // Go to Emergency Contatcs View After successful addition
    @IBAction func goToEmergencyContactsScreen(_ sender: Any) {
        
        let errors = validateFields()
        // validate if phone number exists in User table
//        let phone_errors = validatePhoneField()
        // validate if phone number already added
        let phone_errors2 = validatePhoneFieldTwo()
        
        if(errors["fullName"] != "" || errors["phone"] != "" || errors["relationship"] != "" || errors["msg"] != "" ) {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "Make sure you entered all fields correctly" , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
        guard errors["phoneMatch"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: errors["phoneMatch"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        // phone number is not registered in TORQ
//        guard phone_errors["phoneDNE"] == "" else {
//            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: phone_errors["phoneDNE"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
//            return
//        }
        guard errors["phoneDNE"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: errors["phoneDNE"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
//        guard recieverID != nil else {
//            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "The phone number must be registered in TORQ" , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
//            return
//        }
        // Phone has been added before
        guard phone_errors2["phoneExists"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: phone_errors2["phoneExists"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
            message.setBorder(color: "error", image: UIImage(named: "messageError")!)
            errorMessage.alpha = 1
            return
        }
        
        // if msg is empty, then set up TORQ Default msg
        if message.text?.trimWhiteSpace() == "" || message.text?.trimWhiteSpace() == nil {
            message.text = "\(usrName!) had a Car Accident, you are receiving this because \(usrName!) has listed you as an emergency contact"
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
        emergencyMessage = message.text!.trimWhiteSpace()
        
        //3- create Emergency Contact info
        let emergencyContact: [String: Any] = [
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
        let alertView = SCLAlertView(appearance: self.apperanceWithoutClose)
        
        alertView.addButton("Got it!", backgroundColor: self.blueUIColor){
            self.dismiss(animated: true, completion: nil)
        }
        alertView.showCustom("Success!", subTitle: "Your emergency contact has been added successfully", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
        
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
    
    @IBAction func msgEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        if  errors["msg"] != "" {
            message.setBorder(color: "error", image: UIImage(named: "messageError")!)
            errorMessage.text = errors["msg"]!
            errorMessage.alpha = 1
        }else if message.text?.trimWhiteSpace() == nil || message.text?.trimWhiteSpace() == "" {
            message.setBorder(color: "default", image: UIImage(named: "messageDefault")!)
            errorMessage.alpha = 0
        }
        else {
            message.setBorder(color: "valid", image: UIImage(named: "messageValid")!)
            errorMessage.alpha = 0
        }
    }
    
}
//MARK: - Extensions
extension addEmergencyContactViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    
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
    //    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    //        return 60
    //    }
}

extension addEmergencyContactViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
private var __maxLengths = [UITextField: Int]()

extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        if let t = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
}
