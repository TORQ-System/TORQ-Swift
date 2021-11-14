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
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var birthDate: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var nationalID: UITextField!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var user: User?
    
    
    //MARK: - Constants
    let datePicker = UIDatePicker()
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance( showCloseButton: false, contentViewCornerRadius: 15, buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance( contentViewCornerRadius: 15, buttonCornerRadius: 7, hideWhenBackgroundViewIsTapped: true)
    let settings = ["Change Email","Change Password"]
    let formatter = DateFormatter()
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "MMM d, yyyy"
        
        fetchUserData()
        
        configureButtonView()
        configureInputs()
        configureSegmentControl()
        configureDatePickerView()
        
    }
    //MARK: - Functions
    func configureButtonView(){
//        let gradient: CAGradientLayer = CAGradientLayer()
//                let red = UIColor(red: 191.0/255.0, green: 49.0/255.0, blue: 69.0/255.0, alpha: 1.0).cgColor
//                let pink = UIColor(red: 226.0/255.0, green: 111.0/255.0, blue: 128.0/255.0, alpha: 1.0).cgColor
//
//                accountView.layer.cornerRadius = 25
//                accountView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//                accountView.layer.shadowColor = UIColor.black.cgColor
//                accountView.layer.shadowOpacity = 0.4
//                accountView.layer.shadowOffset = CGSize(width: 5, height: 5)
//                accountView.layer.shadowRadius = 25
//                accountView.layer.shouldRasterize = true
//                accountView.layer.rasterizationScale = UIScreen.main.scale
    }

    func configureInputs(){
        fullName.textColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0)
        email.textColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0)
        phoneNumber.textColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0)
        birthDate.textColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0)
        
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
        email.setBorder(color: "valid", image: UIImage(named: "emailValid")!)
        nationalID.setBorder(color: "default", image: UIImage(named: "idDefault")!)
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
        birthDate.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
        
        fullName.clearsOnBeginEditing = false
        email.clearsOnBeginEditing = false
        phoneNumber.clearsOnBeginEditing = false
        nationalID.isUserInteractionEnabled = false
        
    }
    
    func configureSegmentControl(){
        gender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControl.State.normal)
    }
    
    func configureDatePickerView(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(chooseDate))
        doneButton.tintColor = blueUIColor
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
        
        if fullName.text == nil || fullName.text == "" || !fullName.text!.isValidName || fullName.text!.count <= 2{
            errors["fullName"] = "Error in full name"
        }
        
        if email.text == nil || email.text == "" || !email.text!.trimWhiteSpace().isValidEmail || !email.text!.trimWhiteSpace().isValidDomain{
            errors["email"] = "Error in email"
        }
        
        if nationalID.text == nil || nationalID.text == "" || !nationalID.text!.isValidNationalID{
            errors["nationalID"] = "National ID cannot be empty"
        }
        
        if birthDate.text == nil || birthDate.text == "" {
            errors["birthDate"] = "Date of birth cannot be empty"
        }
        
        if phoneNumber.text == nil || phoneNumber.text == "" || !phoneNumber.text!.isValidPhone {
            errors["phoneNumber"] = "Phone number cannot be empty"
        }
        
        return errors
    }
    
    func updateUserEmail(newEmail: String) -> Bool {
        let currentEmail = Auth.auth().currentUser?.email
        var credential: AuthCredential
        var updateEmail: Bool = false
        
        credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: (user?.getPassword())!)
        
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error)  in
            if error != nil  {
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error occured while authenticating your information", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                updateEmail = false
            } else {
                Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { error in
                    if error != nil {
                        SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error occured while updating your information", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                        updateEmail = false
                    } else{
                        updateEmail = true
                    }
                })
            }
        })
        
        return updateEmail
    }
    //MARK: - @IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
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
            return
        }
        
        guard errors["email"] == "" else{
            email.setBorder(color: "error", image: UIImage(named: "emailError")!)
            return
        }
        
        guard errors["phoneNumber"] == "" else{
            phoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            return
        }
        
        guard errors["birthDate"] == "" else{
            birthDate.setBorder(color: "error", image: UIImage(named: "calendarError")!)
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
                        SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error occured while updating your information", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
        
        email.setBorder(color: "valid", image: UIImage(named: "emailValid")!)
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
        nationalID.setBorder(color: "default", image: UIImage(named: "idDefault")!)
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
        birthDate.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
        
    }
    
    
    @IBAction func fullNameEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["fullName"] == "" else{
            fullName.setBorder(color: "error", image: UIImage(named: "personError")!)
            return
        }
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
    }
    
    @IBAction func phoneNumberEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        
        guard errors["phoneNumber"] == "" else{
            phoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            return
        }
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
    }
    
    @IBAction func emailEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["email"] == "" else{
            email.setBorder(color: "error", image: UIImage(named: "emailError")!)
            return
        }
        email.setBorder(color: "valid", image: UIImage(named: "emailValid")!)
    }
}

//MARK: - Extensions
extension editAccountViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

extension editAccountViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
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
