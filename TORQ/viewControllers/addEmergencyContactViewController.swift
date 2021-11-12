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
    
    // DB reference
    var ref = Database.database().reference()
    // current user varibles
    var usrID = Auth.auth().currentUser?.uid
    var usrName : String?
    var phoneMatch : String?
    // arrays
    var usersArray: [User] = []
    var emergencyContactArray: [emergencyContact] = []
    // emergency contact varibles
    var fullName: String?
    var phoneNumber: String?
    var emergencyMessage: String?
    var selectedRelationship: String?
    var relationship: String?
    var recieverID : String?
    
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
       
        getUserInfo()
        getEmergencyContactsInfo()
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
    // getting user info from User node in DB and append each user info to usersArray
    func getUserInfo(){
        ref.child("User").observe(.value) { snapshot in
            for user in snapshot.children{
                let obj = user as! DataSnapshot
                let userID = obj.key
                let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                let email = obj.childSnapshot(forPath: "email").value as! String
                let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                let gender = obj.childSnapshot(forPath: "gender").value as! String
                let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                let password = obj.childSnapshot(forPath: "password").value as! String
                let phone = obj.childSnapshot(forPath:  "phone").value as! String
                let user = User(userID: userID, dateOfBirth: dateOfBirth, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password: password, phone: phone)
                self.usersArray.append(user)
                print("Users Array:\(self.usersArray)")
            }
        }
    }
    
    func getEmergencyContactsInfo(){
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
                 self.emergencyContactArray.append(emergencyContact)
                 print("Emergency Contacts Array:\(self.emergencyContactArray)")
             }
        }
    }
    // should go to emergency contacts screen
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    
    // validate form entries
    func validateFields() -> [String: String] {
        
        var errors = ["Empty":"","fullName":"", "phone":"","relationship":"","msg":""]
        
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
        
        return errors
    }
    
    func validateEmergencyPhoneNumber()-> [String: String]{
        var errors = ["phoneMatch":"","phoneDNE":"","phoneExists":""]
        
        // CASE1: Emergency phone match current user phone
        for user in usersArray {
            if user.getUserID() == usrID {
                 phoneMatch = user.getPhone()
                if emergencyContactPhoneNumber.text == phoneMatch {
                    errors["phoneMatch"] = "Emergency phone cannot be the same as yours"
                }
            }
        }
        
        // CASE2: checking if emergency contact number exists in user table in the database
        for user in usersArray {
            if user.getPhone() == emergencyContactPhoneNumber.text && user.getPhone() != phoneMatch {
                recieverID = user.getUserID()
                print("recieverID: \(recieverID!)")
            }
        }
        
        if recieverID == "" || recieverID == nil {
            errors["phoneDNE"] = "The phone number must be registered in TORQ"
        }
    
        // CASE3: check if user have added phone number before (to ensure there are no duplicates)
        for ec in emergencyContactArray {
            if ec.getSenderID() == usrID && ec.getPhoneNumber() == emergencyContactPhoneNumber.text {
                errors["phoneExists"] = "Phone number have been already added"
            }
        }
        
        
        return errors
        
    }
    func getUserFullName(){
        for user in usersArray {
            if user.getUserID() == usrID {
                usrName = user.getFullName()
            }
        }
    }
    
    // Go to Emergency Contatcs View After successful addition
    @IBAction func goToEmergencyContactsScreen(_ sender: Any) {
        
        // to set up default message we need the current user full name
        getUserFullName()
        
        let errors = validateFields()
        let phone_errors = validateEmergencyPhoneNumber()
        
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
