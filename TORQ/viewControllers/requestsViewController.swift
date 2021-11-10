import UIKit
import FirebaseDatabase
import SwiftUI
import FirebaseAuth


class requestsViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var requestsColletionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var assignedRequests: UILabel!
    @IBOutlet weak var namecenter: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var noprossing: UILabel!
    @IBOutlet weak var segmentcontrol: UISegmentedControl!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var requests: [Request] = []
    var loggedInCenterEmail: String!
    var loggedInCenter: [String: Any]?
    var myRequests: [Request] = []
    let refrechcon = UIRefreshControl()
    var prossed : [Request] = []
    var switches = 0
    //MARK: - Overriden function
    override func viewWillAppear(_ animated: Bool) {
        getRequests()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI setup
//        setGradientBackground()
       // setGradient()
        
        configureContainerView()
        configureCenter()
        configureSegmentControl()
        getRequests()
    }
    
    
    //MARK: - Functions
    func setGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        let blue =  UIColor(red: 26.0/255.0, green: 40.0/255.0, blue: 88.0/255.0, alpha: 1.0).cgColor
        let lightblue =  UIColor(red: 49.0/255.0, green: 90.0/255.0, blue: 149.0/255.0, alpha: 1.0).cgColor
        gradient.colors = [blue, lightblue]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = backgroundView.layer.frame
        backgroundView.layer.insertSublayer(gradient, at: 0)
        backgroundView.layer.cornerRadius = 20
    }
    
    func configureSegmentControl(){
           segmentcontrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControl.State.normal)
        segmentcontrol.layer.cornerRadius = 45.0
        //segmentcontrol.layer.borderColor = UIColor.white.cgColor
        segmentcontrol.layer.borderWidth = 1.0
        segmentcontrol.layer.masksToBounds = true
        segmentcontrol.layer.cornerRadius = segmentcontrol.bounds.height / 2
      //  segmentcontrol.layer.borderColor = UIColor.blueColor().CGColor
        segmentcontrol.layer.borderWidth = 1
    }
   
    
    func configureContainerView(){
        assignedRequests.alpha = 0
        containerView.layer.cornerRadius = 20
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        containerView.layer.shadowRadius = 25
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func configureCenter(){
        let domainRange = loggedInCenterEmail.range(of: "@")!
        let centerName = loggedInCenterEmail[..<domainRange.lowerBound]
        loggedInCenter = SRCACenters.getSRCAInfo(name: String(centerName))
        namecenter.text="\(centerName.firstUppercased)'s Requests"
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func getRequests(){
        requests.removeAll()
        myRequests.removeAll()
       prossed.removeAll()
        
        ref.child("Request").queryOrdered(byChild: "time_stamp").observe(.value) { snapshot in
            for contact in snapshot.children{
                print("enter")

                let obj = contact as! DataSnapshot
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                let sensor_id = obj.childSnapshot(forPath: "sensor_id").value as! String
                let request_id = obj.childSnapshot(forPath: "request_id").value as! String
                let time_stamp = obj.childSnapshot(forPath: "time_stamp").value as! String
                let lonitude = obj.childSnapshot(forPath: "longitude").value as! String
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let vib = obj.childSnapshot(forPath: "vib").value as! String
                let rotation = obj.childSnapshot(forPath: "rotation").value as! String
                let status = obj.childSnapshot(forPath: "status").value as! String
                
                let request = Request(user_id:user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: lonitude, latitude:latitude , vib: vib, rotation:rotation , status: status )
                print(request)

                //get active requests only
              //  if ( request.getStatus() == "0" ) {
                    self.requests.append(request)
                print("try to add\(self.requests)")
                    self.nearest(longitude: request.getLongitude(), latitude: request.getLatitude(), request: request)
                //}
                
            }}
        print(requests)

        print(myRequests)
        print(prossed)
        requestsColletionView.reloadData()
    }
    
    
    func nearest(longitude: String, latitude:String, request: Request){
        
        let nearest = SRCACenters.getNearest(longitude: Double(longitude)!, latitude: Double(latitude)!)
        print(nearest)
        if nearest["name"] as! String == loggedInCenter!["name"] as! String{
            var i = 0
            var t = 0
            for item in myRequests {
                if item.request_id == request.request_id {
                    myRequests.remove(at:i )
                }
                i = i+1
            }
            for item in prossed {
                if item.request_id == request.request_id {
                    prossed.remove(at:t )
                }
                t = t+1
            }
            if request.status == "0"{
                myRequests.append(request)
                print(request)

            }
            else if request.status == "1"{
                prossed.append(request)
                print(request)

            }
            self.requestsColletionView.reloadData()
          


        }
    }
    
    func locf(lon:String,lang:String) -> String{
        return lon
    }
    
    func goToLoginScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! loginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - objc Functions
    @objc func getdata(){
        refrechcon.endRefreshing()
        getRequests()
        requestsColletionView.reloadData()
    }
    
    @objc
    func findloc(sender:UIButton){
        print("try")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
        vc.latitude = Double(myRequests[sender.tag].getLatitude())!
        vc.longitude = Double(myRequests[sender.tag].getLongitude())!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc
    func viewbutten(sender:UIButton){
        print("view")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "requestReportViewController") as! requestReportViewController
        vc.lang = Double(myRequests[sender.tag].getLatitude())!
        vc.long = Double(myRequests[sender.tag].getLongitude())!
        vc.time = myRequests[sender.tag].getDateTime()
        vc.userMedicalReportID = String(myRequests[sender.tag].getUserID())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    //MARK: - @IBActions
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let userDefault = UserDefaults.standard
            userDefault.setValue(false, forKey: "isUserSignedIn")
            goToLoginScreen()
        } catch let error {
            print (error.localizedDescription)
        }
    }
    @IBAction func segment(_ sender: Any) {
        requestsColletionView.reloadData()
    }
}

//MARK: - Extension
extension requestsViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "requestReportViewController") as! requestReportViewController
        if switches==1{
        vc.lang = Double(myRequests[indexPath.row].getLatitude())!
        vc.long = Double(myRequests[indexPath.row].getLongitude())!
        vc.time = myRequests[indexPath.row].getDateTime()
        vc.userMedicalReportID = String(myRequests[indexPath.row].getUserID())
            vc.Requestid = String(myRequests[indexPath.row].getRequestID())
            vc.statusid = String(myRequests[indexPath.row].getStatus())
        vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)}
        if switches==2{
        vc.lang = Double(prossed[indexPath.row].getLatitude())!
        vc.long = Double(prossed[indexPath.row].getLongitude())!
        vc.time = prossed[indexPath.row].getDateTime()
        vc.userMedicalReportID = String(prossed[indexPath.row].getUserID())
            vc.statusid = String(prossed[indexPath.row].getStatus())
        vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)}
    }
    
}

extension requestsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        switch segmentcontrol.selectedSegmentIndex{
        case 0:
            noprossing.alpha = 0

            if myRequests.count == 0 {
                assignedRequests.alpha = 1
            }else{
                assignedRequests.alpha = 0
            }
            return myRequests.count
        case 1:
            assignedRequests.alpha = 0

            if prossed.count == 0 {
                noprossing.alpha = 1
            }else{
                noprossing.alpha = 0
            }
            return prossed.count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCell", for: indexPath) as! requestCollectionViewCell
        
        cell.shadowDecorate()
        
        switch segmentcontrol.selectedSegmentIndex{
        case 0:
            switches = 1
            print(switches)
            cell.name.text = "Accident #\(indexPath.row)"

            cell.dateTime.text = myRequests[indexPath.row].getDateTime()
            
            cell.viewbutten.tag = indexPath.row
            cell.viewbutten.addTarget(self, action: #selector(viewbutten(sender: )), for: .touchUpInside)
            
        case 1:
            switches = 2
            print(switches)
            cell.name.text = "Accident #\(indexPath.row)"

            cell.dateTime.text = prossed[indexPath.row].getDateTime()
            
            cell.viewbutten.tag = indexPath.row
            cell.viewbutten.addTarget(self, action: #selector(viewbutten(sender: )), for: .touchUpInside)
        default:
            break
        }


        return cell
    }
}


extension requestsViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/1.1, height: 60)
    }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}

extension UICollectionViewCell {
    func shadowDecorate() {
        let radius: CGFloat = 20
        contentView.layer.cornerRadius = radius
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}

