//
//  signUpSecondViewController.swift
//  TORQ

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class signUpSecondViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var nationalID: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    let datePicker = UIDatePicker()
    var userFirstName: String!
    var userLastName: String!
    var userEmail: String!
    var userPassword: String!
    var userDate: String?
    var userGender: String?
    var userNationalID: String?
    var userPhone: String?
    
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePickerView()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view!.addGestureRecognizer(tap)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    //MARK: - Functions
    
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
        
    }
    
    @objc func keyboardwillShow(notification: NSNotification){
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardHieght = keyboardFrame.cgRectValue.height
            let bottomSpace = self.view.frame.height - (self.nextButton.frame.origin.y + nextButton.frame.height)
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
    
    func validateFields() -> [String: String] {
        var errors = ["nationalID":"", "phone":""]
        
        //CASE-1: This case validate if the user enters empty or nil or a nationalID that has chracters.
        if nationalID.text == nil || nationalID.text == ""{
            errors["nationalID"] = "National ID cannot be empty"
        }
        else if !nationalID.text!.isValidNationalID{
            errors["nationalID"] = "Invalid National ID"
        }
        
        //CASE-2: date of birth
        
        
        //CASE-3: This case validate if the user enters empty or nil or a nationalID that has chracters.
        if phone.text == nil || phone.text == "" {
            errors["phone"] = "Phone number cannot be empty"
        }
        else if !phone.text!.isValidPhone {
            errors["phone"] = "Invalid phone number"
        }
        
        //CASE-4: gender
        //no validation is needed
        
        return errors
    }
    
    func setupDatePickerView(){
        datePicker.preferredDatePickerStyle = .wheels
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        datePicker.maximumDate = Date("01-01-2012")
        datePicker.minimumDate = Date("01-01-1950")
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(chooseDate))
        toolbar.setItems([doneButton], animated: true)
        date.inputView = datePicker
        date.inputAccessoryView = toolbar
        datePicker.datePickerMode = .date
        
    }
    
    func showALert(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func chooseDate(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        date.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - @IBActions
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToHomeScreen(_ sender: Any) {
        
        let errors = validateFields()
        // if national id has an error
        guard errors["nationalID"] == "" else {
            //handle the error
            showALert(message: errors["nationalID"]!)
            return
        }
        // if phone number has an error
        guard errors["phone"] == "" else {
            //handle the error
            showALert(message: errors["phone"]!)
            return
        }
        
       
        //2- caching the first sign up screen information
        let genderType = gender.selectedSegmentIndex
        if genderType == 0 {
            userGender = "Female"
        } else if genderType == 1{
            userGender = "Male"
        }
        userDate = date.text
        userNationalID = nationalID.text
        userPhone = phone.text
        
        guard userDate != "" else {
            //handle the error
            showALert(message: "Date cannot be empty")
            return
        }
        //3- create user info
        
        let user: [String: Any] = [
            "firstName": userFirstName!,
            "lastName": userLastName!,
            "email": userEmail!,
            "password": userPassword!,
            "dateOfBirth": userDate!,
            "gender": userGender!,
            "nationalID": userNationalID!,
            "phone": userPhone!
        ]
        
        print(user)
        
        // write the user to firebase auth and realtime database.
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { Result, error in
            // need to specify the error with message
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showALert(message: "invalid email")
                    case .emailAlreadyInUse:
                        self.showALert(message: "email in use")
                    default:
                        self.showALert(message: "invalid credentials")
                    }
                }
            }
            else{
                // go to user home screen
                let id = Result!.user.uid
                print(id)
                self.ref.child("User").child(id).setValue(user)
                self.goToHomeScreen()
            }
            
        }
        
    }
    
}

//MARK: - Extensions
extension signUpSecondViewController: UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }
}
