import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class addMedicalReportViewController: UIViewController {
    
    //MARK: - @IBOutlets
        @IBOutlet weak var bloodTypeTextField: UITextField!
        @IBOutlet weak var chronicDisease: UITextField!
        @IBOutlet weak var disability: UITextField!
        @IBOutlet weak var allergy: UITextField!
        @IBOutlet weak var prescribedMedication: UITextField!
        @IBOutlet weak var errorBloodType: UILabel!
        @IBOutlet weak var errorChronicDisease: UILabel!
        @IBOutlet weak var errorDisability: UILabel!
        @IBOutlet weak var errorAllergy: UILabel!
        @IBOutlet weak var errorPrescribedMedication: UILabel!
        @IBOutlet weak var addButton: UIButton!
        @IBOutlet weak var stackView: UIStackView!
    
        //MARK: - Variables
        var ref = Database.database().reference()
        var usrID: String?
        var userBloodType : String?
        var selectedBloodtype : String?
        var userChronicDisease : String?
        var userDisability : String?
        var userAllergy : String?
        var userPrescribedMedication : String?
    
        // picker view variables
        var blood_types = [
            "Please Select",
            "A+",
            "A-",
            "B+",
            "B-",
            "O+",
            "O-",
            "AB+",
            "AB-",
        ]
        let screenWidth = UIScreen.main.bounds.width-10
        let screenHeight = UIScreen.main.bounds.height/2
        var selectedRow = 0
        var pickerView = UIPickerView()
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide error labels
        errorBloodType.alpha = 0
        errorChronicDisease.alpha = 0
        errorDisability.alpha = 0
        errorAllergy.alpha = 0
        errorPrescribedMedication.alpha = 0
        
        // set borders
        bloodTypeTextField.setBorder(color: "default", image: UIImage(named: "bloodDefault")!)
        chronicDisease.setBorder(color: "default", image: UIImage(named: "bandageDefault")!)
        disability.setBorder(color: "default", image: UIImage(named: "disabilityDefault")!)
        allergy.setBorder(color: "default", image: UIImage(named: "heartDefault")!)
        prescribedMedication.setBorder(color: "default", image: UIImage(named: "pillDefault")!)
        
        // set up blood type picker view
        setUpBloodTypePickerView()
        configureKeyboard()
    }
    
    //MARK: - Overriden Functions
    
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
            let bottomSpace = self.view.frame.height - (self.addButton.frame.origin.y + addButton.frame.height + 20)
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
    
    func setUpBloodTypePickerView(){
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closePicker))
        toolbar.setItems([btnDone], animated: true)
        
        bloodTypeTextField.inputView = pickerView
        bloodTypeTextField.inputAccessoryView = toolbar
    }
    @objc func closePicker(){
        bloodTypeTextField.text = blood_types[selectedRow]
        view.endEditing(true)
    }
    // should go to medical report screen not HOME
    func goToHomeScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    // should go to medical report screen not HOME
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    func showALert(message:String){
        //show alert based on the message that is being paased as parameter
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        }
    // validate form entries
    func validateFields() -> [String: String] {
       
        var errors = ["Empty":"","bloodtype":"", "chronicDisease":"","disability":"","allergy":"","prescribedMedication":"","emptyCD":"","emptyDisability":"","emptyallergy":"","emptyPM":""]
        // CASE all fields were empty
        if (bloodTypeTextField.text == "" || bloodTypeTextField.text == "Please Select" || bloodTypeTextField.text == nil ) && chronicDisease.text == "" && disability.text == "" && allergy.text == "" && prescribedMedication.text == "" {
            errors["Empty"] = "Please fill one of the fields or return"
        }
        // CASE: user selected "Please select option "
        if bloodTypeTextField.text == "Please Select" {
            errors["bloodtype"] = "Please select a valid blood type"
        }
//        // CASE: Chronic dieses contain numbers or any unvalid characters
//        if !chronicDisease.text!.isValidWord {
//            errors["chronicDisease"] = "Disease cannot contain numbers or special characters"
//        }
        // since there are no chronic disease less than 2 characters
        if chronicDisease.text!.count == 1 {
            errors["chronicDisease"] = "Chronic Disease must be greater than two characters"
        }
        else if !chronicDisease.text!.isValidSequence && chronicDisease.text != "" {
            errors["chronicDisease"] = "Please seperate each disease with comma"
        }
        // just for changing border to its default color
        else if chronicDisease.text == nil || chronicDisease.text == "" {
            errors["emptyCD"] = "Empty Chronic Disease"
        }
        
//        // CASE: Disability contain numbers or any unvalid characters
//        if !disability.text!.isValidWord {
//            errors["disability"] = "Disabilities cannot contain numbers"
//        }
        // since there are no Disability less than 2 characters
        if disability.text!.count == 1{
            errors["disability"] = "Disabilities must be greater than two characters"
        }
        else if !disability.text!.isValidSequence && disability.text != "" {
            errors["disability"] = "Please seperate each disability with comma"
        }
        else if disability.text == nil || disability.text == ""{
            errors["emptyDisability"] = "Empty Disability"
        }
        
//        // CASE: Allergy contain numbers or any unvalid characters
//        if !allergy.text!.isValidWord {
//            errors["allergy"] = "Allergies cannot contain numbers"
//        }
        // since there are no allergies less than 2 characters
        if allergy.text!.count == 1{
            errors["allergy"] = "Allergies must be greater than two characters"
        }
        else if !allergy.text!.isValidSequence && allergy.text != "" {
            errors["allergy"] = "Please seperate each allergy with comma"
        }
        else if allergy.text == nil || allergy.text == ""{
            errors["emptyallergy"] = "Empty Allergy"
        }
        
//        // CASE: prescribed Medication contain numbers or any unvalid characters
//        if !prescribedMedication.text!.isValidWord {
//            errors["prescribedMedication"] = "Prescribed medication cannot contain numbers"
//        }
        // since there are no prescribed Medications less than 2 characters
        if prescribedMedication.text!.count == 1{
            errors["prescribedMedication"] = "Medication must be greater than two characters"
        }
        else if !prescribedMedication.text!.isValidSequence && prescribedMedication.text != "" {
            errors["prescribedMedication"] = "Please seperate each medication with comma"
        }
        else if prescribedMedication.text == nil || prescribedMedication.text == "" {
            errors["emptyPM"] = "Empty Prescribed Medication"
        }
       
        return errors
    }
    // go to medical report screen after success addition
    @IBAction func goToMedicalReportScreen(_ sender: Any) {
        let errors = validateFields()
        
        // if blood type has an error
        guard errors["bloodtype"] == "" else {
            //handle the error
            errorBloodType.text = errors["bloodtype"]!
            bloodTypeTextField.setBorder(color: "error", image: UIImage(named: "bloodError")!)
            errorBloodType.alpha = 1
            return
        }
        guard errors["Empty"] == "" else {
            showALert(message: "Please make sure you entered all fields correctly")
            return
        }
        // if Chronic Disease has an error
        guard errors["chronicDisease"] == "" else {
            //handle the error
            errorChronicDisease.text = errors["chronicDisease"]!
            chronicDisease.setBorder(color: "error", image: UIImage(named: "bandageError")!)
            errorChronicDisease.alpha = 1
            return
        }
        
        // if disability has an error
        guard errors["disability"] == "" else {
            //handle the error
            errorDisability.text = errors["disability"]!
            disability.setBorder(color: "error", image: UIImage(named: "disabilityError")!)
            errorDisability.alpha = 1
            return
        }
        
        // if allergy has an error
        guard errors["allergy"] == "" else {
            //handle the error
            errorAllergy.text = errors["allergy"]!
            allergy.setBorder(color: "error", image: UIImage(named: "heartError")!)
            errorAllergy.alpha = 1
            return
        }
        
        // if prescribed Medication has an error
        guard errors["prescribedMedication"] == "" else {
            //handle the error
            errorPrescribedMedication.text = errors["prescribedMedication"]!
            prescribedMedication.setBorder(color: "error", image: UIImage(named: "pillError")!)
            errorPrescribedMedication.alpha = 1
            return
        }
        
        
        // if no error is detected hide the error view
        errorBloodType.alpha = 0
        errorChronicDisease.alpha = 0
        errorDisability.alpha = 0
        errorAllergy.alpha = 0
        errorPrescribedMedication.alpha = 0
        
        //check emptiness of fields and set variables
        

            //CASE: empty Blood Type
            if bloodTypeTextField.text == nil || bloodTypeTextField.text == ""  {
                // not mandatory then set it to empty
                userBloodType = "-"
            }
            else {
                userBloodType = bloodTypeTextField.text
            }
            //CASE: empty chronicDisease
            if chronicDisease.text == nil || chronicDisease.text == "" {
                // not mandatory then set it to empty
                userChronicDisease = "-"
            }
            else{
                userChronicDisease = chronicDisease.text!.trimWhiteSpace()
            }

            // CASE: empty disability
            if disability.text == nil || disability.text == "" {
                // not mandatory then set it to empty
                userDisability = "-"
            }
            else {
                userDisability = disability.text!.trimWhiteSpace()
            }
        
            // CASE: empty allergy
            if allergy.text == nil || allergy.text == "" {
                // not mandatory then set it to empty
                userAllergy = "-"
            }
            else {
                userAllergy = allergy.text!.trimWhiteSpace()
            }
            // CASE: empty prescribed Medication
            if prescribedMedication.text == nil || prescribedMedication.text == "" {
                // not mandatory then set it to empty
                userPrescribedMedication = "-"
            }
            else {
                userPrescribedMedication = prescribedMedication.text!.trimWhiteSpace()
            }
 
        
        //3- create user medical report info
        let MedicalReport: [String: Any] = [
            "user_id": usrID!,
            "blood_type": userBloodType!,
            "chronic_disease": userChronicDisease!,
            "disabilities": userDisability!,
            "allergies": userAllergy!,
            "prescribed_medication": userPrescribedMedication!,
        ]
        
        //4- push info to database
        self.ref.child("MedicalReport").childByAutoId().setValue(MedicalReport)
        
        //5- alert of success
        let alert = UIAlertController(title: "Medical Report is Updated!", message: "you can delete it anytime from your medical report page", preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (_) -> Void in
            self.goToHomeScreen()
        }
        alert.addAction(acceptAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func bloodTypeDidEnd(_ sender: UITextField) {
        let errors = validateFields()
               if  errors["bloodtype"] != "" {
                   bloodTypeTextField.setBorder(color: "error", image: UIImage(named: "bloodError")!)
                   errorBloodType.text = errors["bloodtype"]!
                   errorBloodType.alpha = 1
               }
                else {
                    bloodTypeTextField.setBorder(color: "valid", image: UIImage(named: "bloodValid")!)
                    errorBloodType.alpha = 0
               }
    }
    
    @IBAction func chronicDiseaseEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change chronic Disease border if chronic Disease is invalid, and set error msg
               if  errors["chronicDisease"] != "" {
                   chronicDisease.setBorder(color: "error", image: UIImage(named: "bandageError")!)
                   errorChronicDisease.text = errors["chronicDisease"]!
                   errorChronicDisease.alpha = 1
               }
                else if errors["emptyCD"] != ""{
                    chronicDisease.setBorder(color: "default", image: UIImage(named: "bandageDefault")!)
                    errorChronicDisease.alpha = 0
                }
                else {
                    chronicDisease.setBorder(color: "valid", image: UIImage(named: "bandageValid")!)
                    errorChronicDisease.alpha = 0
               }
    
    }
    @IBAction func disabilityEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change disability border if disability is invalid, and set error msg
               if  errors["disability"] != "" {
                   disability.setBorder(color: "error", image: UIImage(named: "disabilityError")!)
                   errorDisability.text = errors["disability"]!
                   errorDisability.alpha = 1
               }
                else if errors["emptyDisability"] != "" {
                   disability.setBorder(color: "default", image: UIImage(named: "disabilityDefault")!)
                   errorDisability.alpha = 0
               }
                else {
                    disability.setBorder(color: "valid", image: UIImage(named: "disabilityValid")!)
                    errorDisability.alpha = 0
               }
   
    }
    @IBAction func allergyEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change allergy border if allergy is invalid, and set error msg
               if  errors["allergy"] != "" {
                   allergy.setBorder(color: "error", image: UIImage(named: "heartError")!)
                   errorAllergy.text = errors["allergy"]!
                   errorAllergy.alpha = 1
               } else if errors["emptyallergy"] != "" {
                   allergy.setBorder(color: "default", image: UIImage(named: "heartDefault")!)
                   errorAllergy.alpha = 0
               }
                else {
                    allergy.setBorder(color: "valid", image: UIImage(named: "heartValid")!)
                    errorAllergy.alpha = 0
               }
    }
    
    @IBAction func predcribedMedsEditingChanged(_ sender: UITextField) {
        let errors = validateFields()
                // change prescribed Medication border if prescribed Medication invalid, and set error msg
               if  errors["prescribedMedication"] != "" {
                   prescribedMedication.setBorder(color: "error", image: UIImage(named: "pillError")!)
                   errorPrescribedMedication.text = errors["prescribedMedication"]!
                   errorPrescribedMedication.alpha = 1
               } else if errors["emptyPM"] != ""{
                   prescribedMedication.setBorder(color: "default", image: UIImage(named: "pillDefault")!)
                   errorPrescribedMedication.alpha = 0
               }
                else {
                    prescribedMedication.setBorder(color: "valid", image: UIImage(named: "pillValid")!)
                    errorPrescribedMedication.alpha = 0
               }
    
    }
    
}
//MARK: - Extensions
extension addMedicalReportViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = Array(blood_types)[row]
        label.sizeToFit()
        return label
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        blood_types.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        bloodTypeTextField.text = blood_types[row]
    }
}

extension addMedicalReportViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

