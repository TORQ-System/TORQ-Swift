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
    @IBOutlet weak var errorNationalID: UILabel!
    @IBOutlet weak var errorPhone: UILabel!
    @IBOutlet weak var errorDOB: UILabel!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    let datePicker = UIDatePicker()
    var userID: String?
    var userFirstName: String!
//    var userLastName: String!
    var userEmail: String!
    var userPassword: String!
    var userDate: String?
    var userGender: String?
    var userNationalID: String?
    var userPhone: String?
    
    
    //MARK: - Overriden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hide the error message and add the border
        errorNationalID.alpha = 0
        errorPhone.alpha = 0
        errorDOB.alpha = 0

        // national ID border
        nationalID.setBorder(color: "default", image: UIImage(named: "idDefault")!)
        // date border
        date.setBorder(color: "default", image: UIImage(named: "calendarDefault")!)
        // phone border
        phone.setBorder(color: "default", image: UIImage(named: "phoneDefault")!)
     
        setupDatePickerView()
        configureKeyboard()
        
    }
    
    //MARK: - Functions
    func configureKeyboard() {
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
        var errors = ["Empty":"","nationalID":"", "phone":"","date":""]
        
        // CASE-0 : This case validates submitting form with empty fields
        if nationalID.text == "" && phone.text == "" && date.text == "" {
            errors["Empty"] = "Empty Fields"
        }
        
        //CASE-1: This case validate if the user enters empty or nil or a nationalID that has chracters.each case with it sub-cases detailed messages explained below.
        if nationalID.text == nil || nationalID.text == ""{
            errors["nationalID"] = "National ID cannot be empty"
        }
        else if !nationalID.text!.isValidNationalID{
            errors["nationalID"] = "Invalid National ID"
        }
        
        //CASE-2: date of birth
        // no validation is needed since the date picker has the minimum date as the deafult, thus we're preventing the error from the first place.
        if date.text == nil || date.text == "" {
            errors["date"] = "Date of Birth cannot be empty"
        }
                
        //CASE-3: This case validate if the user enters empty or nil or a nationalID that has chracters.each case with it sub-cases detailed messages explained below.
        if phone.text == nil || phone.text == "" {
            errors["phone"] = "Phone number cannot be empty"
        }
        else if !phone.text!.isValidPhone {
            errors["phone"] = "Invalid phone number"
        }
        
        //CASE-4: gender
        //no validation is needed since we're using segmented control that has "Female" as it's default value, thus we're preventing the error from the first place
        
        return errors
    }
    
    func setupDatePickerView(){
        datePicker.preferredDatePickerStyle = .wheels
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        datePicker.maximumDate = Date("12-31-2012")
        datePicker.minimumDate = Date("01-01-1930")
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(chooseDate))
        toolbar.setItems([doneButton], animated: true)
        doneButton.tintColor = UIColor(red: 0.974, green: 0.666, blue: 0.341, alpha: 1)
        date.inputView = datePicker
        date.inputAccessoryView = toolbar
        datePicker.datePickerMode = .date
        
    }
    // is not needed
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
        vc.userEmail = userEmail
        vc.userID = userID
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - @IBActions
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToHomeScreen(_ sender: Any) {
        
        let errors = validateFields()
        
        // if fields are empty
        
        guard errors["Empty"] == "" else {
            
            // show error message
            errorNationalID.text = "National ID cannot be empty"
            errorNationalID.alpha = 1
            
            errorPhone.text = "Phone cannot be empty"
            errorPhone.alpha = 1
            
            errorDOB.text = "Date of Birth cannot be empty"
            errorDOB.alpha = 1
            
            // set borders
            nationalID.setBorder(color: "error", image: UIImage(named: "idError")!)
           
            phone.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            
            date.setBorder(color: "error", image: UIImage(named: "calendarError")!)
            
            return
        }
        
        // if national id has an error
        guard errors["nationalID"] == "" else {
            //handle the error
            errorNationalID.text = errors["nationalID"]!
            nationalID.setBorder(color: "error", image: UIImage(named: "idError")!)
            errorNationalID.alpha = 1
            return
        }
        // if Date of Birth has an error
        guard errors["date"] == "" else {
            //handle the error
            errorDOB.text = errors["date"]!
            date.setBorder(color: "error", image: UIImage(named: "calendarError")!)
            errorDOB.alpha = 1
            return
        }
        // if phone number has an error
        guard errors["phone"] == "" else {
            //handle the error
            errorPhone.text = errors["phone"]!
            phone.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            errorPhone.alpha = 1
            return
        }
        // if no error is detected hide the error view
        errorNationalID.alpha = 0
        errorPhone.alpha = 0
        errorDOB.alpha = 0
       
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
            "fullName": userFirstName!,
//            "lastName": userLastName!,
            "email": userEmail!,
            "password": userPassword!,
            "dateOfBirth": userDate!,
            "gender": userGender!,
            "nationalID": userNationalID!,
            "phone": userPhone!
        ]
        
        
        // write the user to firebase auth and realtime database.
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { Result, error in
            // need to specify the error with message
            guard error == nil else{
                
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showALert(message: "Invalid email, please try again")
                    case .emailAlreadyInUse:
                        self.showALert(message: "This email is in use try with another one")
                    default:
                        self.showALert(message: "Invalid credentials")
                    }
                }
                return
            }
            
                // go to user home screen
                self.userID = Result!.user.uid
                let id = self.userID
                self.ref.child("User").child(id!).setValue(user)
                self.ref.child("Sensor").child("S\(id!)/longitude").setValue("0")
                self.ref.child("Sensor").child("S\(id!)/latitude").setValue("0")
                self.ref.child("Sensor").child("S\(id!)/time").setValue("0")
            
                //alert sheet to indicate success
                let alert = UIAlertController(title: "You're all set up!", message: "Welcome to TORQ App, your safety is our concern!", preferredStyle: .actionSheet)
                let acceptAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
                    self.goToHomeScreen()
                }
                alert.addAction(acceptAction)
                self.present(alert, animated: true, completion: nil)
        }//Auth
        
    }//Go to home screen
    
    @IBAction func nationalIdEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change national ID border if national ID is not valid, and set error msg
               if  errors["nationalID"] != "" {
                   nationalID.setBorder(color: "error", image: UIImage(named: "idError")!)
                   errorNationalID.text = errors["nationalID"]!
                   errorNationalID.alpha = 1
               }
                else {
                    nationalID.setBorder(color: "valid", image: UIImage(named: "idValid")!)
                    errorNationalID.alpha = 0
               }
    }
    
    
    
    @IBAction func phoneEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change phone border if phone is not valid, and set error msg
               if  errors["phone"] != "" {
                   phone.setBorder(color: "error", image: UIImage(named: "phoneError")!)
                   errorPhone.text = errors["phone"]!
                   errorPhone.alpha = 1
               }
                else {
                    phone.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
                    errorPhone.alpha = 0
               }
    }
    
    @IBAction func dateOfBirthEditing(_ sender: Any) {
        let errors = validateFields()
        if  errors["date"] == "" {
                date.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
                errorDOB.alpha = 0
        }
        
    }
}

//MARK: - Extensions
extension signUpSecondViewController: UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }
}
