import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

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
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var roundGradientView: UIView!
    
    
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var usrID: String?
    var userBloodType : String?
    var selectedBloodtype : String?
    var userChronicDisease : String?
    var userDisability : String?
    var userAllergy : String?
    var userPrescribedMedication : String?
    var tap = UITapGestureRecognizer()
    
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
    
    // picker view variables
    var blood_types = [
        "None",
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
        
        configureInputs()
        configureButtonView()
        configureTapGesture()
        
    }
    func configureInputs(){
        //hide error labels
        errorBloodType.alpha = 0
        errorChronicDisease.alpha = 0
        errorDisability.alpha = 0
        errorAllergy.alpha = 0
        errorPrescribedMedication.alpha = 0
        
        // set borders
        bloodTypeTextField.setBorder(color: "default", image: UIImage(named: "bloodDefault")!)
        chronicDisease.setBorder(color: "default", image: UIImage(named: "bandageDefault")!)
        chronicDisease.clearsOnBeginEditing = false
        disability.setBorder(color: "default", image: UIImage(named: "disabilityDefault")!)
        disability.clearsOnBeginEditing = false
        allergy.setBorder(color: "default", image: UIImage(named: "heartDefault")!)
        allergy.clearsOnBeginEditing = false
        prescribedMedication.setBorder(color: "default", image: UIImage(named: "pillDefault")!)
        prescribedMedication.clearsOnBeginEditing = false
        
        // set up blood type picker view
        setUpBloodTypePickerView()
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
            tap = UITapGestureRecognizer(target: self, action: #selector(self.addClicked(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            buttonView.addGestureRecognizer(tap)
            buttonView.isUserInteractionEnabled = true
        }
    
    func configureLayout(){
       
//        addButton.layer.cornerRadius = 20
//        addButton.layer.masksToBounds = true
        
        // back button
//        backButton.roundCorners( [.topRight, .bottomRight], radius: 8)
//        backButton.layer.masksToBounds = true
    }
    
    
    func setUpBloodTypePickerView(){
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closePicker))
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
    
    // validate form entries
    func validateFields() -> [String: String] {
        
        var errors = ["Empty":"","bloodtype":"", "chronicDisease":"","disability":"","allergy":"","prescribedMedication":""]
        
        // CASE all fields were empty
        if (bloodTypeTextField.text == "" || bloodTypeTextField.text == "None" || bloodTypeTextField.text == nil ) && chronicDisease.text == "" && disability.text == "" && allergy.text == "" && prescribedMedication.text == "" {
            errors["Empty"] = "Please fill one of the fields or return"
        }
//        // CASE: user selected "Please select option "
//        if bloodTypeTextField.text == "Please Select" {
//            errors["bloodtype"] = "Please select a valid blood type"
//        }
        // since there are no chronic disease less than 2 characters
        if chronicDisease.text!.count == 1 {
            errors["chronicDisease"] = "Chronic Disease must be greater than two characters"
        }
        else if chronicDisease.text != "" && !chronicDisease.text!.trimWhiteSpace().isValidSequence {
            errors["chronicDisease"] = "Please seperate each disease with comma"
        }
        
        // since there are no Disability less than 2 characters
        if disability.text!.count == 1{
            errors["disability"] = "Disabilities must be greater than two characters"
        }
        else if disability.text != "" && !disability.text!.trimWhiteSpace().isValidSequence {
            errors["disability"] = "Please seperate each disability with comma"
        }

        // since there are no allergies less than 2 characters
        if allergy.text!.count == 1{
            errors["allergy"] = "Allergies must be greater than two characters"
        }
        else if allergy.text != "" && !allergy.text!.trimWhiteSpace().isValidSequence {
            errors["allergy"] = "Please seperate each allergy with comma"
        }
        
        // since there are no prescribed Medications less than 2 characters
        if prescribedMedication.text!.count == 1{
            errors["prescribedMedication"] = "Medication must be greater than two characters"
        }
        else if prescribedMedication.text != "" && !prescribedMedication.text!.trimWhiteSpace().isValidSequence {
            errors["prescribedMedication"] = "Please seperate each medication with comma"
        }
        
        return errors
    }
    // go to medical report screen after success addition
    @objc func addClicked(_ sender: UITapGestureRecognizer) {
        let errors = validateFields()
        
        if errors["bloodtype"] != ""  || errors["chronicDisease"] != "" || errors["chronicDisease"] != "" || errors["disability"] != "" || errors["allergy"] != "" || errors["prescribedMedication"] != "" {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "Please make sure you entered all fields correctly", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
        }
        
        // if blood type has an error
        guard errors["bloodtype"] == "" else {
            //handle the error
            errorBloodType.text = errors["bloodtype"]!
            bloodTypeTextField.setBorder(color: "error", image: UIImage(named: "bloodError")!)
            errorBloodType.alpha = 1
            return
        }
        guard errors["Empty"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: errors["Empty"]!, color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
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
        if bloodTypeTextField.text == nil || bloodTypeTextField.text == "" || bloodTypeTextField.text == "None" {
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
        let alertView = SCLAlertView(appearance: self.apperanceWithoutClose)
        
        alertView.addButton("Got it!", backgroundColor: self.blueUIColor){
            self.goToHomeScreen()
        }
        alertView.showCustom("Success!", subTitle: "Your medical report has been added successfully", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
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
        else if chronicDisease.text == nil || chronicDisease.text == ""{
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
        else if disability.text == nil || disability.text == "" {
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
        } else if allergy.text == nil || allergy.text == "" {
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
        } else if prescribedMedication.text == nil || prescribedMedication.text == "" {
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
extension UIButton {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}

