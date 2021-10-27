//
//  addMedicalReportViewController.swift
//  TORQ
//
//  Created by a w on 25/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class addMedicalReportViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - @IBOutlets
       
        @IBOutlet weak var bloodTypeButton: UIButton!
        @IBOutlet weak var dropdownButton: UIButton!
        // MARK: - Text Fields
        @IBOutlet weak var chronicDisease: UITextField!
        @IBOutlet weak var disability: UITextField!
        @IBOutlet weak var allergy: UITextField!
        @IBOutlet weak var prescribedMedication: UITextField!
    
        // MARK: -  Error labels
        @IBOutlet weak var errorBloodType: UILabel!
        @IBOutlet weak var errorChronicDisease: UILabel!
        @IBOutlet weak var errorDisability: UILabel!
        @IBOutlet weak var errorAllergy: UILabel!
        @IBOutlet weak var errorPrescribedMedication: UILabel!
    
    
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var usrID = Auth.auth().currentUser?.uid
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
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // remove title from drop down button and set blood type button
        dropdownButton.setTitle("", for: .normal)
        bloodTypeButton.titleLabel?.font =  .systemFont(ofSize: 14)
        
        //hide error labels
        errorBloodType.alpha = 0
        errorChronicDisease.alpha = 0
        errorDisability.alpha = 0
        errorAllergy.alpha = 0
        errorPrescribedMedication.alpha = 0
        
        // set borders
        chronicDisease.setBorder(color: "default", image: UIImage(named: "bandageDefault")!)
        disability.setBorder(color: "default", image: UIImage(named: "disabilityDefault")!)
        allergy.setBorder(color: "default", image: UIImage(named: "heartDefault")!)
        prescribedMedication.setBorder(color: "default", image: UIImage(named: "pillDefault")!)

    }
    // should go to medical report screen not HOME
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        vc.userEmail = Auth.auth().currentUser?.email
        vc.userID = usrID
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    // should go to medical report screen not HOME
    @IBAction func back(_ sender:Any){
        dismiss(animated: true, completion: nil)
    }
    // validate form entries
    func validateFields() -> [String: String] {
       
        var errors = ["Empty":"","bloodtype":"", "chronicDisease":"","disability":"","allergy":"","prescribedMedication":"","emptyCD":"","emptyDisability":"","emptyallergy":"","emptyPM":""]
        // CASE all fields were empty
        if (selectedBloodtype == "" || selectedBloodtype == "Please Select" || selectedBloodtype == nil ) && chronicDisease.text == "" && disability.text == "" && allergy.text == "" && prescribedMedication.text == "" {
            errors["Empty"] = "Please fill one of the fields or return"
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
//        guard errors["bloodtype"] == "" else {
//            //handle the error
//            errorBloodType.text = errors["bloodtype"]!
//            errorBloodType.alpha = 1
//            return
//        }
        guard errors["Empty"] == "" else {
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
        
        //check emptiness of fields
        
//            if (selectedBloodtype == nil || selectedBloodtype == "") && (chronicDisease.text == nil || chronicDisease.text == "") && ( disability.text == nil || disability.text == "") && (allergy.text == nil || allergy.text == "") && (prescribedMedication.text == nil || prescribedMedication.text == "") {
//                dismiss(animated: true, completion: nil)
//            }

            //CASE: empty Blood Type
            if selectedBloodtype == nil || selectedBloodtype == "" || selectedBloodtype == "Please Select" {
                // not mandatory then set it to empty
                userBloodType = "-"
            }
            else {
                userBloodType = selectedBloodtype
            }
            //CASE: empty chronicDisease
            if chronicDisease.text == nil || chronicDisease.text == "" {
                // not mandatory then set it to empty
                userChronicDisease = "-"
            }
            else{
                userChronicDisease = chronicDisease.text
            }
//            else {
//                userChronicDisease = chronicDisease.text!.components(separatedBy: ",")
//        }
            // CASE: empty disability
            if disability.text == nil || disability.text == "" {
                // not mandatory then set it to empty
                userDisability = "-"
            }
            else {
                userDisability = disability.text
            }
        
            // CASE: empty allergy
            if allergy.text == nil || allergy.text == "" {
                // not mandatory then set it to empty
                userAllergy = "-"
            }
            else {
                userAllergy = allergy.text
            }
            // CASE: empty prescribed Medication
            if prescribedMedication.text == nil || prescribedMedication.text == "" {
                // not mandatory then set it to empty
                userPrescribedMedication = "-"
            }
            else {
                userPrescribedMedication = prescribedMedication.text
            }
            // CASE: If all fields were empty then go back to HOME Screen or Medical report Screen without adding the report to the system DB
//            guard (userBloodType != "-" && userChronicDisease != "-" && userDisability != "-" && userAllergy != "-" && userPrescribedMedication != "-") else {
////                goToHomeScreen()
//                return
//            }
        
        //2- caching information
//        userBloodType = selectedBloodtype
//        userChronicDisease = chronicDisease.text
//        userDisability = disability.text
//        userAllergy = allergy.text
//        userPrescribedMedication = prescribedMedication.text
        
        //3- create user medical report info
        let medical_info: [String: Any] = [
            "user_id": usrID!,
            "blood_type": userBloodType!,
            "chronic_disease": userChronicDisease!,
            "disabilities": userDisability!,
            "allergies": userAllergy!,
            "prescribed_medication": userPrescribedMedication!,
        ]
        
        //4- push info to database
        self.ref.child("medical_info").childByAutoId().setValue(medical_info)
        
        //5- alert of success
        let alert = UIAlertController(title: "Medical Report is Updated!", message: "you can delete it anytime from your medical report page", preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (_) -> Void in
            self.goToHomeScreen()
        }
        alert.addAction(acceptAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // no need since there are no validation on the blood type
    @IBAction func bloodTypeDidEnd(_ sender: UIButton) {
        let errors = validateFields()
               if  errors["bloodtype"] != "" {
                   errorBloodType.text = errors["bloodtype"]!
                   errorBloodType.alpha = 1
                   bloodTypeButton.titleLabel?.font =  .systemFont(ofSize: 14)
               }
                else {
                    errorBloodType.alpha = 0
                    bloodTypeButton.titleLabel?.font =  .systemFont(ofSize: 14)
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
    // picker view for blood type
    @IBAction func popUpPicker(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select Blood Type", message: "", preferredStyle: .actionSheet)
       
        alert.popoverPresentationController?.sourceView = bloodTypeButton
        alert.popoverPresentationController?.sourceRect = bloodTypeButton.bounds
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in }))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {
        (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.blood_types)[self.selectedRow]
            let name = selected
            self.selectedBloodtype = name
            self.bloodTypeButton.setTitle(name, for: .normal)
            self.bloodTypeButton.setTitleColor(UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 ), for: .normal)
            self.bloodTypeButton.titleLabel?.font =  .systemFont(ofSize: 14)
        }))
        self.present(alert, animated: true, completion: nil)
    }
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
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
}
