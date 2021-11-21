import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation
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
    @IBOutlet weak var backgroundView: UIView!
    
    
    //MARK: - Variables
    var userMedicalReportID : String!
    var long : Double!
    var lang : Double!
    var time : String!
    var Requestid : String!
    var statusid : String!
    var ref = Database.database().reference()
    
    // MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contetnt()
        if (statusid == "1"){
            
           print("try")
                self.prosseing0.alpha = 0
            
        }
        configureView()
        configureGradient()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        print(statusid as Any)
        if (statusid == "1"){
           
                self.prosseing0.alpha = 0
            
        }
        
                                                                     
                                                                     }
    
    
    //MARK: - Functions
    func configureView(){
      scroolview.layer.cornerRadius = 20
//        scroolview.layer.shadowColor = UIColor.black.cgColor
//        scroolview.layer.shadowOpacity = 1
//        scroolview.layer.shadowOffset = CGSize(width: 0, height: 5)
//        scroolview.layer.shadowRadius = 10
//        scroolview.layer.shouldRasterize = true
              prosseing0.layer.cornerRadius = 15
//        prosseing0.layer.masksToBounds = true
        location_report.backgroundColor = .white
        location_report.layer.cornerRadius = 25
    }
    @objc func goToLocation (sender:CustomTapGestureRecognizer) {
           let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
           let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
           vc.latitude = sender.lang
           vc.longitude = sender.long
           vc.modalPresentationStyle = .fullScreen
           self.present(vc, animated: true, completion: nil)
       }

    // create a custom class for UITapGestureRecognizer
    class CustomTapGestureRecognizer: UITapGestureRecognizer {
        var long: Double?
        var lang: Double?
    }
    //MARK: - Functions
      func configureGradient() {
          backgroundView.layer.cornerRadius = 40
                  backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                  backgroundView.layer.shouldRasterize = true
                  backgroundView.layer.rasterizationScale = UIScreen.main.scale
                  
                  let gradient: CAGradientLayer = CAGradientLayer()
                  
                  gradient.colors = [
                      UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
                      UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor
                  ]
                  
                  gradient.locations = [0, 1]
                  gradient.startPoint = CGPoint(x: 0, y: 0)
                  gradient.endPoint = CGPoint(x: 1, y: 1)
                  gradient.frame = backgroundView.layer.frame
                  
                  backgroundView.layer.insertSublayer(gradient, at: 0)
          
      }
    
    func contetnt(){
        //location
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lang), longitude: CLLocationDegrees(long)))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = ""
        // if user taps on map
        
        let tap = CustomTapGestureRecognizer(target: self, action: #selector(goToLocation(sender:)))
        tap.lang = lang
        tap.long = long
        location_report.addTarget(self, action: #selector(findloc(sender: )), for: .touchUpInside)
        
        let domainRange = time!.range(of: " ")!
        let date = time![..<domainRange.lowerBound]
        let newDate = date.replacingOccurrences(of: ":", with: "/", options: .literal, range: nil)
        data_timeRE.text = String(newDate)
    
        
        
        ref.child("User").child(userMedicalReportID!).observe(.value, with: {(snapshot) in
            if let dec = snapshot.value as? [String :Any]
            {
                let fullName = dec["fullName"] as! String
                let Gender1 = dec["gender"] as! String
                let NID = dec["nationalID"] as! String

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
                    
                    self.blood.text = try1
                    self.disease.text = try3
                    self.algeer0.text = try2
                    self.medation0.text = try4
                    print("2-\(try1)")
                    print("1-\(try2)")
                    print("1-\(try3)")
                    print("1-\(try4)")
                }
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
        vc.RequestID = String(Requestid)
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
//MARK: - Map View Delegate Extension
extension requestReportViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation)else{
            return nil
        }
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "accidentPin")
        if pin == nil {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "accidentPin")
            pin?.canShowCallout = true
            pin?.image = UIImage(named: "Vector")
        }else{
            pin?.annotation = annotation
        }
        return pin
    }

    
}
