//
//  signUpFirstViewController.swift
//  TORQ
import UIKit

class signUpFirstViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //MARK: - Variables
    var userFirstName: String?
    var userLastName: String?
    var userEmail: String?
    var userPassword: String?
    
    //MARK: - Overriden Functions

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Functions
    
    func validateFields() -> [String: String ]{
        var error: [String: String ] = ["firstName": "" ,"lastName": "" ,"email": "", "password":""]
        
        //CASE-1: This case validate if the user enters empty or nil or a first name that is less tha two charecters.
            if firstName.text == nil || firstName.text == "" || firstName.text!.count < 2{
                error["firstName"] = "First Name must be grater than two characters, please enter a valid name"
            }
        
        //CASE-2: This case validate if the user enters empty or nil or a last name that is less tha two charecters.
            if lastName.text == nil || lastName.text == "" || lastName.text!.count < 2{
                error["lastName"] = "Last Name must be grater than two characters, please enter a valid name"
            }
        
        //CASE-3: This case validate if the user enters empty or nil or an invalid email address or if it restricted ( has the same domain as the paramedics "@srca.org.sa" )
            if email.text == nil || email.text == "" || !email.text!.isValidEmail || !email.text!.isValidDomain {
                error["email"] = "Please enter a valid email address"
            }
        
        //CASE-4: This case validate if the user enters empty or nil or an invalid password that has not fulfilled the conditions ( Not less than 8 charecters & has capital letter &  ).
            if password.text == nil || password.text == "" {
                error["password"] = "Please enter a valid password (Not less than 8 charecters & has capital and small letters and a number ))"
            }

        return error
    }
    
    func setupTheSecondSignUpScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUpSecondViewController") as! signUpSecondViewController
        vc.modalPresentationStyle = .fullScreen
        vc.userFirstName = userFirstName
        vc.userLastName = userLastName
        vc.userEmail = userEmail
        vc.userPassword = userPassword
        present(vc, animated: true, completion: nil)
    }
    
    func showALert(message:String){
        //show alert based on the message that is being paased as parameter
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - @IBActions
    
    @IBAction func goToSecondScreen(_ sender: Any) {
        
        //1- validation of the fields
        let errors = validateFields()
        // if the first name has an error
        guard errors["firstName"] == "" else {
            //handle the error
            showALert(message: errors["firstName"]!)
            return
        }
        // if the last name has an error
        guard errors["lastName"] == "" else {
            //handle the error
            showALert(message: errors["lastName"]!)
            return
        }
        // if the email has an error
        guard errors["email"] == "" else {
            //handle the error
            showALert(message: errors["email"]!)
            return
        }
        // if the password has an error
        guard errors["password"] == "" else {
            //handle the error
            showALert(message: errors["password"]!)
            return
        }

        //2- caching the first sign up screen information
        userFirstName = firstName.text
        userLastName = lastName.text
        userEmail = email.text
        userPassword = password.text
        
        //3- move and pass the data to signUpSecondScreen
        setupTheSecondSignUpScreen()
    }
    
}

//MARK: - Extension
//extension signUpFirstViewController: UITextFieldDelegate{
//
//}

