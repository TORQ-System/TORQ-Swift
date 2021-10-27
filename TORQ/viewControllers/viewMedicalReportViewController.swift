import UIKit

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
    
    
    //MARK: - Variables
    var userID: String?
    
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
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
    }
    
    private func retrieveMedicalReport(){
        
        
        
    }
    
    
    //MARK: - @IBActions
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
        // Shahad's code goes here
    }
    
}

//MARK: - Extensions
