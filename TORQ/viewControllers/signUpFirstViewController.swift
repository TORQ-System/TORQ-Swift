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
    
    func showALert(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - @IBActions
    @IBAction func goToSecondScreen(_ sender: Any) {
        
        //1- validation
        if (firstName.text == nil || firstName.text == "") {
            showALert(message: "the first name is missing!")
            return
        }else if (lastName.text == nil || lastName.text == "") {
            showALert(message: "the last name is missing!")
            return
        }else if (email.text == nil || email.text == "") {
            showALert(message: "the email is missing!")
            return
        }else if (password.text == nil || password.text == "") {
            showALert(message: "the password is missing!")
            return
        }
        
        //2- caching the first sign up screen information
        userFirstName = firstName.text
        userLastName = lastName.text
        userEmail = email.text
        userPassword = password.text
        
        //3- move and pass the data to signUpSecondScreen
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUpSecondViewController") as! signUpSecondViewController
        vc.userFirstName = userFirstName
        vc.userLastName = userLastName
        vc.userEmail = userEmail
        vc.userPassword = userPassword
        present(vc, animated: true, completion: nil)
    }
    
}

//MARK: - Extension
extension signUpFirstViewController: UITextFieldDelegate{
    
}

