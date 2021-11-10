//
//  AccidentHistoryViewController.swift
//  TORQ
//
//  Created by Norua Alsalem on 04/11/2021.
//

import UIKit
import Firebase

class AccidentHistoryViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var accidents: UICollectionView!
    
    
    //MARK: - Variables
    var userID: String?
    var ref = Database.database().reference()
    var accidentsArray : [Request] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAccidents(userID: userID!)
    }
    
    //MARK: - Functions
    func fetchAccidents(userID: String){
        
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        
        searchQueue.sync {
            
            ref.child("Request").observe(.childAdded) { snapshot in
                
                let obj = snapshot.value as! [String: Any]
                let user_id = obj["user_id"] as! String
                let sensor_id = obj["sensor_id"] as! String
                let request_id = obj["request_id"] as! String
                let time_stamp = obj["time_stamp"] as! String
                let rotation = obj["rotation"] as! String
                let status = obj["status"] as! String
                let vib = obj["vib"] as! String
                let longitude = obj["longitude"] as! String
                let latitude = obj["latitude"] as! String
                
                let request = Request(user_id:user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude:latitude , vib: vib, rotation:rotation , status: status )
                
                if ( userID == request.getUserID() && ( request.getStatus() == "1" ||  request.getStatus() == "2" )  ) {
                    self.accidentsArray.append(request)
                    self.accidents.reloadData()
                }
                
    }
}
}
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
    
//MARK: - extinsions

    extension AccidentHistoryViewController: UICollectionViewDataSource{
        
        // tell the collection view how many cells to make
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return accidentsArray.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            // get a reference to our storyboard cell
            if ( accidentsArray.count == 0 ) {
                //noAdded.alpha = 1
            } else{
                //noAdded.alpha = 0
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! AccidentsCollectionViewCell
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            cell.layer.shadowColor  = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowRadius = 90
            cell.layer.shadowOffset = CGSize(width: 9, height: 9)
            cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            cell.map.layer.cornerRadius = 10
            cell.accidentLabel.text = "Accident #\(indexPath.row + 1)"
            cell.vibrationLabel.text = "Vibration detected: "
            cell.vibration.text = "\(accidentsArray[indexPath.row].getVib())"
            cell.inclinationLabel.text = "Inclination detected: "
            cell.inclination.text = "\(accidentsArray[indexPath.row].getRotation())"
                if ( accidentsArray[indexPath.row].getStatus() == "1" ) {
                    cell.status.text = "Processed"
                }
                else {
                    cell.status.text = "Canceled"
                    cell.status.textColor = UIColor(red: 0.784, green: 0.267, blue: 0.337, alpha: 1)
                }
            var date: String
            var alteredDate: String
            date = accidentsArray[indexPath.row].getDateTime()
            let year = String((date.prefix(4)))
            let monthStart = date.index(date.startIndex, offsetBy: 5)
            let monthEnd = date.index(date.startIndex, offsetBy: 6)
            let range = monthStart...monthEnd
            let month = String(date[range])
            let dayStart = date.index(date.startIndex, offsetBy: 8)
            let dayEnd = date.index(date.startIndex, offsetBy: 9)
            let range2 = dayStart...dayEnd
            let day = String(date[range2])
            alteredDate = "\(year)-\(month)-\(day)"
            cell.date.text = alteredDate
            
            return cell
            
        }
    }

    extension AccidentHistoryViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 374, height: 160)
    }
}

extension AccidentHistoryViewController: UICollectionViewDelegate{
    
    
}





 
