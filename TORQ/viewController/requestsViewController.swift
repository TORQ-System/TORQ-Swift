import UIKit
import FirebaseDatabase

class requestsViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var requestsColletionView: UICollectionView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var requests: [Request] = []
    
    //MARK: - Overriden function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRequests()
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
    
}

extension requestsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "requestCell", for: indexPath) as! requestCollectionViewCell
        cell.backgroundColor = .darkGray
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 20
        cell.dateTime.text = "\(requests[indexPath.row].getDate())   \(requests[indexPath.row].getTime())"
        cell.status.text = "\(requests[indexPath.row].getStatus())"
        return cell
    }
    
    
}

extension requestsViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 414, height: 185)
    }
    
}

