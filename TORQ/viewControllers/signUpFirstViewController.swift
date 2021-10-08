import UIKit

class signUpFirstViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nextbutton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Variables
    var userFirstName: String?
    var userLastName: String?
    var userEmail: String?
    var userPassword: String?
    
    //MARK: - Overriden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        var error: [String: String ] = ["firstName": "" ,"lastName": "" ,"email": "", "password":""]
        
        //CASE-1: This case validate if the user enters empty or nil or a first name that is less tha two charecters. each case with it sub-cases detailed messages explained below.
        
        if firstName.text == nil || firstName.text == "" {
            error["firstName"] = "First Name can't be empty"
        }
        else if firstName.text!.count <= 2{
            error["firstName"] = "First Name must be greater than two characters"
        }
        else if !firstName.text!.isValidName{
            error["firstName"] = "First Name must be a valid name that has no spaces nor numbers"
        }
        
        //CASE-2: This case validate if the user enters empty or nil or a last name that is less tha two charecters. each case with it sub-cases detailed messages explained below.
        
        if lastName.text == nil || lastName.text == ""{
            error["lastName"] = "Last Name can't be empty"
        }
        else if lastName.text!.count <= 2 {
            error["lastName"] = "Last Name must be greater than two characters"
        }
        else if !lastName.text!.isValidName{
            error["lastName"] = "Last Name must be a valid name that has no spaces nor numbers"
        }
        
        //CASE-3: This case validate if the user enters empty or nil or an invalid email address or if it restricted ( has the same domain as the paramedics "@srca.org.sa" )
        
        if email.text == nil || email.text == "" {
            error["email"] = "Email can't be empty"
        }
        else if !email.text!.isValidEmail{
            error["email"] = "Please enter a valid email address"
        }
        else if !email.text!.isValidDomain{
            error["email"] = "Please enter a valid user email that dont contain the domain @srca.org.sa"
        }
        
        //CASE-4: This case validate if the user enters empty or nil or an invalid password that has not fulfilled the conditions ( Not less than 8 charecters & has capital letter &  ).
        
        if password.text == nil || password.text == ""{
            error["password"] = "Password can't be empty"
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

