//
//  addEmergencyContactViewController.swift
//  TORQ
//
//  Created by a w on 20/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class addEmergencyContactViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var emergencyContactFullName: UITextField!
    @IBOutlet weak var emergencyContactPhoneNumber: UITextField!
    @IBOutlet weak var relationship: UITextField!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var errorFullName: UILabel!
    @IBOutlet weak var errorPhoneNumber: UILabel!
    @IBOutlet weak var errorRelationship: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var userID: String?
    var fullName: String?
    var phoneNumber: String?
    var emergencyMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        relationship.setBorder(color: "default", image: UIImage(named: "personDefault")!)
        // message border
        message.setBorder(color: "default", image: UIImage(named: "personDefault")!)

        // Do any additional setup after loading the view.
    }
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    // validate form entries
    func validateFields() -> [String: String] {
        var errors = ["Empty":"","fullName":"", "phone":"","relationship":"","message":""]
        
        //validate full name
        
        // validate phone number
        if emergencyContactPhoneNumber.text == nil || emergencyContactPhoneNumber.text == "" {
            errors["phone"] = "Phone number cannot be empty"
        }
        else if !emergencyContactPhoneNumber.text!.isValidPhone {
            errors["phone"] = "Invalid phone number"
        }
        // check of emergency contact number exists in user table in the date base
        
        //validate relationship
        
        //validate message
        
        
        return errors
    }

    // MARK: - Navigation
    

}
