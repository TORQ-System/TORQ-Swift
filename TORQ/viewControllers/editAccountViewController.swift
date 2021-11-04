//
//  editAccountViewController.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 03/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class editAccountViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var birthDate: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var nationalID: UITextField!
    @IBOutlet weak var settingsCollectionView: UICollectionView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var user: User?
    
    //MARK: - Constants
    let datePicker = UIDatePicker()
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance( showCloseButton: false, contentViewCornerRadius: 15, buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance( contentViewCornerRadius: 15, buttonCornerRadius: 7, hideWhenBackgroundViewIsTapped: true)
    let settings = ["Change Email","Change Password"]
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup user data
        fetchUserData()
        
        //Configure UI elements
        configureAccountView()
        configureInputs()
        configureSegmentControl()
        configureDatePickerView()
        
    }
    
    //MARK: - Functions
    func configureAccountView(){
        accountView.layer.cornerRadius = 50
        accountView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        accountView.layer.shadowColor = UIColor.black.cgColor
        accountView.layer.shadowOpacity = 0.25
        accountView.layer.shadowOffset = CGSize(width: 5, height: 5)
        accountView.layer.shadowRadius = 25
        accountView.layer.shouldRasterize = true
        accountView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func configureInputs(){
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
        nationalID.setBorder(color: "valid", image: UIImage(named: "idValid")!)
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
        birthDate.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
        
        fullName.clearsOnBeginEditing = false
        phoneNumber.clearsOnBeginEditing = false
        nationalID.isUserInteractionEnabled = false
        
    }
    
    func configureSegmentControl(){
        gender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControl.State.normal)
    }
    
    func configureDatePickerView(){
        datePicker.preferredDatePickerStyle = .wheels
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        datePicker.maximumDate = Date("12-31-2012")
        datePicker.minimumDate = Date("01-01-1930")
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(chooseDate))
        toolbar.setItems([doneButton], animated: true)
        doneButton.tintColor = blueUIColor
        birthDate.inputView = datePicker
        birthDate.inputAccessoryView = toolbar
        datePicker.datePickerMode = .date
        
    }
    
    @objc func chooseDate(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        birthDate.text = formatter.string(from: datePicker.date)
        birthDate.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
        self.view.endEditing(true)
    }
    
    func fetchUserData(){
        let userID = Auth.auth().currentUser?.uid
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        ref.child("User").child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let birthDate = value?["dateOfBirth"] as? String ?? "Uknown"
            let email = value?["email"] as? String ?? "Uknown"
            let fullName = value?["fullName"] as? String ?? "Uknown"
            let gender = value?["gender"] as? String ?? "Uknown"
            let nationalID = value?["nationalID"] as? String ?? "Uknown"
            let password = value?["password"] as? String ?? "Uknown"
            let phone = value?["phone"] as? String ?? "Uknown"
            
            self.user = User(dateOfBirth: birthDate, email: email, fullName: fullName, gender: gender, nationalID: nationalID, password:password, phone: phone)
            
            self.datePicker.date = formatter.date(from: birthDate)!
            
            self.fullName.text = fullName
            self.gender.selectedSegmentIndex = self.selectGender(gender: gender)
            self.birthDate.text = birthDate
            self.nationalID.text = nationalID
            self.phoneNumber.text = phone
        })
        
    }
    
    func selectGender(gender:String) -> Int{
        switch gender{
        case "Female":
            return 0
        default:
            return 1
        }
    }
    
    func fetchGender() -> String{
        switch gender.selectedSegmentIndex{
        case 0:
            return "Female"
        default:
            return "Male"
        }
    }
    
    func validateFields() -> [String: String]{
        var errors = ["fullName": "", "nationalID": "", "phoneNumber": "", "birthDate": ""]
        
        if fullName.text == nil || fullName.text == "" || !fullName.text!.isValidName || fullName.text!.count <= 2{
            errors["fullName"] = "Error in full name"
        }
        
        if nationalID.text == nil || nationalID.text == "" || !nationalID.text!.isValidNationalID{
            errors["nationalID"] = "National ID cannot be empty"
        }
        
        if birthDate.text == nil || birthDate.text == "" {
            errors["birthDate"] = "Date of birth cannot be empty"
        }
        
        if phoneNumber.text == nil || phoneNumber.text == "" || !phoneNumber.text!.isValidPhone {
            errors["phoneNumber"] = "Phone number cannot be empty"
        }
        
        return errors
    }
    
    //MARK: - @IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let errors = validateFields()
        let userID = Auth.auth().currentUser?.uid
        
        if errors["nationalID"] != "" || errors["fullName"] != "" || errors["phoneNumber"] != "" || errors["birthDate"] != "" {
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: "Please make sure you entered all fields correctly", color: self.redUIColor, icon: alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
        }
        
        guard errors["nationalID"] == "" else{
            nationalID.setBorder(color: "error", image: UIImage(named: "idError")!)
            return
        }
        
        guard errors["fullName"] == "" else{
            fullName.setBorder(color: "error", image: UIImage(named: "personError")!)
            return
        }
        
        guard errors["phoneNumber"] == "" else{
            phoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            return
        }
        
        guard errors["birthDate"] == "" else{
            birthDate.setBorder(color: "error", image: UIImage(named: "calendarError")!)
            return
        }
        
        
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
        nationalID.setBorder(color: "valid", image: UIImage(named: "idValid")!)
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
        birthDate.setBorder(color: "valid", image: UIImage(named: "calendarValid")!)
        
        let updatedUser = ["birthDate": birthDate.text!,
                           "fullName": fullName.text!,
                           "gender": fetchGender(),
                           "nationalID": nationalID.text!,
                           "phoneNumber": phoneNumber.text!]
        
        
        if(user?.getFullName() == updatedUser["fullName"] && user?.getDateOfBirth() == updatedUser["birthDate"] && user?.getGender() == updatedUser["gender"] && user?.getPhone() == updatedUser["phoneNumber"]){
            SCLAlertView(appearance: self.apperance).showCustom("Credentials Didn't Change", subTitle: "You have not updated your information yet!", color: self.redUIColor, icon: alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        
        ref.child("User").child(userID!).updateChildValues(["fullName": updatedUser["fullName"]!, "phone": updatedUser["phoneNumber"]!, "gender": updatedUser["gender"]!, "dateOfBirth": updatedUser["birthDate"]! ]){
            (error : Error?, ref: DatabaseReference) in
            if error != nil{
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error ocuured, please try again later", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            }
            else{
                SCLAlertView(appearance: self.apperance).showCustom("Success!", subTitle: "We have updated your information", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", animationStyle: SCLAnimationStyle.topToBottom)
                self.fetchUserData()
            }
        }
        
    }
    
    @IBAction func fullNameEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["fullName"] == "" else{
            fullName.setBorder(color: "error", image: UIImage(named: "personError")!)
            return
        }
        fullName.setBorder(color: "valid", image: UIImage(named: "personValid")!)
    }
    
    @IBAction func phoneNumberEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
        
        guard errors["phoneNumber"] == "" else{
            phoneNumber.setBorder(color: "error", image: UIImage(named: "phoneError")!)
            return
        }
        phoneNumber.setBorder(color: "valid", image: UIImage(named: "phoneValid")!)
    }
    
}

//MARK: - Extensions
extension editAccountViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

extension editAccountViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = UIViewController()
        
        switch indexPath.row {
        case 0:
            let viewVC =  storyboard.instantiateViewController(identifier: "changeEmailViewController") as! changeEmailViewController
            viewVC.modalPresentationStyle = .fullScreen
            vc = viewVC
            break
        case 1:
            let viewVC = storyboard.instantiateViewController(identifier: "changePasswordViewController") as! changePasswordViewController
            viewVC.modalPresentationStyle = .fullScreen
            vc = viewVC
            break
        default:
            print("error")
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension editAccountViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accountSettingsViewCell", for: indexPath) as! accountSettingCollectionViewCell
        
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        
        cell.settingLabel.text = settings[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.settingImage.image = UIImage(systemName: "envelope.fill")
        case 1:
            cell.settingImage.image = UIImage(systemName: "lock.fill")
        default:
            print("unknown")
        }
        return cell
    }
}

extension editAccountViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}
private var __maxLengths = [UITextField: Int]()

extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        if let t = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
}
