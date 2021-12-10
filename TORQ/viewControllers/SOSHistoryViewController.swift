//
//  SOSHistoryViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 10/12/2021.
//

import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation

class SOSHistoryViewController: UIViewController {


    @IBOutlet weak var BackgroundView: UIStackView!
    @IBOutlet weak var noSos: UILabel!
    @IBOutlet weak var BackgroundView1: UIView!
    @IBOutlet weak var collectionViewSOS: UICollectionView!
    
    var requests: [SOSRequest] = []

    var ref = Database.database().reference()
    var userID: String?
    override func viewDidLoad() {
        super.viewDidLoad()
       background()
        getRequests()
        print(requests)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func background() {
        /// other reame
        BackgroundView1.layer.cornerRadius = 50
        BackgroundView1.layer.masksToBounds = true
        BackgroundView1.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = BackgroundView1.frame
        gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.96, b: 0.95, c: -0.95, d: -1.56, tx: 1.43, ty: 0.83))
        gradientLayer.bounds = BackgroundView1.bounds.insetBy(dx: -0.5*BackgroundView1.bounds.size.width, dy: -0.5*BackgroundView1.bounds.size.height)
        gradientLayer.position = BackgroundView1.center
        BackgroundView1.layer.addSublayer(gradientLayer)
        BackgroundView1.layer.insertSublayer(gradientLayer, at: 0)
       
         collectionViewSOS.layer.cornerRadius = 15
    }
    
    //fetch data from firebase and reload the collection
    func getRequests(){
      
       
        ref.child("SOSRequests").observe(.value) { snapshot in
            for contact in snapshot.children{
              // print("enter")
                let obj = contact as! DataSnapshot
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                let time_stamp = obj.childSnapshot(forPath: "time_date").value as! String
                let lonitude = obj.childSnapshot(forPath: "longitude").value as! String
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let center = obj.childSnapshot(forPath: "assigned_center").value as! String
                let sent = obj.childSnapshot(forPath: "sent").value as! String
                let status = obj.childSnapshot(forPath: "status").value as! String
              
                
               
             
                let request = SOSRequest(user_id: user_id, status: status, assignedCenter: center, sent: sent, longitude: lonitude, latitude: latitude, timeDate:time_stamp)
             

              
                print(self.userID!)
                //cheak
                if(self.userID! == request.user_id ) && (request.getStatus() != "1") {
                    print("should add")

                    self.requests.append(request)
                    print(self.requests)
                   self.collectionViewSOS.reloadData()
                    
                }
            }}
     
    }
      
  
    
    @objc func goToLocation (sender:CustomTapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
        vc.latitude = sender.lat
        vc.longitude = sender.long
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }


    

    
    // create a custom class for UITapGestureRecognizer
    class CustomTapGestureRecognizer: UITapGestureRecognizer {
        var long: Double?
        var lat: Double?
    }
    
}
 


//MARK: - Extension
extension SOSHistoryViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "requestReportViewController") as! requestReportViewController
//
//        vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)}
    }
    
}
//MARK: - extinsions
    extension SOSHistoryViewController: UICollectionViewDataSource{
        
        // tell the collection view how many cells to make
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if ( requests.count == 0 ) {
                noSos.alpha = 1
            } else{
                noSos.alpha = 0
            }
            return requests.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SOSCell", for: indexPath as IndexPath) as! HistorySOSCollectionViewCell
            //cell.shadowDecorate1()
        //    cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            cell.map.layer.cornerRadius = 10
            cell.Requestnum.text = "Request #\(indexPath.row + 1)"
            
            //Assigned center
            let center = requests[indexPath.row].getAssignedCenter().trimmingCharacters(in: .whitespacesAndNewlines)
            if(center == "kingfahad"){
                cell.CenterName.text = "King fahad"
            }else  if(center == "kingfaisal"){
                cell.CenterName.text = "King faisal"

            }
            else{
            cell.CenterName.text = center.firstUppercased0
            }
           
            // Location
            let lat = Double(requests[indexPath.row].getLatitude())!
            let long = Double(requests[indexPath.row].getLongitude())!

            let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long)))

            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = "Request"
            let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 12000, longitudinalMeters: 12000)
            cell.map.setRegion(coordinateRegion, animated: true)
            cell.map.addAnnotation(annotation)

         
            
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(goToLocation(sender:)))
            tap.lat = lat
            tap.long = long
            cell.map.addGestureRecognizer(tap)
            
            //  Status
                if ( requests[indexPath.row].getStatus() == "Cancelled" ) {
                    cell.status.text = "Cancelled"
                    cell.status.textColor = UIColor(red: 0.784, green: 0.267, blue: 0.337, alpha: 1)
                }
                else {
                    cell.status.text = "Processed"

                    cell.status.textColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1)
                }
            // date and time
            var date: String
            var time: String
            date = requests[indexPath.row].getTimeDate()

            time = requests[indexPath.row].getTimeDate()
          var datein = String(date.prefix(11))
            let  timein = String(time.suffix(8))
            print(timein)
            datein = datein.trimmingCharacters(in: .whitespacesAndNewlines)

            cell.Date.text = "\(datein)"

            return cell
            
        }
}


extension SOSHistoryViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 356, height: 120)
    }
    
}

//the map set the vector
//MARK: - Map View Delegate Extension
extension SOSHistoryViewController: MKMapViewDelegate{
    
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
// change the fisrt letter of center to capital
extension StringProtocol {
    var firstUppercased0: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized0: String { return prefix(1).capitalized + dropFirst() }
}
//for shadow
extension UICollectionViewCell {
    func shadowDecorate1() {
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
