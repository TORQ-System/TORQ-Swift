//
//  editAccountViewController.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 03/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class editAccountViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var roundGradientView: UIView!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var fullNameError: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var birthDate: UITextField!
    @IBOutlet weak var birthdateError: UILabel!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var phoneNumberError: UILabel!
    @IBOutlet weak var nationalID: UITextField!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var user: User?
    var tap = UITapGestureRecognizer()
    var users: [User] = []
    
    
    //MARK: - Constants
    let datePicker = UIDatePicker()
    let redUIColor = UIColor(red: 200/255, green: 68/255, blue:86/255, alpha: 1.0)
    let blueUIColor = UIColor(red: 49/255, green: 90/255, blue:149/255, alpha: 1.0)
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance( showCloseButton: false, contentViewCornerRadius: 15, buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance( contentViewCornerRadius: 15, buttonCornerRadius: 7, hideWhenBackgroundViewIsTapped: true)
    let formatter = DateFormatter()
    let validColor = UIColor(red: 73/255, green: 171/255, blue:223/255, alpha: 1.0)
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "MMM d, yyyy"
        
        fetchUsers()
        fetchUserData()
        
        configureTapGesture()
        configureButtonView()
        configureInputs()
        configureSegmentControl()
        configureDatePickerView()
        
    }
    //MARK: - Functions
    func fetchUsers() {
        ref.child("User").observe(.value) { [self]snapshot in
            for user in snapshot.children{
                let obj = user as! DataSnapshot
                let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                let email = obj.childSnapshot(forPath: "email").value as! String
                let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                let gender = obj.childSnapshot(forPath: "gender").value as! String
                let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                let password = obj.childSnapshot(forPath: "password").value as! String
                let phone = obj.childSnapshot(forPath:  "phone").value as! String
                
                let compareUser = User(dateOfBirth: dateOfBirth, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password:password, phone: phone)
                if Auth.auth().currentUser?.uid == obj.key {
                    print("current user")
                } else{
                users.append(compareUser)
                }
            }
        }
    }
    
    func configureTapGesture(){
        tap = UITapGestureRecognizer(target: self, action: #selector(self.saveClicked(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        buttonView.addGestureRecognizer(tap)
        buttonView.isUserInteractionEnabled = true
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
    
    func configureInputs(){
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
        email.setBorder(color: "valid", image: UIImage(named: "emailValid")!)
        nationalID.setBorder(color: "default", image: UIImage(named: "idDefault")!)
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
        birthDate.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
        
        fullName.textColor = validColor
        email.textColor = validColor
        phoneNumber.textColor = validColor
        birthDate.textColor = validColor
        
        fullNameError.alpha = 0
        emailError.alpha = 0
        phoneNumberError.alpha = 0
        birthdateError.alpha = 0
        
        nationalID.isUserInteractionEnabled = false
    }
    
    func configureSegmentControl(){
        gender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControl.State.normal)
    }
    
    func configureDatePickerView(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(chooseDate))
        doneButton.tintColor = validColor
        toolbar.setItems([doneButton], animated: true)
        
        birthDate.inputView = datePicker
        birthDate.inputAccessoryView = toolbar
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date("12-31-2012")
        datePicker.minimumDate = Date("01-01-1930")
        
    }
    
    @objc func chooseDate(){
        birthDate.text = formatter.string(from: datePicker.date)
        birthDate.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
        
        self.view.endEditing(true)
    }
    
    @objc func saveClicked(_ sender: UITapGestureRecognizer) {
        let errors = validateFields()
        let userID = Auth.auth().currentUser?.uid
        
        if errors["nationalID"] != "" || errors["fullName"] != "" || errors["phoneNumber"] != "" || errors["birthDate"] != "" ||  errors["email"] != ""{
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: "Please make sure you entered all fields correctly", color: self.redUIColor, icon: alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
        }
        
        guard errors["nationalID"] == "" else{
            nationalID.setBorder(color: "error", image: UIImage(named: "idError")!)
            return
        }
        
        guard errors["fullName"] == "" else{
            fullName.setBorder(color: "error", image: UIImage(named: "personError")!)
            fullNameError.text = errors["fullName"]!
            fullNameError.alpha = 1
            return
        }
        
        guard errors["email"] == "" else{
            email.setBorder(color: "error", image: UIImage(named: "emailError")!)
            emailError.text = errors["email"]!
            emailError.alpha = 1
            return
        }
        
        guard errors["phoneNumber"] == "" else{
            phoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            phoneNumberError.text = errors["phoneNumber"]!
            phoneNumberError.alpha = 1
            return
        }
        
        guard errors["birthDate"] == "" else{
            birthDate.setBorder(color: "error", image: UIImage(named: "calendarError")!)
            birthdateError.text = errors["birthDate"]!
            birthdateError.alpha = 1
            return
        }
        
        let updatedUser = ["birthDate": birthDate.text!,
                           "fullName": fullName.text!,
                           "email": email.text!.trimWhiteSpace(),
                           "gender": fetchGender(),
                           "nationalID": nationalID.text!,
                           "phoneNumber": phoneNumber.text!]
        
        if(user?.getFullName() == updatedUser["fullName"] && user?.getEmail() == updatedUser["email"]  && user?.getDateOfBirth() == updatedUser["birthDate"] && user?.getGender() == updatedUser["gender"] && user?.getPhone() == updatedUser["phoneNumber"]){
            SCLAlertView(appearance: self.apperance).showCustom("Credentials Didn't Change", subTitle: "You have not updated your information yet!", color: self.redUIColor, icon: alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        
        let currentEmail = Auth.auth().currentUser?.email
        var credential: AuthCredential
        
        credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: (user?.getPassword())!)
        
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error)  in
            if error != nil  {
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error occured while authenticating your information", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            } else {
                Auth.auth().currentUser?.updateEmail(to: updatedUser["email"]!, completion: { error in
                    if error != nil {
                        SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "The email entered is already in use", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                    } else{
                        self.ref.child("User").child(userID!).updateChildValues(["fullName": updatedUser["fullName"]!, "email": updatedUser["email"]!, "phone": updatedUser["phoneNumber"]!, "gender": updatedUser["gender"]!, "dateOfBirth": updatedUser["birthDate"]! ]){
                            (error : Error?, ref: DatabaseReference) in
                            if error != nil{
                                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error ocuured, please try again later", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                            }
                            else{
                                SCLAlertView(appearance: self.apperance).showCustom("Success!", subTitle: "We have updated your information", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", animationStyle: SCLAnimationStyle.topToBottom)
                                
                                self.fetchUserData()
                            }
                        }
                    }
                })
            }
        })
        
        configureInputs()
    }
    
    func fetchUserData(){
        let userID = Auth.auth().currentUser?.uid
        
        ref.child("User").child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let birthDate = value?["dateOfBirth"] as? String ?? "Uknown"
            let email = value?["email"] as? String ?? "Uknown"
            let fullName = value?["fullName"] as? String ?? "Uknown"
            let gender = value?["gender"] as? String ?? "Uknown"
            let nationalID = value?["nationalID"] as? String ?? "Uknown"
            let password = value?["password"] as? String ?? "Uknown"
            let phone = value?["phone"] as? String ?? "Uknown"
            
            self.user = User(dateOfBirth: birthDate, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password:password, phone: phone)
            self.datePicker.date = Date(birthDate)
            self.fullName.text = fullName
            self.email.text = email
            self.gender.selectedSegmentIndex = self.selectGender(gender: gender)
            self.birthDate.text = birthDate
            self.nationalID.text = nationalID
            self.phoneNumber.text = phone
        })
        
    }
    
    func validatePhoneNumber() -> Bool{
        for user in users {
            if user.getPhone() == phoneNumber.text {
                return false
            }
        }
        return true
    }
    
    func selectGender(gender:String) -> Int{
        switch gender{
        case "Female":
            return 0
        default:
            return 1
        }
    }
    
    func fetchGender() -> String{
        switch gender.selectedSegmentIndex{
        case 0:
            return "Female"
        default:
            return "Male"
        }
    }
    
    func validateFields() -> [String: String]{
        var errors = ["fullName": "", "nationalID": "", "phoneNumber": "", "birthDate": "", "email": ""]
        
        if fullName.text == nil || fullName.text == "" {
            errors["fullName"] = "Full Name cannot be empty"
        }
        else if !fullName.text!.isValidName{
            errors["fullName"] = "Full Name should contain two words, and no numbers"
        } else if fullName.text!.count <= 2{
            errors["fullName"] = "Full Name must be greater than two characters"
        }
        
        if email.text == nil || email.text == ""{
            errors["email"] = "Email cannot be empty"
        }  else if !email.text!.trimWhiteSpace().isValidEmail {
            errors["email"] = "Please enter a valid email address"
        } else if !email.text!.trimWhiteSpace().isValidDomain{
            errors["email"] = "Email should not contain the domain @srca.org.sa"
        }
        
        if nationalID.text == nil || nationalID.text == "" || !nationalID.text!.isValidNationalID{
            errors["nationalID"] = "cannot be empty"
        }
        
        if birthDate.text == nil || birthDate.text == "" {
            errors["birthDate"] = "Date of Birth cannot be empty"
        }
        
        if phoneNumber.text == nil || phoneNumber.text == "" {
            errors["phoneNumber"] = "Phone number cannot be empty"
        } else if !phoneNumber.text!.isValidPhone {
            errors["phoneNumber"] = "Invalid phone number"
        } else if !validatePhoneNumber(){
            errors["phoneNumber"] = "Phone number already in use"
        }
        
        return errors
    }
    

    
    
    //MARK: - @IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fullNameEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["fullName"] == "" else{
            fullName.setBorder(color: "error", image: UIImage(named: "personError")!)
            fullNameError.text = errors["fullName"]!
            fullNameError.alpha = 1
            return
        }
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
        fullNameError.alpha = 0
    }
    
    @IBAction func phoneNumberEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        
        guard errors["phoneNumber"] == "" else{
            phoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            phoneNumberError.text = errors["phoneNumber"]!
            phoneNumberError.alpha = 1
            return
        }
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
        phoneNumberError.alpha = 0
        
    }
    
    @IBAction func emailEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["email"] == "" else{
            email.setBorder(color: "error", image: UIImage(named: "emailError")!)
            emailError.text = errors["email"]!
            emailError.alpha = 1
            return
        }
        email.setBorder(color: "valid", image: UIImage(named: "emailValid")!)
        emailError.alpha = 0
    }
}

//MARK: - Extensions
extension editAccountViewController: UITextFieldDelegate{
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
