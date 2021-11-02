import UIKit
import FirebaseDatabase

class requestReportViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var data_timeRE: UILabel!
    @IBOutlet weak var name_report: UILabel!
    @IBOutlet weak var DOB: UILabel!
    @IBOutlet weak var location_report: UIButton!
    @IBOutlet weak var namerequest: UILabel!
    @IBOutlet weak var blood: UILabel!
    @IBOutlet weak var disease: UILabel!
    @IBOutlet weak var medation: UILabel!
    @IBOutlet weak var algeer: UILabel!
    @IBOutlet weak var medation0: UILabel!
    @IBOutlet weak var algeer0: UILabel!
    @IBOutlet weak var prosseing0: UIButton!
    @IBOutlet weak var scroolview: UIScrollView!
    @IBOutlet weak var Gender: UILabel!
    
    //MARK: - Variables
    var userMedicalReportID : String!
    var long : Double!
    var lang : Double!
    var time : String!
    var ref = Database.database().reference()
    
    // MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        contetnt()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref.child("Request").queryOrdered(byChild:"user_id").observe(.childAdded, with: {(snapshot) in
            if let dec = snapshot.value as? [String :Any]{
                if (dec["user_id"] as! String == self.userMedicalReportID! && dec["status"]as! String == "1"){self.prosseing0.alpha = 0
                    
                }
            }
        })
            
        
                                                                     
                                                                     }
    
    
    //MARK: - Functions
    func configureView(){
        scroolview.layer.cornerRadius = 20
        scroolview.layer.shadowColor = UIColor.black.cgColor
        scroolview.layer.shadowOpacity = 1
        scroolview.layer.shadowOffset = CGSize(width: 0, height: 5)
        scroolview.layer.shadowRadius = 10
        scroolview.layer.shouldRasterize = true
        prosseing0.layer.cornerRadius = 15
        prosseing0.layer.masksToBounds = true
        location_report.backgroundColor = .white
        location_report.layer.cornerRadius = 25
    }
    
    func contetnt(){
        //location
        location_report.addTarget(self, action: #selector(findloc(sender: )), for: .touchUpInside)
        // time format
//        let find = time.firstIndex(of: "+") ?? time.endIndex
//        let find2 = time[..<find]
//        let start = find2.index(find2.startIndex, offsetBy: 0)
//        let end = find2.index(find2.startIndex, offsetBy: 10)
//        let range = start...end
//
//        let newString = String(find2[range])
//        let start1 = find2.index(find2.startIndex, offsetBy: 10)
//        let end1 = find2.index(find2.startIndex, offsetBy:18)
//        let range1 = start1...end1
//        let newString1 = String(find2[range1])
        data_timeRE.text = time
        ///
        //        ref.child("User").child(UID!).observe(.value, with: {(snapshot) in
        //                   if let dec = snapshot.value as? [String :Any]
        //                   {
        //                    let Fname = dec["firstName"] as! String
        //                       let lname = dec["lastName"] as! String
        //                       print("hi\(Fname)")
        //                       self.name_report.text = Fname+" "+lname
        //                       self.namerequest.text = "\(Fname)'s Request"
        //
        //                   }
        //
        //               })
        
        
        ref.child("User").child(userMedicalReportID!).observe(.value, with: {(snapshot) in
            if let dec = snapshot.value as? [String :Any]
            {
                let fullName = dec["fullName"] as! String
                let Gender1 = dec["gender"] as! String
                let NID = dec["nationalID"] as! String


             //   let firstName = fullName.components(separatedBy: " ").first
                self.namerequest.text = "\(fullName)"
                self.name_report.text = "\(NID)"
                self.Gender.text = "\(Gender1)"

            }
            
        })
        
        ref.child("MedicalReport").queryOrdered(byChild:"user_id").observe(.childAdded, with: {(snapshot) in
            var try1 = "Not set"
            var try2 = "Not set"
            var  try3 = "Not set"
            var try4 = "Not set"
            
            
            if let dec = snapshot.value as? [String :Any]
            {
                if (dec["user_id"] as! String == self.userMedicalReportID!){
                    if dec["blood_type"] as! String != "-"{
                       try1 = dec["blood_type"] as! String}
                    
                    if dec["allergies"] as! String != "-"{
                        try2 = dec["allergies"] as! String }
                    
                    
                    if dec["chronic_disease"] as! String != "-"{
                        try3 = dec["chronic_disease"] as! String }
                    
                    if dec["prescribed_medication"] as! String != "-"{
                        try4 = dec["prescribed_medication"] as! String}
                    
                    
                    
                    //  let lname = dec["lastName"] as! String
                    self.blood.text = try1
                    self.disease.text = try3
                    self.algeer0.text = try2
                    self.medation0.text = try4
                    print("2-\(try1)")
                    print("1-\(try2)")
                    print("1-\(try3)")
                    print("1-\(try4)")
                }
                //  self.name_report.text = Fname+" "+lname
                //   self.namerequest.text = "\(Fname)'s Request"
                //o
            }
            
        })
    }

    @objc
    func findloc(sender:UIButton){
        print("try")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
        vc.latitude = lang
        vc.longitude = long
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - @IBAction
    @IBAction func back_butten(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func prosessing(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "hospitalsViewController") as! hospitalsViewController
        vc.userMedicalReportID = String(userMedicalReportID)
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
