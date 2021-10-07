import UIKit
import FirebaseDatabase

class requestsViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var requestsColletionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
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
        getRequests()
        configureContainerView()
    }
    
    //MARK: - Functions
    
    func getRequests(){
        //set an observer to get the requests
        ref.child("Request").observe(.childAdded) { snapshot in
            let object = snapshot.value as! [String: Any]
            let request = Request(user_id: object["user_id"] as! String, sensor_id: object["sensor_id"] as! String, request_id: object["request_id"] as! String, dateTime: object["time_stamp"] as! String, longitude: object["longitude"] as! String, latitude: object["latitude"] as! String, vib: object["vib"] as! String, rotation: object["rotation"] as! String, status: object["status"] as! String)
            self.requests.append(request)
            self.nearest(longitude: request.getLongitude(), latitude: request.getLatitude(), request: request)
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
        print("view: \(String(describing: centerName))")
        print("view: \(String(describing: self.loggedInCenterEmail))")
        print("view: \(String(describing: self.loggedInCenter))")
    }
    
    func nearest(longitude: String, latitude:String, request: Request){
        let nearest = SRCACenters.getNearest(longitude: Double(longitude)!, latitude: Double(latitude)!)
        if nearest["name"] as! String == loggedInCenter?["name"] as! String{
            myRequests.append(request)
            self.requestsColletionView.reloadData()

        }
    }

    //MARK: - @IBActions

}

//MARK: - Extension
extension requestsViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocation") as! viewLocationViewController
        vc.latitude = Double(myRequests[indexPath.row].getLatitude())!
        vc.longitude = Double(myRequests[indexPath.row].getLongitude())!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension requestsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCell", for: indexPath) as! requestCollectionViewCell
        cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        cell.layer.borderWidth = 2
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 20
        cell.dateTime.text = "\(myRequests[indexPath.row].getDateTime())"
        var state = "Processed"
        if myRequests[indexPath.row].getStatus() == "0" {
            state = "Active"
        }
        cell.status.text = "status: \(state)"
        return cell
    }
    
    
}

extension requestsViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 119)
    }
    
}
