//
//  AccidentHistoryViewController.swift
//  TORQ
//
//  Created by Norua Alsalem on 04/11/2021.
//

import UIKit
import Firebase
import MapKit

class AccidentHistoryViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var accidents: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var noAccidents: UILabel!
    

    //MARK: - Variables
    var userID: String?
    var ref = Database.database().reference()
    var accidentsArray : [Request] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAccidents(userID: userID!)
        background()
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
    
    
    func background() {
        //background view
         backgroundView.layer.cornerRadius = 50
         backgroundView.layer.masksToBounds = true
         backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
         let gradientLayer = CAGradientLayer()
         gradientLayer.frame = backgroundView.frame
         gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
         gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
         gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
         gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.96, b: 0.95, c: -0.95, d: -1.56, tx: 1.43, ty: 0.83))
         gradientLayer.bounds = backgroundView.bounds.insetBy(dx: -0.5*backgroundView.bounds.size.width, dy: -0.5*backgroundView.bounds.size.height)
         gradientLayer.position = backgroundView.center
         backgroundView.layer.addSublayer(gradientLayer)
         backgroundView.layer.insertSublayer(gradientLayer, at: 0)
         // add corner radius to the clooection view as a whole
         accidents.layer.cornerRadius = 15
    }
    
    @objc func goToLocation (sender:CustomTapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
        vc.latitude = sender.lat
        vc.longitude = sender.long
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }

    }
    // create a custom class for UITapGestureRecognizer
    class CustomTapGestureRecognizer: UITapGestureRecognizer {
        var long: Double?
        var lat: Double?
    }
 


//MARK: - extinsions

    extension AccidentHistoryViewController: UICollectionViewDataSource{
        
        // tell the collection view how many cells to make
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return accidentsArray.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            if ( accidentsArray.count == 0 ) {
                noAccidents.alpha = 1
            } else{
                noAccidents.alpha = 0
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccidentCell", for: indexPath as IndexPath) as! AccidentsCollectionViewCell
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true
            cell.layer.shadowColor  = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowRadius = 90
            cell.layer.shadowOffset = CGSize(width: 9, height: 9)
            cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            cell.map.layer.cornerRadius = 10
            cell.accidentLabel.text = "Accident #\(indexPath.row + 1)"
            
            //cause
            cell.vibrationLabel.text = "Accident cause: "
            if (accidentsArray[indexPath.row].getRotation() == "1023" ) {
                cell.vibration.text = "Rollover"
            }
            else {cell.vibration.text = "Impact" }
            //severity
            cell.inclinationLabel.text = "Accident severity: "
            if ( accidentsArray[indexPath.row].getRotation() == "1023" ) {
                cell.inclination.text = "High"
            }
            else if ( Double(accidentsArray[indexPath.row].getVib())! >= 50000 && Double(accidentsArray[indexPath.row].getVib())! <= 100000 ) {
                cell.inclination.text = "Low"
            }
            else if ( Double(accidentsArray[indexPath.row].getVib())! > 100000 && Double(accidentsArray[indexPath.row].getVib())! <= 200000 ) {
                cell.inclination.text = "Intermediate"
            }
            else if ( Double(accidentsArray[indexPath.row].getVib())! > 200000 ) {
                cell.inclination.text = "High"
            }
            
            // map view manipulation (inside cell)
            
            let lat = Double(accidentsArray[indexPath.row].getLatitude())!
            let long = Double(accidentsArray[indexPath.row].getLongitude())!
            
            let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long)))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = "Accident"
            let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 12000, longitudinalMeters: 12000)
            cell.map.setRegion(coordinateRegion, animated: true)
            cell.map.addAnnotation(annotation)

            // if user taps on map
            
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(goToLocation(sender:)))
            tap.lat = lat
            tap.long = long
            cell.map.addGestureRecognizer(tap)
            
            // accident status
            
                if ( accidentsArray[indexPath.row].getStatus() == "1" ) {
                    cell.status.text = "Processed"
                }
                else {
                    cell.status.text = "Canceled"
                    cell.status.textColor = UIColor(red: 0.784, green: 0.267, blue: 0.337, alpha: 1)
                }
            // date formatting
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

    //MARK: - Map View Delegate Extension
    extension AccidentHistoryViewController: MKMapViewDelegate{
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation)else{
                return nil
            }
            var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "accidentView")
            if pin == nil {
                pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "accidentView")
                pin?.canShowCallout = true
            }else{
                pin?.annotation = annotation
            }
            let img = UIImageView(image: UIImage(named: "pin"))
            pin?.image = img.image
    //        pin?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pin
        }
        
        
    }
