import UIKit
import Firebase
import SCLAlertView

class viewMedicalReportViewController: UIViewController {
    
    
    //MARK: - @IBOutlts
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var addMedicalReport: UIButton!
    @IBOutlet weak var deleteMedicalReport: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    @IBOutlet weak var bloodType: UILabel!
    @IBOutlet weak var disabilities: UILabel!
    @IBOutlet weak var medication: UILabel!
    @IBOutlet weak var diseases: UILabel!
    @IBOutlet weak var allergies: UILabel!
    @IBOutlet weak var notAvailable: UILabel!
    @IBOutlet weak var medicalStackView: UIStackView!
    @IBOutlet weak var flipbutton: UIButton!
    
    
    //MARK: - Variables
    var userID: String?
    var ref = Database.database().reference()
    var medicalReport: MedicalReport?
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(contentViewCornerRadius: 15,buttonCornerRadius: 7,hideWhenBackgroundViewIsTapped: true)
    var front = true
    

    
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        retrieveMedicalReport()
    }
    
    
    //MARK: - Functions
    private func configureLayout(){
        // 1- profile View corner radius
        profileView.layer.cornerRadius = 40
        profileView.layer.masksToBounds = true
        // 2- card View corner radius
        cardView.layer.cornerRadius = 30
        cardView.layer.masksToBounds = true
        // 3- scroll View corner radius
        scrollView.layer.cornerRadius = 30
        scrollView.layer.masksToBounds = true
        // 4- scroll View container corner radius
        scrollViewContainer.layer.cornerRadius = 30
        scrollViewContainer.layer.masksToBounds = true
        // 5- buttons View corner radius
        addMedicalReport.layer.cornerRadius = 35
        addMedicalReport.layer.masksToBounds = true
        deleteMedicalReport.layer.cornerRadius = 35
        deleteMedicalReport.layer.masksToBounds = true
        // 6- hide the not availbale MR lable
        notAvailable.alpha = 0
    }
    
    private func retrieveMedicalReport(){
        ref.child("MedicalReport").observe(.value) { snapshot in
            print(snapshot.value!)
            for report in snapshot.children{
                let obj = report as! DataSnapshot
                let bloodType = obj.childSnapshot(forPath: "blood_type").value as! String
                let allergies = obj.childSnapshot(forPath: "allergies").value as! String
                let chronic_disease = obj.childSnapshot(forPath: "chronic_disease").value as! String
                let disabilities = obj.childSnapshot(forPath: "disabilities").value as! String
                let prescribed_medication = obj.childSnapshot(forPath: "prescribed_medication").value as! String
                let userId = obj.childSnapshot(forPath: "user_id").value as! String
                
                let report = MedicalReport(userID: userId, bloodType: bloodType, allergies: allergies, chronic_disease: chronic_disease, disabilities: disabilities, prescribed_medication: prescribed_medication)
                
                if report.getUserID() == self.userID {
                    self.medicalReport = report
                    self.bloodType.text = "Blood Type: \(report.getBloodType())"
                    self.allergies.text = "Allergies: \(report.getAllergies())"
                    self.diseases.text = "Chronic Disease: \(report.getDiseases())"
                    self.disabilities.text = "Disabilities: \(report.getDisabilities())"
                    self.medication.text = "Prescribed Medication: \(report.getMedications())"
                }
            }
            if self.medicalReport == nil {
                // The user have no Medical Report
                self.medicalStackView.isHidden = true
                self.notAvailable.alpha = 1
            }
            print("printing Report: \(String(describing: self.medicalReport))")
        }
    }
    
    
    //MARK: - @IBActions
    
    @IBAction func flipCard(_ sender: Any) {
        let QR = UIImage(named: "qr-code")
        if self.front {
            UIView.transition(with: cardView, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            self.scrollViewContainer.isHidden = true
            self.flipbutton.setImage(QR, for: .normal)
            front = false
        }else{
            UIView.transition(with: cardView, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
            self.scrollViewContainer.isHidden = false
            self.flipbutton.setImage(nil, for: .normal)
            front = true
        }
    }
    
    
    
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addMedicalReport(_ sender: Any) {
        //        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        //        let addVC = storyboard.instantiateViewController(identifier: "addMedicalReportViewController") as! addMedicalReportViewController
        //        addVC.userID = userID
        //        self.present(addVC, animated: true, completion: nil)
    }
    
    @IBAction func deleteMedicalReport(_ sender: Any) {
        let alertView = SCLAlertView(appearance: self.apperance)
        alertView.addButton("Delete", backgroundColor: self.redUIColor){
            self.ref.child("MedicalReport").queryOrdered(byChild:"user_id").observe(.childAdded, with: {(snapshot) in
                if let dec = snapshot.value as? [String :Any]{
                    if (dec["user_id"] as! String == self.userID!){
                        self.ref.child("MedicalReport").child(snapshot.key).removeValue()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
        alertView.showCustom("Are you sure?", subTitle: "We will delete your entire medical report", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Cancel", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
    }
    
}

//MARK: - Extensions
