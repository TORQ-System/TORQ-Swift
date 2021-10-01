//
//  signUpSecondViewController.swift
//  TORQ

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class signUpSecondViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var nationalID: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var userFirstName: String!
    var userLastName: String!
    var userEmail: String!
    var userPassword: String!
    var userDate: Date?
    var userGender: String?
    var userNationalID: String?
    var userPhone: String?
    
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Functions
    
    func showALert(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - @IBActions
    @IBAction func goToThirdScreen(_ sender: Any) {
        
        //1- validation
        if (gender.selectedSegmentIndex == -1) {
            showALert(message: "the gender is missing!")
            return
        }else if (nationalID.text == nil || nationalID.text == "") {
            showALert(message: "the national ID is missing!")
            return
        }else if (phone.text == nil || phone.text == "") {
            showALert(message: "the phone is missing!")
            return
        }
        
        //2- caching the first sign up screen information
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yyyy"
        let userDate = dateFormatter.string(from: date.date)
        let genderType = gender.selectedSegmentIndex
        print(genderType)
        if genderType == 0 {
            userGender = "Female"
        } else if genderType == 1{
            userGender = "Male"
        }
        userNationalID = nationalID.text
        userPhone = phone.text
        
        //3- create user info
        
        let user: [String: Any] = [
            "firstName": userFirstName!,
            "lastName": userLastName!,
            "email": userEmail!,
            "password": userPassword!,
            "dateOfBirth": userDate,
            "gender": userGender!,
            "nationalID": userNationalID!,
            "phone": userPhone!
        ]
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { Result, error in
            
            guard error == nil else{
                print(error!)
                return
            }
            
            let id = Result!.user.uid
            print(id)
            self.ref.child("User").child(id).setValue(user)
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
                
        
        
    }
    
}

//MARK: - Extensions
