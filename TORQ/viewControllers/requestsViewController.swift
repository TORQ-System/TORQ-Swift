import UIKit
import FirebaseDatabase

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
    //MARK: - Overriden function
    
    override func viewWillAppear(_ animated: Bool) {
        configureCenter()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCenter()
        getRequests()
        configureContainerView()
    }
    
    //MARK: - Functions
    
//    func getRequests(){
//        //set an observer to get the requests
//        ref.child("Request").queryOrdered(byChild: "time_stamp").observe(.childAdded) { snapshot in
//            let object = snapshot.value as! [String: Any]
//            let request = Request(user_id: object["user_id"] as! String, sensor_id: object["sensor_id"] as! String, request_id: object["request_id"] as! String, dateTime: object["time_stamp"] as! String, longitude: object["longitude"] as! String, latitude: object["latitude"] as! String, vib: object["vib"] as! String, rotation: object["rotation"] as! String, status: object["status"] as! String)
//            self.requests.append(request)
//            self.nearest(longitude: request.getLongitude(), latitude: request.getLatitude(), request: request)
//        }
//    }
      func getRequests(){
            //set an observer to get the requests
            ref.child("Request").queryOrdered(byChild: "time_stamp").observe(.childAdded) { snapshot in
                let object = snapshot.value as! [String: Any]
                if object["status"] as! String == "0"{
                let request = Request(user_id: object["user_id"] as! String, sensor_id: object["sensor_id"] as! String, request_id: object["request_id"] as! String, dateTime: object["time_stamp"] as! String, longitude: object["longitude"] as! String, latitude: object["latitude"] as! String, vib: object["vib"] as! String, rotation: object["rotation"] as! String, status: object["status"] as! String)
                self.requests.append(request)
                    self.nearest(longitude: request.getLongitude(), latitude: request.getLatitude(), request: request)}
            }
        }
    
    func configureContainerView(){
        containerView.layer.cornerRadius = 70
        containerView.layer.maskedCorners = [.layerMinXMinYCorner]
    }

    
    func configureCenter(){
        let domainRange = loggedInCenterEmail.range(of: "@")!
        let centerName = loggedInCenterEmail[..<domainRange.lowerBound]
        loggedInCenter = SRCACenters.getSRCAInfo(name: String(centerName))
        namecenter.text="\(centerName) Requests"
//        print("view: \(String(describing: centerName))")
//        print("view: \(String(describing: self.loggedInCenterEmail))")
//        print("view: \(String(describing: self.loggedInCenter))")
    }
    
    func nearest(longitude: String, latitude:String, request: Request){
        let nearest = SRCACenters.getNearest(longitude: Double(longitude)!, latitude: Double(latitude)!)
//        print("vieww: \(loggedInCenter!["name"] as! String)")
        if nearest["name"] as! String == loggedInCenter!["name"] as! String{
        
            myRequests.append(request)
            self.requestsColletionView.reloadData()

        }
    }
    func locf(lon:String,lang:String) -> String{
        return lon
   
        
    }
    @objc
    func findloc(sender:UIButton){
        
        print("try")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
               let vc = storyboard.instantiateViewController(identifier: "viewLocation") as! viewLocationViewController
        vc.latitude = Double(myRequests[sender.tag].getLatitude())!
        vc.longitude = Double(myRequests[sender.tag].getLongitude())!
               vc.modalPresentationStyle = .fullScreen
               self.present(vc, animated: true, completion: nil)
    }
    @objc
    func viewbutten(sender:UIButton){
        
        print("view")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
               let vc = storyboard.instantiateViewController(identifier: "ViewRequest_Report") as! ViewRequest_Report
        vc.lang = Double(myRequests[sender.tag].getLatitude())!
        vc.long = Double(myRequests[sender.tag].getLongitude())!
        vc.time = myRequests[sender.tag].getDateTime()
        vc.UID=String(myRequests[sender.tag].getUserID())
        
//        ref.child("User/\(myRequests[sender.tag].getUserID())/firstName").observeSingleEvent(of: .value, with: { snapshot in  guard let value1 = snapshot.value as? String else {return}
//            print(value1)
//            vc.UID = "hi\(value1)"
//
//                })
//        ref.child("User").child((myRequests[sender.tag].getUserID())).observe(.value, with: {(snapshot) in
//            if let dec = snapshot.value as? [String :Any]
//            {
//             let Fname = dec["firstName"] as! String
//                print("hi\(Fname)")
//                vc.UID = "hi\(Fname)"
//                print("hiii\(vc.UID)")
//
//            }
//
//        })
      
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
//        vc.latitude = Double(myRequests[indexPath.row].getLatitude())!
//        vc.longitude = Double(myRequests[indexPath.row].getLongitude())!
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
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
        cell.layer.borderColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        cell.layer.borderWidth = 2
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 20
        cell.name.text = "Accident #\(indexPath.row)"
       // cell.dateTime.text = "\(myRequests[indexPath.row].getDateTime())"
        //  cell.dateTime.text =
          let date1 = "\(myRequests[indexPath.row].getDateTime())"
          let find = date1.firstIndex(of: "+") ?? date1.endIndex
          let find2 = date1[..<find]
          let start = find2.index(find2.startIndex, offsetBy: 0)
          let end = find2.index(find2.startIndex, offsetBy: 10)
          let range = start...end

          let newString = String(find2[range])
          let start1 = find2.index(find2.startIndex, offsetBy: 10)
          let end1 = find2.index(find2.startIndex, offsetBy:18)
          let range1 = start1...end1

          let newString1 = String(find2[range1])
          cell.dateTime.text = "\(newString), \(newString1) "
          var state = " "
          if myRequests[indexPath.row].getStatus() == "0" {
              state = ""
          }
          cell.status.text = state
        cell.location.tag=indexPath.row
        
        cell.location.addTarget(self, action: #selector(findloc(sender: )), for: .touchUpInside)
        cell.viewbutten.tag=indexPath.row
        cell.viewbutten.addTarget(self, action: #selector(viewbutten(sender: )), for: .touchUpInside)
        return cell
    }
    
    
}

extension requestsViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 119)
    }
    
}

