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
        relationTextField.setBorder(color: "default", image: UIImage(named: "relationshipDefault")!)
        
        // picker view
        setUpRelationshipPickerView()
        
        // message border
        message.setBorder(color: "default", image: UIImage(named: "messageDefault")!)
        configureKeyboardNotification()
    }
    //MARK: - Functions
    
    
    func configureKeyboardNotification(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view!.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
        
    }
    
    @objc func keyboardwillShow(notification: NSNotification){
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardHieght = keyboardFrame.cgRectValue.height
            let bottomSpace = self.view.frame.height - (addButton.frame.origin.y + addButton.frame.height)
            self.view.frame.origin.y -= keyboardHieght - bottomSpace
            
        }
        
    }
    
    @objc func keyboardWillHide(){
        self.view.frame.origin.y = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        ref.child("User").child(usrID!).observeSingleEvent(of: .value , with: { snapshot in
            
            guard let dictionary = snapshot.value as? [String:Any] else {
                return
            }
            let user = User(dateOfBirth: dictionary["dateOfBirth"] as! String, email: dictionary["email"] as! String, fullName: dictionary["fullName"] as! String, gender: dictionary["phone"] as! String, nationalID: dictionary["nationalID"] as! String, password: dictionary["password"] as! String, phone: dictionary["phone"] as! String)
            self.userInfo = user
            self.usrName = user.fullName
            self.phoneMatch = user.phone
        })
        //        print(usrName as Any)
    }
    
    // should go to emergency contacts screen
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    
    // validate form entries
    func validateFields() -> [String: String] {
        
        var errors = ["Empty":"","fullName":"", "phone":"","relationship":"","msg":"","phoneDNE":"","phoneExists":"","phoneMatch":""]
        
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
        // CASE: msg greater than 80 characters
        if message.text!.count >= 80 {
            errors["msg"] = "message is too long, try to shorten it"
        }
        
        // Emergency phone match current user phone
        if phoneMatch == emergencyContactPhoneNumber.text {
            errors["phoneMatch"] = "Emergency phone cannot be the same as yours"
        }
        
        // check of emergency contact number exists in user table in the database and retrieve its info
        ref.child("User").queryOrdered(byChild: "phone").queryEqual(toValue: emergencyContactPhoneNumber.text).observeSingleEvent(of: .value , with: { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            dictionary.forEach({ (key , value) in
                self.recieverID = key
                //                 print("Key \(key), value \(value)")
            })
        })
        if recieverID == "" || recieverID == nil {
            errors["phoneDNE"] = "The phone number must be registered in TORQ"
        }
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
                //                            print(emergencyContact.getPhoneNumber())
                //                            print(emergencyContact.getSenderID())
                
                if (emergencyContact.getSenderID()) == self.usrID && (emergencyContact.getPhoneNumber() == self.emergencyContactPhoneNumber.text){
                    self.phoneNumExists = emergencyContact.getPhoneNumber()
                    //                                print(emergencyContact.getPhoneNumber())
                    //                                print(emergencyContact.getSenderID())
                    errors["phoneExists"] = "Phone number have been already added"
                }
                
            }
        }
        if phoneNumExists != nil {
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
            
            relationTextField.setBorder(color: "error", image: UIImage(named: "relationshipError")!)
            
            // show alert
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "Make sure you entered all fields correctly" , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
        // phone number is not registered in TORQ
        guard errors["phoneDNE"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: errors["phoneDNE"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        // Phone has been added before
        guard errors["phoneExists"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: errors["phoneExists"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
        // chack if phone number equals current user number
        guard errors["phoneMatch"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: errors["phoneMatch"]! , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
        //2- caching information
        fullName = emergencyContactFullName.text!.trimWhiteSpace()
        phoneNumber = emergencyContactPhoneNumber.text
        relationship = relationTextField.text
        emergencyMessage = message.text!.trimWhiteSpace()
        
        //3- create user info
        
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
        alertView.showCustom("Emergency Contact Added!", subTitle: "You can delete it anytime from your emergeny contacts list.", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
        
    }//Go to home screen
    
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
