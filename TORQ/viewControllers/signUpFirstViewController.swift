import UIKit

class signUpFirstViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nextbutton: UIButton!
    @IBOutlet weak var errorEmail: UILabel!
    @IBOutlet weak var errorPassword: UILabel!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var errorConfirmPassword: UILabel!
    @IBOutlet weak var errorFullName: UILabel!
    @IBOutlet weak var fullName: UITextField!
    
    
    //MARK: - Variables
    var userFullName: String?
//    var userLastName: String?
    var userEmail: String?
    var userPassword: String?
    
    //MARK: - Overriden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide the error message and add the border
        errorFullName.alpha = 0
        errorConfirmPassword.alpha = 0
        errorEmail.alpha = 0
        errorPassword.alpha = 0
      
        // First name border
        fullName.setBorder(color: "default", image: UIImage(named: "personDefault")!)
        
        // Last name border
        confirmPassword.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
       
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
        var error: [String: String ] = ["Empty": "","fullName": "" ,"confirmPass": "" ,"email": "", "password":""]
        
        // CASE-0: This case validates if the user submits the form with empty fields
        if fullName.text == "" && email.text == "" && password.text == "" && confirmPassword.text == ""{
            error["Empty"] = "Empty Fields"
        }
        
        //CASE-1: This case validate if the user enters empty or nil or a full Name that is less tha two charecters. each case with it sub-cases detailed messages explained below.
        
        if fullName.text == nil || fullName.text == "" {
            error["fullName"] = "Full Name cannot be empty"
        }
        else if !fullName.text!.isValidName{
//            error["firstName"] = "First Name must be a valid name that has no spaces nor numbers"
              error["fullName"] = "Full Name should contain two words, and no numbers"
        }
        else if fullName.text!.count <= 2{
            error["fullName"] = "Full Name must be greater than two characters"
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
            error["password"] = "Password should have 8 characters with capital & small letters"
        }
        // confirm password checking
        if confirmPassword.text == nil || confirmPassword.text == ""{
            error["confirmPass"] = "Confirm Password cannot be empty"
        }
        else if confirmPassword.text != password.text!{
            error["confirmPass"] = "Passwords does not match"
        }

        return error
    }
    
    func setupTheSecondSignUpScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUpSecondViewController") as! signUpSecondViewController
        vc.modalPresentationStyle = .fullScreen
        vc.userFirstName = userFullName
//        vc.userLastName = userLastName
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
    // next button
    @IBAction func goToSecondScreen(_ sender: Any) {
        
        //1- validation of the fields
        let errors = validateFields()
        
        // if all fields were empty
        guard errors["Empty"] == ""  else {
            
            // show error message
            errorFullName.text = "Full name cannot be empty"
            errorFullName.alpha = 1
            
            errorConfirmPassword.text = "Confirm password cannot be empty"
            errorConfirmPassword.alpha = 1
            
            errorEmail.text = "Email cannot be empty"
            errorEmail.alpha = 1
            
            errorPassword.text = "Password cannot be empty"
            errorPassword.alpha = 1
            
            // set borders
            fullName.setBorder(color: "error", image: UIImage(named: "personError")!)
           
            confirmPassword.setBorder(color: "error", image: UIImage(named: "lockError")!)
            
            email.setBorder(color: "error", image: UIImage(named: "emailError")!)
            
            password.setBorder(color: "error", image: UIImage(named: "lockError")!)
            
            return
        }
        // if full name has an error
        guard errors["fullName"] == "" else {
            //handle the error
            errorFullName.text = errors["fullName"]!
            errorFullName.alpha = 1
            return
        }
        // if the Confirm pass has an error
        guard errors["confirmPass"] == "" else {
            //handle the error
            errorConfirmPassword.text = errors["confirmPass"]
            errorConfirmPassword.alpha = 1
            return
        }
        // if the email has an error
        guard errors["email"] == "" else {
            //handle the error
            errorEmail.text = errors["email"]
            errorEmail.alpha = 1
            return
        }
        // if the password has an error
        guard errors["password"] == "" else {
            //handle the error
            errorPassword.text = errors["password"]
            errorPassword.alpha = 1
            return
        }
        // if no error is detected hide the error view
        errorFullName.alpha = 0
        errorConfirmPassword.alpha = 0
        errorEmail.alpha = 0
        errorPassword.alpha = 0
        
        //2- caching the first sign up screen information
        userFullName = fullName.text
//        userLastName = lastName.text
        userEmail = email.text
        userPassword = password.text
        
        //3- move and pass the data to signUpSecondScreen
        setupTheSecondSignUpScreen()
    }
    
    
    @IBAction func firstNameChanged(_ sender: UITextField) {

        let errors = validateFields()
                // change full Name border if  name invalid, and set error msg
               if  errors["fullName"] != "" {
                   // first name invalid
                   fullName.setBorder(color: "error", image: UIImage(named: "personError")!)
                   errorFullName.text = errors["fullName"]!
                   errorFullName.alpha = 1
               }
                else {
                    // full Name valid
                    fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
                    errorFullName.alpha = 0
               }
    }
    
    @IBAction func lastNameEditingChanged(_ sender: UITextField) {
        confirmPassword.isSecureTextEntry = true
        let errors = validateFields()
                
        // change last name border if confirm Password is invalid, and set error msg
               if  errors["confirmPass"] != "" {
                   // confirm Pass is invalid
                   confirmPassword.setBorder(color: "error", image: UIImage(named: "lockError")!)
                   errorConfirmPassword.text = errors["confirmPass"]!
                   errorConfirmPassword.alpha = 1
               }
                else {
                    // confirm Pass is valid
                    confirmPassword.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
                    errorConfirmPassword.alpha = 0
               }
    }
    
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
              
        // change email  border if email invalid, and set error msg
               if  errors["email"] != "" {
                   email.setBorder(color: "error", image: UIImage(named: "emailError")!)
                   errorEmail.text = errors["email"]!
                   errorEmail.alpha = 1
               }
                else {
                    email.setBorder(color: "valid", image: UIImage(named: "emailValid")!)
                    errorEmail.alpha = 0
               }
    }
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        let errors = validateFields()
        // change password  border if password invalid, and set error msg
            if password.text == nil || password.text == "" || errors["password"] != "" {
                // password is invalid
                password.setBorder(color: "error", image: UIImage(named: "lockError")!)
                errorPassword.text = errors["password"]!
                errorPassword.alpha = 1
            } else{
                // password is valid
                password.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
                errorPassword.alpha = 0
        }
    }
    
}

//MARK: - Extension
//extension signUpFirstViewController: UITextFieldDelegate{
//
//}

