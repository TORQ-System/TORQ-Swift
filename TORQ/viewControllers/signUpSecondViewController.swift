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
        
    }
    
    //MARK: - Functions
    
    func validateFields() -> [String: String] {
        var errors = ["nationalID":"", "phone":""]
        
        //CASE-1: This case validate if the user enters empty or nil or a nationalID that has chracters.
        if nationalID.text == nil || nationalID.text == "" ||  !nationalID.text!.isValidNationalID {
            errors["nationalID"] = "Invalid National ID, note that you can't enter numbers nor exceed the limit of 10 digits also it should start with 1"
        }
        
        //CASE-2: date of birth
        //no validation is needed
        
        
        //CASE-3: This case validate if the user enters empty or nil or a nationalID that has chracters.
        if phone.text == nil || phone.text == "" ||  !phone.text!.isValidPhone {
            errors["phone"] = "Invalid phone number, note that you can't enter characters nor exceed the limit of 10 digits also it should start with 05"
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
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - @IBActions
    
    @IBAction func goToHomeScreen(_ sender: Any) {
        
        let errors = validateFields()
        // if the first name has an error
        guard errors["nationalID"] == "" else {
            //handle the error
            showALert(message: errors["nationalID"]!)
            return
        }
        // if the last name has an error
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
            
            guard error == nil else{
                print(error!)
                return
            }
            
            let id = Result!.user.uid
            print(id)
            self.ref.child("User").child(id).setValue(user)
        }
        
        
        goToHomeScreen()
                
        
        
    }
    
}

//MARK: - Extensions
