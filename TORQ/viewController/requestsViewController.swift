import UIKit
import FirebaseDatabase

class requestsViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var requestsColletionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var requests: [Request] = []
    
    //MARK: - Overriden function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequests()
        containerView.layer.cornerRadius = 70
        containerView.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    //MARK: - Functions
    
    func getRequests(){
        //set an observer to get the requests
        ref.child("Request").observe(.childAdded) { snapshot in
            let object = snapshot.value as! [String: Any]
            let request = Request(user_id: object["user_id"] as! Int, sensor_id: object["sensor_id"] as! Int, request_id: object["request_id"] as! Int, date: object["date"] as! String, time: object["time"] as! String, longitude: object["longitude"] as! Double, latitude: object["latitude"] as! Double, vib: object["vib"] as! Int, rotation: object["rotation"] as! Int, status: object["status"] as! Int)
            self.requests.append(request)
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
        vc.latitude = requests[indexPath.row].getLatitude()
        vc.longitude = requests[indexPath.row].getLongitude()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension requestsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCell", for: indexPath) as! requestCollectionViewCell
        cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        cell.layer.borderWidth = 2
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 20
        cell.dateTime.text = "\(requests[indexPath.row].getDate())   \(requests[indexPath.row].getTime())"
        var state = "Processed"
        if requests[indexPath.row].getStatus() == 0 {
            state = "Active"
        }
        cell.status.text = "status: \(state)"
        return cell
    }
    
    
}

extension requestsViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 185)
    }
    
}

