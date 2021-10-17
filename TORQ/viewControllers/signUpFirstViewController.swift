import UIKit

class signUpFirstViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nextbutton: UIButton!
    @IBOutlet weak var errorFirstName: UILabel!
    @IBOutlet weak var errorLastName: UILabel!
    @IBOutlet weak var errorEmail: UILabel!
    @IBOutlet weak var errorPassword: UILabel!
    
    
    
    //MARK: - Variables
    var userFirstName: String?
    var userLastName: String?
    var userEmail: String?
    var userPassword: String?
    
    //MARK: - Overriden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide the error message and add the border
        errorFirstName.alpha = 0
        errorLastName.alpha = 0
        errorEmail.alpha = 0
        errorPassword.alpha = 0
      
        // First name border
        firstName.setBorder(color: "default", image: UIImage(named: "personDefault")!)
        
        // Last name border
        lastName.setBorder(color: "default", image: UIImage(named: "personDefault")!)
       
        // email border
        email.setBorder(color: "default", image: UIImage(named: "emailDefault")!)
        
        // password border
        password.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        
        configureKeyboard()
    }
    
    //MARK: - Functions
    func configureKeyboard(){
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
            let bottomSpace = self.view.frame.height - (self.nextbutton.frame.origin.y + nextbutton.frame.height)
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
    
    
    func validateFields() -> [String: String ]{
        var error: [String: String ] = ["Empty": "","firstName": "" ,"lastName": "" ,"email": "", "password":""]
        
        // CASE-0: This case validates if the user submits the form with empty fields
        if firstName.text == "" && lastName.text == "" && email.text == "" && password.text == "" {
            error["Empty"] = "Empty Fields"
        }
        
        //CASE-1: This case validate if the user enters empty or nil or a first name that is less tha two charecters. each case with it sub-cases detailed messages explained below.
        
        if firstName.text == nil || firstName.text == "" {
            error["firstName"] = "First Name cannot be empty"
        }
        else if !firstName.text!.isValidName{
//            error["firstName"] = "First Name must be a valid name that has no spaces nor numbers"
              error["firstName"] = "First Name cannot have spaces or numbers"
        }
        else if firstName.text!.count <= 2{
            error["firstName"] = "First Name must be greater than two characters"
        }
        
        
        //CASE-2: This case validate if the user enters empty or nil or a last name that is less tha two charecters. each case with it sub-cases detailed messages explained below.
        
        if lastName.text == nil || lastName.text == ""{
            error["lastName"] = "Last Name cannot be empty"
        }
        else if !lastName.text!.isValidName{
//            error["lastName"] = "Last Name must be a valid name that has no spaces nor numbers"
            error["lastName"] = "Last Name cannot have spaces or numbers"
        }
        else if lastName.text!.count <= 2 {
            error["lastName"] = "Last Name must be greater than two characters"
        }
        
        
        //CASE-3: This case validate if the user enters empty or nil or an invalid email address or if it restricted ( has the same domain as the paramedics "@srca.org.sa" )
        
        if email.text == nil || email.text == "" {
            error["email"] = "Email cannot be empty"
        }
        else if !email.text!.isValidEmail{
            error["email"] = "Please enter a valid email address"
        }
        else if !email.text!.isValidDomain{
            error["email"] = "Please enter a valid user email that does not contain the domain @srca.org.sa"
        }
        
        //CASE-4: This case validate if the user enters empty or nil or an invalid password that has not fulfilled the conditions ( Not less than 8 charecters & has capital letter &  ).
        
        if password.text == nil || password.text == ""{
            error["password"] = "Password cannot be empty"
        }
        else if !password.text!.isValidPassword{
            error["password"] = "Password should not be less than 6 characters"
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
        
        // if all fields were empty
        guard errors["Empty"] == ""  else {
            
            // show error message
            errorFirstName.text = "First name cannot be empty"
//            errorFirstName.isHidden = false
            errorFirstName.alpha = 1
            
            errorLastName.text = "Last name cannot be empty"
//            errorLastName.isHidden = false
            errorLastName.alpha = 1
            
            errorEmail.text = "Email cannot be empty"
//            errorEmail.isHidden = false
            errorEmail.alpha = 1
            
            errorPassword.text = "Password cannot be empty"
//            password.isHidden = false
            errorPassword.alpha = 1
            
            return
        }
        // if the first name has an error
        guard errors["firstName"] == "" else {
            //No need for alerts anymore
            //showALert(message: errors["firstName"]!)
            errorFirstName.text = errors["firstName"]!
//            errorFirstName.isHidden = false
            errorFirstName.alpha = 1
            return
        }
        // if the last name has an error
        guard errors["lastName"] == "" else {
            //No need for alerts anymore
            //showALert(message: errors["lastName"]!)
            //handle the error
            errorLastName.text = errors["lastName"]!
//            errorLastName.isHidden = false
            errorLastName.alpha = 1
            return
        }
        // if the email has an error
        guard errors["email"] == "" else {
            //No need for alerts anymore
            //showALert(message: errors["email"]!)
            //handle the error
            errorEmail.text = errors["email"]
//            errorEmail.isHidden = false
            errorEmail.alpha = 1
            return
        }
        // if the password has an error
        guard errors["password"] == "" else {
            //No need for alerts anymore
            //showALert(message: errors["password"]!)
            //handle the error
            errorPassword.text = errors["password"]
            errorPassword.alpha = 1
            return
        }
        // if no error is detected hide the error view
        errorFirstName.alpha = 0
        errorLastName.alpha = 0
        errorEmail.alpha = 0
        errorPassword.alpha = 0
        
        //2- caching the first sign up screen information
        userFirstName = firstName.text
        userLastName = lastName.text
        userEmail = email.text
        userPassword = password.text
        
        //3- move and pass the data to signUpSecondScreen
        setupTheSecondSignUpScreen()
    }
    
    
    @IBAction func firstNameChanged(_ sender: UITextField) {

        let errors = validateFields()
                // change first name border if  name is not valid, and set error msg
               if  errors["firstName"] != "" {
                   // first name invalid
                   firstName.setBorder(color: "error", image: UIImage(named: "personError")!)
                   errorFirstName.text = errors["firstName"]!
//                   errorFirstName.isHidden = false
                   errorFirstName.alpha = 1
               }
                else {
                    // first name valid
                    firstName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
//                    errorFirstName.isHidden = true
                    errorFirstName.alpha = 0
               }
    }
    
    @IBAction func lastNameEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change last name border if  name is not valid, and set error msg

               if  errors["lastName"] != "" {
                   // last name is invalid
                   lastName.setBorder(color: "error", image: UIImage(named: "personError")!)
                   errorLastName.text = errors["lastName"]!
//                   errorLastName.isHidden = false
                   errorLastName.alpha = 1
               }
                else {
                    // last name is valid
                    lastName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
//                    errorLastName.isHidden = true
                    errorLastName.alpha = 0
               }
    }
    
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change email  border if email is not valid, and set error msg

               if  errors["email"] != "" {
                   email.setBorder(color: "error", image: UIImage(named: "emailError")!)
                   errorEmail.text = errors["email"]!
//                   errorEmail.isHidden = false
                   errorEmail.alpha = 1
               }
                else {
                    email.setBorder(color: "valid", image: UIImage(named: "emailValid")!)
//                    errorEmail.isHidden = true
                    errorEmail.alpha = 0
               }
    }
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        let errors = validateFields()
        // change password  border if password is not valid, and set error msg
            if password.text == nil || password.text == "" || errors["password"] != "" {
                // password is invalid
                password.setBorder(color: "error", image: UIImage(named: "lockError")!)
                errorPassword.text = errors["password"]!
//                errorPassword.isHidden = false
                errorPassword.alpha = 1
            } else{
                // password is valid
                password.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
//                errorPassword.isHidden = true
                errorPassword.alpha = 0
        }
    }
    
}

//MARK: - Extension
//extension signUpFirstViewController: UITextFieldDelegate{
//
//}

