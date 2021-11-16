import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

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
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var textFiledsStackView: UIStackView!
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    //MARK: - Variables
    var ref = Database.database().reference()
    let datePicker = UIDatePicker()
    var userID: String?
    var userFirstName: String!
    var userEmail: String!
    var userPassword: String!
    var userDate: String?
    var userGender: String?
    var userNationalID: String?
    var userPhone: String?
    var completedFields: Float = 0.625
    var numberOfCompleted: Int = 5
    var correctField: [String:Bool] = ["nationalID":false, "phone": false, "date":false]
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance(
        showCloseButton: false,
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        percentageLabel.text = "\(calculatePercentage())%"
        progressBar.setProgress(completedFields, animated: true)
        
        // hide the error message and add the border
        errorNationalID.alpha = 0
        errorPhone.alpha = 0
        errorDOB.alpha = 0
        
        // national ID border
        nationalID.setBorder(color: "default", image: UIImage(named: "idDefault")!)
        nationalID.clearsOnBeginEditing = false
        // date border
        date.setBorder(color: "default", image: UIImage(named: "calendarDefault")!)
        // phone border
        phone.setBorder(color: "default", image: UIImage(named: "phoneDefault")!)
        phone.clearsOnBeginEditing = false
        setupDatePickerView()
        
    }
    
    //MARK: - Functions
    func calculatePercentage() -> Int{
        let percentage = Int((Float(numberOfCompleted)/8.0) * 100)
        return percentage
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
        date.inputView = datePicker
        date.inputAccessoryView = toolbar
        datePicker.datePickerMode = .date
        
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
        let tb = storyboard.instantiateViewController(identifier: "Home") as! UITabBarController
        let vcs = tb.viewControllers!
        let home = vcs[0] as! userHomeViewController
        home.userEmail = userEmail
        home.userID = userID
        home.modalPresentationStyle = .fullScreen
        present(tb, animated: true, completion: nil)
    }
    
    //MARK: - @IBActions
    
    @IBAction func goToLogin(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(identifier: "loginViewController") as! loginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToHomeScreen(_ sender: Any) {
        
        let errors = validateFields()
        
        // if fields are empty
        if errors["Empty"] != "" || errors["nationalID"] != "" || errors["date"] != "" || errors["phone"] != "" {
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: "Please make sure you entered all fields correctly", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
        }
        
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
        
        progressBar.setProgress(1, animated: true)
        
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
                    case .emailAlreadyInUse:
                        SCLAlertView(appearance: self.apperance).showCustom("Email in Use", subTitle: "The email you entered is already in use, login instead", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                    default:
                        SCLAlertView(appearance: self.apperance).showCustom("Oh no!", subTitle: "An error occured, try again later", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
            self.ref.child("Sensor").child("S\(id!)/date").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/Vib").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/X").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/Y").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/Z").setValue("0")

            let alertView = SCLAlertView(appearance: self.apperanceWithoutClose)
            alertView.addButton("Let's go", backgroundColor: self.blueUIColor){
                self.goToHomeScreen()
            }
            
            alertView.showCustom("You're all set up!", subTitle: "Welcome to TORQ App, your safety is our concern.", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
            
        }
        
    }
    
    @IBAction func nationalIdEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        
        if errors["nationalID"] == "" && !correctField["nationalID"]!{
            completedFields+=0.125
            numberOfCompleted+=1
            correctField["nationalID"]! = true
        }
        
        if errors["nationalID"] != "" && correctField["nationalID"]!{
            completedFields-=0.125
            numberOfCompleted-=1
            correctField["nationalID"]! = false
        }
        
        progressBar.setProgress(completedFields, animated: true)
        percentageLabel.text = "\(calculatePercentage())%"
        
        // change national ID border if national ID is not valid, and set error msg
        if  errors["nationalID"] != "" {
            nationalID.changeBorder(type: "error", image: UIImage(named: "idError")!)
            errorNationalID.text = errors["nationalID"]!
            errorNationalID.alpha = 1
        }
        else {
            nationalID.changeBorder(type: "valid", image: UIImage(named: "idValid")!)
            errorNationalID.alpha = 0
        }
    }
    
    
    
    @IBAction func phoneEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        
        if errors["phone"] == "" && !correctField["phone"]!{
            completedFields+=0.125
            numberOfCompleted+=1
            correctField["phone"]! = true
        }
        
        if errors["phone"] != "" && correctField["date"]!{
            completedFields-=0.125
            numberOfCompleted-=1
            correctField["phone"]! = false
        }
        
        progressBar.setProgress(completedFields, animated: true)
        percentageLabel.text = "\(calculatePercentage())%"
        
        // change phone border if phone is not valid, and set error msg
        if  errors["phone"] != "" {
            phone.changeBorder(type: "error", image: UIImage(named: "phoneError")!)
            errorPhone.text = errors["phone"]!
            errorPhone.alpha = 1
        }
        else {
            phone.changeBorder(type: "valid", image: UIImage(named: "phoneValid")!)
            errorPhone.alpha = 0
        }
    }
    
    @IBAction func dateOfBirthEditing(_ sender: Any) {
        let errors = validateFields()
        if errors["date"] == "" && !correctField["date"]!{
            completedFields+=0.125
            numberOfCompleted+=1
            correctField["date"]! = true
        }
        
        if errors["date"] != "" && correctField["date"]!{
            completedFields-=0.125
            numberOfCompleted-=1
            correctField["date"]! = false
        }
        
        progressBar.setProgress(completedFields, animated: true)
        percentageLabel.text = "\(calculatePercentage())%"
        
        if  errors["date"] == "" {
            date.changeBorder(type: "valid", image: UIImage(named: "calendarValid")!)
            errorDOB.alpha = 0
        }
        
    }
}

//MARK: - Extensions
extension signUpSecondViewController: UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
