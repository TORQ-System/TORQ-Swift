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
    @IBOutlet weak var errorNationalID: UILabel!
    @IBOutlet weak var errorPhone: UILabel!
    @IBOutlet weak var errorDOB: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var textFiledsStackView: UIStackView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var roundGradientView: UIView!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var checkBoxButton : UIButton!
    
    
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
    var completedFields: Float = 0.5
    var numberOfCompleted: Int = 4
    var correctField: [String:Bool] = ["nationalID":false, "phone": false, "date":false,"conditions":false]
    // tap gesture variable
    var tap = UITapGestureRecognizer()
    // arrays
    var usersArray : [User] = []
    // chcck var
    var isChecked : Bool?
    
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
    let formatter = DateFormatter()
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "MMM d, yyyy" //Universal format
        percentageLabel.text = "\(calculatePercentage())%"
        progressBar.setProgress(completedFields, animated: true)
        fillUsersArray()
        configureInputs()
        configureButtonView()
        configureTapGesture()
    }
    
    //MARK: - Functions
    func calculatePercentage() -> Int{
        let percentage = Int((Float(numberOfCompleted)/8.0) * 100)
        return percentage
    }
    
    func configureInputs(){
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
        // date
        setupDatePickerView()
        // gender
        gender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControl.State.normal)
        
        // conditions label
        let stringValue = "By signing up, you are accepting our Terms & Conditions, and Privacy Policy"
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Terms & Conditions", withColor: UIColor(red: 73/255, green: 171/255, blue:223/255, alpha: 1.0))
        attributedString.setColorForText(textForAttribute: "Privacy Policy", withColor: UIColor(red: 73/255, green: 171/255, blue:223/255, alpha: 1.0))
        
        conditionsLabel.attributedText = attributedString
        
        conditionsLabel.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        conditionsLabel.addGestureRecognizer(tapgesture)
        
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.conditionsLabel.text else { return }
        let termsAndConditionRange = (text as NSString).range(of: "Terms & Conditions")
        let privacyPolicyRange = (text as NSString).range(of: "Privacy Policy")
        if gesture.didTapAttributedTextInLabel(label: self.conditionsLabel, inRange: privacyPolicyRange) {
            print("user tapped on privacy policy text")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "privacyPolicyViewController") as! privacyPolicyViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else if gesture.didTapAttributedTextInLabel(label: self.conditionsLabel, inRange: termsAndConditionRange){
            print("user tapped on terms and conditions text")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "termsAndConditionsViewController") as! termsAndConditionsViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    func configureButtonView(){
        roundGradientView.layer.cornerRadius = 20
        roundGradientView.layer.shouldRasterize = true
        roundGradientView.layer.rasterizationScale = UIScreen.main.scale
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.cornerRadius = 20
        gradient.colors = [
            UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = roundGradientView.bounds
        roundGradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    func configureTapGesture(){
        tap = UITapGestureRecognizer(target: self, action: #selector(self.signUpClicked(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        buttonView.addGestureRecognizer(tap)
        buttonView.isUserInteractionEnabled = true
    }
    
    func fillUsersArray(){
        ref.child("User").observe(.value) { snapshot in
            for user in snapshot.children{
                let obj = user as! DataSnapshot
                let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                let email = obj.childSnapshot(forPath: "email").value as! String
                let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                let gender = obj.childSnapshot(forPath: "gender").value as! String
                let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                let password = obj.childSnapshot(forPath: "password").value as! String
                let phone = obj.childSnapshot(forPath:  "phone").value as! String
                let user = User(dateOfBirth: dateOfBirth, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password: password, phone: phone)
                self.usersArray.append(user)
            }
        }
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
    
    func validatePhone() -> [String: String] {
        var error = ["phoneExists":""]
        
        for user in usersArray {
            if phone.text != nil && phone.text != "" {
                if user.getPhone() == phone.text {
                    error["phoneExists"] = "Phone number already in use"
                }
            }
        }
        
        return error
    }
    
    func validateNationalID() -> [String: String] {
        var error = ["idExists":""]
        
        for user in usersArray {
            if nationalID.text != nil && nationalID.text != "" {
                if user.getNationalID() == nationalID.text {
                    error["idExists"] = "National ID already in use"
                }
            }
        }
        
        return error
    }
    
    func setupDatePickerView(){
        datePicker.preferredDatePickerStyle = .wheels
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(chooseDate))
        toolbar.setItems([doneButton], animated: true)
        date.inputView = datePicker
        date.inputAccessoryView = toolbar
        datePicker.datePickerMode = .date
        
    }
    
    @objc func chooseDate(){
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
    
    @IBAction func checkBoxTapped(_ sender:UIButton){
        
        //        let errors = validateFields()
        if sender.isSelected {
            // check box is not selected
            sender.isSelected = false
            
        } else {
            // check box selected
            sender.isSelected = true
        }
        
        if checkBoxButton.isSelected == false  && correctField["conditions"]!{
            completedFields-=0.125
            numberOfCompleted-=1
            correctField["conditions"]! = false
        }
        if checkBoxButton.isSelected == true && !correctField["conditions"]!{
            completedFields+=0.125
            numberOfCompleted+=1
            correctField["conditions"]! = true
        }
        
        progressBar.setProgress(completedFields, animated: true)
        percentageLabel.text = "\(calculatePercentage())%"
        
    }
    
    @objc func signUpClicked(_ sender: UITapGestureRecognizer) {
        
        let errors = validateFields()
        let phone_error = validatePhone()
        let natID_error = validateNationalID()
        
        // if fields are empty
        if errors["Empty"] != "" || errors["nationalID"] != "" || errors["date"] != "" || errors["phone"] != "" || phone_error["phoneExists"] != "" || natID_error["idExists"] != "" {
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
        guard natID_error["idExists"] == "" else {
            errorNationalID.text = natID_error["idExists"]!
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
        guard phone_error["phoneExists"] == "" else {
            //handle the error
            errorPhone.text = phone_error["phoneExists"]!
            phone.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            errorPhone.alpha = 1
            return
        }
        // if conditions checkbox was unchecked
        guard checkBoxButton.isSelected == true else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "You must agree on Terms & Conditions and Privacy Policy" , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
            "email": userEmail!.lowercased(),
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
            
            let filteredEmail = self.userEmail!.replacingOccurrences(of: "@", with: "-")
            let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-").lowercased()
            self.ref.child("\(finalEmail)").child("full_name").setValue(self.userFirstName!)
            
            self.ref.child("Sensor").child("S\(id!)/Vib").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/X").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/Y").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/Z").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/longitude").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/latitude").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/time").setValue("0")
            self.ref.child("Sensor").child("S\(id!)/date").setValue("0")
            
            let alertView = SCLAlertView(appearance: self.apperanceWithoutClose)
            alertView.addButton("Let's go", backgroundColor: self.blueUIColor){
                self.goToHomeScreen()
            }
            
            alertView.showCustom("You're all set up!", subTitle: "Welcome to TORQ App, your safety is our concern.", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
            
        }
        
    }
    
    @IBAction func nationalIdEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        let natID_error = validateNationalID()
        
        if errors["nationalID"] == "" && natID_error["idExists"] == "" && !correctField["nationalID"]!{
            completedFields+=0.125
            numberOfCompleted+=1
            correctField["nationalID"]! = true
        }
        
        if (errors["nationalID"] != "" || natID_error["idExists"] != "") && correctField["nationalID"]!{
            completedFields-=0.125
            numberOfCompleted-=1
            correctField["nationalID"]! = false
        }
        
        progressBar.setProgress(completedFields, animated: true)
        percentageLabel.text = "\(calculatePercentage())%"
        
        // change national ID border if national ID is not valid, and set error msg
        if  errors["nationalID"] != "" {
            nationalID.setBorder(color: "error", image: UIImage(named: "idError")!)
            errorNationalID.text = errors["nationalID"]!
            errorNationalID.alpha = 1
        }else if natID_error["idExists"] != "" {
            errorNationalID.text = natID_error["idExists"]!
            nationalID.setBorder(color: "error", image: UIImage(named: "idError")!)
            errorNationalID.alpha = 1
        }
        else {
            nationalID.setBorder(color: "valid", image: UIImage(named: "idValid")!)
            errorNationalID.alpha = 0
        }
    }
    
    @IBAction func phoneEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        let phone_error = validatePhone()
        
        if errors["phone"] == "" && phone_error["phoneExists"] == "" && !correctField["phone"]!{
            completedFields+=0.125
            numberOfCompleted+=1
            correctField["phone"]! = true
        }
        
        if (errors["phone"] != "" || phone_error["phoneExists"] != "") && correctField["phone"]!{
            completedFields-=0.125
            numberOfCompleted-=1
            correctField["phone"]! = false
        }
        
        progressBar.setProgress(completedFields, animated: true)
        percentageLabel.text = "\(calculatePercentage())%"
        
        // change phone border if phone is not valid, and set error msg
        if  errors["phone"] != "" {
            phone.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            errorPhone.text = errors["phone"]!
            errorPhone.alpha = 1
        } else if phone_error["phoneExists"] != "" {
            errorPhone.text = phone_error["phoneExists"]!
            phone.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            errorPhone.alpha = 1
        }
        else {
            phone.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        // Swift 4.1 and below
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        var indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        indexOfCharacter = indexOfCharacter + 4
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
