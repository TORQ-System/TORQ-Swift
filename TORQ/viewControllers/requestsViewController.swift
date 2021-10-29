import UIKit
import FirebaseDatabase
import SwiftUI

class requestsViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var requestsColletionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var assignedRequests: UILabel!
    @IBOutlet weak var namecenter: UILabel!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var requests: [Request] = []
    var loggedInCenterEmail: String!
    var loggedInCenter: [String: Any]?
    var myRequests: [Request] = []
    let refrechcon = UIRefreshControl()
    
    //MARK: - Overriden function
    override func viewWillAppear(_ animated: Bool) {
        getRequests()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI setup
        configureContainerView()
        configureCenter()
        
        getRequests()
    }
    
    
    //MARK: - Functions
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
    
    func getRequests(){
        requests.removeAll()
        myRequests.removeAll()
        
        ref.child("Request").queryOrdered(byChild: "time_stamp").observe(.value) { snapshot in
            for contact in snapshot.children{
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
                
                if ( request.getStatus() == "0" ) {
                    self.requests.append(request)
                    self.nearest(longitude: request.getLongitude(), latitude: request.getLatitude(), request: request)
                }}}
        
        requestsColletionView.reloadData()
    }
    
    
    func nearest(longitude: String, latitude:String, request: Request){
        
        let nearest = SRCACenters.getNearest(longitude: Double(longitude)!, latitude: Double(latitude)!)
        if nearest["name"] as! String == loggedInCenter!["name"] as! String{
            var i = 0
            for item in myRequests {
                if item.request_id == request.request_id {
                    myRequests.remove(at:i )
                }
                i = i+1
            }
            myRequests.append(request)
            self.requestsColletionView.reloadData()
        }
    }
    
    func locf(lon:String,lang:String) -> String{
        return lon
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
    @IBAction func backbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extension
extension requestsViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        //        let vc = storyboard.instantiateViewController(identifier: "viewLocation") as! viewLocationViewController
        //    vc.latitude = Double(myRequests[indexPath.row].getLatitude())!
        //        vc.longitude = Double(myRequests[indexPath.row].getLongitude())!
        //        vc.modalPresentationStyle = .fullScreen
        //        self.present(vc, animated: true, completion: nil)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "requestReportViewController") as! requestReportViewController
        vc.lang = Double(myRequests[indexPath.row].getLatitude())!
        vc.long = Double(myRequests[indexPath.row].getLongitude())!
        vc.time = myRequests[indexPath.row].getDateTime()
        vc.userMedicalReportID = String(myRequests[indexPath.row].getUserID())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension requestsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if myRequests.count == 0 {
            assignedRequests.alpha = 1
        }else{
            assignedRequests.alpha = 0
        }
        return myRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCell", for: indexPath) as! requestCollectionViewCell
        
        cell.shadowDecorate()
        
//                cell.layer.cornerRadius = 20
//                cell.layer.borderWidth = 1.0
//                cell.layer.borderColor = UIColor.red.cgColor
//                cell.layer.masksToBounds = true
        //        cell.layer.shadowColor = UIColor.gray.cgColor
        //        //cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        //        cell.layer.shadowRadius = 4
        //        cell.layer.shadowOpacity = 0.9
        //        cell.layer.cornerRadius = 15.0
        //               cell.layer.masksToBounds = true
        //               cell.layer.borderWidth = 0.0
        //
        //               cell.backgroundView?.layer.shadowColor = UIColor.black.cgColor
        //               cell.backgroundView?.layer.shadowRadius = 5
        //               cell.backgroundView?.layer.shadowOpacity = 1
        //               cell.backgroundView?.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        //
        
        //        layer.shadowColor = UIColor.lightGray.cgColor
        //        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        //        layer.shadowRadius = 6.0
        //        layer.shadowOpacity = 1.0
        //        layer.masksToBounds = false
        //        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        //        layer.backgroundColor = UIColor.clear.cgColor
        
        
        
        cell.name.text = "Accident #\(indexPath.row)"
        
        let date1 = "\(myRequests[indexPath.row].getDateTime())"
        let find = date1.firstIndex(of: "+") ?? date1.endIndex
        let find2 = date1[..<find]
        let start = find2.index(find2.startIndex, offsetBy: 0)
        let end = find2.index(find2.startIndex, offsetBy: 10)
        let range = start...end
        
        let date = String(find2[range])
        let start1 = find2.index(find2.startIndex, offsetBy: 10)
        let end1 = find2.index(find2.startIndex, offsetBy:18)
        let range1 = start1...end1
        
        let timeStamp = String(find2[range1])
        
        cell.dateTime.text = "\(date), \(timeStamp) "
        
        cell.viewbutten.tag = indexPath.row
        cell.viewbutten.addTarget(self, action: #selector(viewbutten(sender: )), for: .touchUpInside)
        
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
