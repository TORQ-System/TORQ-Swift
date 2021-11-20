import UIKit
import FirebaseDatabase
import SwiftUI
import FirebaseAuth
import CoreLocation

import MapKit
class requestsViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var requestsColletionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var assignedRequests: UILabel!
    @IBOutlet weak var namecenter: UILabel!
    @IBOutlet weak var noprossing: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var segmentcontrol: UISegmentedControl!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var requests: [RequestAccident] = []
    var loggedInCenterEmail = Auth.auth().currentUser?.email
    var loggedInCenter: [String: Any]?
    var myRequests: [RequestAccident] = []
    let refrechcon = UIRefreshControl()
    var prossed : [RequestAccident] = []
   // var cordinate : [String: Any] = [:]
    
    var getnearest: [String : Any]?
    var switches = 0
    //MARK: - Overriden function
    override func viewWillAppear(_ animated: Bool) {
        getRequests()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI setup
//        setGradientBackground()
       setGradient()
        
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
      }
    
    func configureSegmentControl(){
           segmentcontrol.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControl.State.normal)
        segmentcontrol.layer.cornerRadius = 50
       // segmentcontrol.layer.borderColor = UIColor.white.cgColor
        segmentcontrol.layer.borderWidth = 0.01
        segmentcontrol.layer.masksToBounds = true
       // segmentcontrol.layer.cornerRadius = segmentcontrol.bounds.height / 2
      //  segmentcontrol.layer.borderColor = UIColor.blueColor().CGColor
      //  segmentcontrol.layer.borderWidth = 1
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
        let domainRange = loggedInCenterEmail!.range(of: "@")!
        let centerName = loggedInCenterEmail![..<domainRange.lowerBound]
        loggedInCenter = SRCACenters.getSRCAInfo(name: String(centerName))
        namecenter.text="\(centerName.firstUppercased)'s Requests"
        namecenter.text = "Accidents \nEmergency Requests"
     
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
        var fullName = ""
        var gender = ""
        ref.child("Request").queryOrdered(byChild: "time_stamp").observe(.value) { snapshot in
            for contact in snapshot.children{
             //   print("enter")

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
              
                self.ref.child("User").child(user_id).observe(.value, with: {(snapshot) in
                    if let dec = snapshot.value as? [String :Any]
                    {
                         fullName = dec["fullName"] as! String
                        gender = dec["gender"] as! String
                      //  print(fullName)
                        
                    }
               
              //  print("print\(fullName)")
                let request = RequestAccident(user_id:user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: lonitude, latitude:latitude , vib: vib, rotation:rotation , status: status ,name: fullName ,gender: gender)
               // print(request)

                //get active requests only
              //  if ( request.getStatus() == "0" ) {
                    self.requests.append(request)
              //  print("try to add\(self.requests)")
                    self.nearest(longitude: request.getLongitude(), latitude: request.getLatitude(), request: request)
                //}
                })
            }}
       // print(requests)

      //  print(myRequests)
      //  print(prossed)
        requestsColletionView.reloadData()
    }
    
    
    func nearest(longitude: String, latitude:String, request: RequestAccident){
        
        let nearest = SRCACenters.getNearest(longitude: Double(longitude)!, latitude: Double(latitude)!)
        getnearest = nearest
        
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
              ///  print(request)

            }
            else if request.status == "1"{
                prossed.append(request)
               // print(request)

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
      
    
    
    @objc
    func viewbutten(sender:UIButton){
        print("view")
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "requestReportViewController") as! requestReportViewController
//        vc.lang = Double(myRequests[sender.tag].getLatitude())!
//        vc.long = Double(myRequests[sender.tag].getLongitude())!
//        vc.time = myRequests[sender.tag].getDateTime()
//        vc.userMedicalReportID = String(myRequests[sender.tag].getUserID())
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "requestReportViewController") as! requestReportViewController
        if switches==1{
            vc.lang = Double(myRequests[sender.tag].getLatitude())!
        vc.long = Double(myRequests[sender.tag].getLongitude())!
        vc.time = myRequests[sender.tag].getDateTime()
        vc.userMedicalReportID = String(myRequests[sender.tag].getUserID())
            vc.Requestid = String(myRequests[sender.tag].getRequestID())
            vc.statusid = String(myRequests[sender.tag].getStatus())
        vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)}
        if switches==2{
        vc.lang = Double(prossed[sender.tag].getLatitude())!
        vc.long = Double(prossed[sender.tag].getLongitude())!
        vc.time = prossed[sender.tag].getDateTime()
        vc.userMedicalReportID = String(prossed[sender.tag].getUserID())
            vc.statusid = String(prossed[sender.tag].getStatus())
        vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)}
    
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
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "requestReportViewController") as! requestReportViewController
//        if switches==1{
//        vc.lang = Double(myRequests[indexPath.row].getLatitude())!
//        vc.long = Double(myRequests[indexPath.row].getLongitude())!
//        vc.time = myRequests[indexPath.row].getDateTime()
//        vc.userMedicalReportID = String(myRequests[indexPath.row].getUserID())
//            vc.Requestid = String(myRequests[indexPath.row].getRequestID())
//            vc.statusid = String(myRequests[indexPath.row].getStatus())
//        vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)}
//        if switches==2{
//        vc.lang = Double(prossed[indexPath.row].getLatitude())!
//        vc.long = Double(prossed[indexPath.row].getLongitude())!
//        vc.time = prossed[indexPath.row].getDateTime()
//        vc.userMedicalReportID = String(prossed[indexPath.row].getUserID())
//            vc.statusid = String(prossed[indexPath.row].getStatus())
//        vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)}
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

            //cell.name.text = "Accident #\(indexPath.row)"
            cell.name.text = myRequests[indexPath.row].getname()

            //My location
           let myLocation = CLLocation(latitude: getnearest!["latitude"] as! Double , longitude:  getnearest!["longitude"] as! Double)
            print("near\(String(describing: getnearest))")
            print("near\(getnearest!["latitude"] as! Double)")
            print("near\(getnearest!["longitude"] as! Double)")
            //My buddy's location
            let myBuddysLocation = CLLocation(latitude: Double (myRequests[indexPath.row].getLatitude())!, longitude: Double(myRequests[indexPath.row].getLongitude())!)

            //Measuring my distance to my buddy's (in km)
           let distance = myLocation.distance(from: myBuddysLocation) / 1000

            //Display the result in km
            print(String(format: "The distance to my buddy is %.01fkm", distance))
           // cell.dateTime.text = myRequests[indexPath.row].getDateTime()
            cell.distance.text =  String(format: " %.01fkm", distance)
            cell.gender.text = myRequests[indexPath.row].getGender()
            cell.status.text = "Active"

            cell.viewbutten.tag = indexPath.row
            cell.viewbutten.addTarget(self, action: #selector(viewbutten(sender: )), for: .touchUpInside)
            let gradient: CAGradientLayer = CAGradientLayer()
            
            gradient.colors = [
                UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
                UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor
            ]
            
            gradient.locations = [0, 1]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.frame = cell.viewbutten.layer.frame
            
            cell.viewbutten.layer.insertSublayer(gradient, at: 0)
            cell.viewbutten.layer.shadowOpacity = 0.3
            cell.viewbutten.layer.shadowOffset = CGSize(width: 5, height: 5)
            cell.viewbutten.layer.shadowRadius = 10
            let lat = Double(myRequests[indexPath.row].getLatitude())!
            let long = Double(myRequests[indexPath.row].getLongitude())!

            let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long)))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = ""
            let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 12000, longitudinalMeters: 12000)
            cell.map.setRegion(coordinateRegion, animated: true)
            cell.map.addAnnotation(annotation)
            // if user taps on map
            
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(goToLocation(sender:)))
            tap.lat = lat
            tap.long = long
            cell.map.addGestureRecognizer(tap)
            
            cell.circle1.layer.cornerRadius = cell.circle1.frame.size.height / 2
           
          //  cell.circle1.layer.shadowColor = UIColor.black.cgColor
            cell.circle1.layer.shadowOpacity = 0.3
            cell.circle1.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.circle1.layer.shadowRadius = 10
           // cell.circle1.layer.shouldRasterize = true
           // cell.circle1.layer.rasterizationScale = UIScreen.main.scale
            cell.circle2.layer.cornerRadius = cell.circle2.frame.size.height / 2
            
            // cell.circle2.layer.shadowColor = UIColor.black.cgColor
             cell.circle2.layer.shadowOpacity = 0.3
             cell.circle2.layer.shadowOffset = CGSize(width: 1, height: 1)
             cell.circle2.layer.shadowRadius = 10
            // cell.circle2.layer.shouldRasterize = true
            cell.circle3.layer.cornerRadius = cell.circle3.frame.size.height / 2
            
             //cell.circle3.layer.shadowColor = UIColor.black.cgColor
             cell.circle3.layer.shadowOpacity = 0.3
             cell.circle3.layer.shadowOffset = CGSize(width: 1, height: 1)
             cell.circle3.layer.shadowRadius = 10
            // cell.circle3.layer.shouldRasterize = true
           



        case 1:
            switches = 2
            print(switches)
           // cell.name.text = "Accident #\(indexPath.row)"
           // cell.name.text = prossed[indexPath.row].getname()

            //cell.dateTime.text = prossed[indexPath.row].getDateTime()
            cell.name.text = prossed[indexPath.row].getname()

            //My location
           let myLocation = CLLocation(latitude: getnearest!["latitude"] as! Double , longitude:  getnearest!["longitude"] as! Double)
            print("near\(String(describing: getnearest))")
            print("near\(getnearest!["latitude"] as! Double)")
            print("near\(getnearest!["longitude"] as! Double)")
            //My buddy's location
            let myBuddysLocation = CLLocation(latitude: Double (prossed[indexPath.row].getLatitude())!, longitude: Double(prossed[indexPath.row].getLongitude())!)

            //Measuring my distance to my buddy's (in km)
           let distance = myLocation.distance(from: myBuddysLocation) / 1000

            //Display the result in km
            print(String(format: "The distance to my buddy is %.01fkm", distance))
           // cell.dateTime.text = myRequests[indexPath.row].getDateTime()
         cell.distance.text =  String(format: " %.01fkm", distance)
          cell.gender.text = prossed[indexPath.row].getGender()
           cell.status.text = "Procced"
            let lat = Double(prossed[indexPath.row].getLatitude())!
            let long = Double(prossed[indexPath.row].getLongitude())!
            let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long)))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = ""
            let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 12000, longitudinalMeters: 12000)
            cell.map.setRegion(coordinateRegion, animated: true)
            cell.map.addAnnotation(annotation)
            cell.circle1.layer.cornerRadius = cell.circle1.frame.size.height / 2
           
          //  cell.circle1.layer.shadowColor = UIColor.black.cgColor
            cell.circle1.layer.shadowOpacity = 0.3
            cell.circle1.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.circle1.layer.shadowRadius = 10
           // cell.circle1.layer.shouldRasterize = true
           // cell.circle1.layer.rasterizationScale = UIScreen.main.scale
            cell.circle2.layer.cornerRadius = cell.circle2.frame.size.height / 2
            
            // cell.circle2.layer.shadowColor = UIColor.black.cgColor
             cell.circle2.layer.shadowOpacity = 0.3
             cell.circle2.layer.shadowOffset = CGSize(width: 1, height: 1)
             cell.circle2.layer.shadowRadius = 10
            // cell.circle2.layer.shouldRasterize = true
            cell.circle3.layer.cornerRadius = cell.circle3.frame.size.height / 2
            
             //cell.circle3.layer.shadowColor = UIColor.black.cgColor
             cell.circle3.layer.shadowOpacity = 0.3
             cell.circle3.layer.shadowOffset = CGSize(width: 1, height: 5)
             cell.circle3.layer.shadowRadius = 10
            
           // cell.circle1.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
          //  cell.circle1.layer.shadowColor = UIColor.black.cgColor
            //cell.circle1.layer.shadowOpacity = 0.5
           // cell.circle1.layer.shadowOffset = CGSize(width: 5, height: 5)
            //cell.circle1.layer.shadowRadius = 25
           // cell.circle1.layer.shouldRasterize = true
            // if user taps on map
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(goToLocation(sender:)))
            tap.lat = lat
            tap.long = long
            cell.map.addGestureRecognizer(tap)
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
        return CGSize(width: collectionView.frame.width/1.1, height: 129)
    }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}
//MARK: - Map View Delegate Extension
extension requestsViewController: MKMapViewDelegate{
    
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
    
    

//extension requestsViewController: UICollectionViewDelegateFlowLayout{
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 360, height: 170)
//    }
//
//}

   
}
