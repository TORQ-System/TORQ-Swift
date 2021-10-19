//
//  ViewRequest_Report.swift
//  TORQ
//
//  Created by  Lama Alshahrani on 13/03/1443 AH.
//

import UIKit
import FirebaseDatabase

class ViewRequest_Report: UIViewController {
    @IBOutlet weak var data_timeRE: UILabel!
    @IBOutlet weak var Rport_loc: UILabel!
    @IBOutlet weak var name_report: UILabel!
    @IBOutlet weak var DOB: UILabel!
    @IBOutlet weak var location_report: UIButton!
    @IBOutlet weak var namerequest: UILabel!
    
    ///
    var UID : String!
    var long : Double!
    var lang : Double!
    var time : String!
    var ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        contetnt()
        
    }
    @objc
    func findloc(sender:UIButton){
        
        print("try")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
               let vc = storyboard.instantiateViewController(identifier: "viewLocation") as! viewLocationViewController
        vc.latitude = lang
        vc.longitude = long
               vc.modalPresentationStyle = .fullScreen
               self.present(vc, animated: true, completion: nil)
    }
    func contetnt(){
        //location
        location_report.addTarget(self, action: #selector(findloc(sender: )), for: .touchUpInside)
            // time format
        let find = time.firstIndex(of: "+") ?? time.endIndex
        let find2 = time[..<find]
        let start = find2.index(find2.startIndex, offsetBy: 0)
        let end = find2.index(find2.startIndex, offsetBy: 10)
        let range = start...end

        let newString = String(find2[range])
        let start1 = find2.index(find2.startIndex, offsetBy: 10)
        let end1 = find2.index(find2.startIndex, offsetBy:18)
        let range1 = start1...end1
        let newString1 = String(find2[range1])
        data_timeRE.text = "\(newString), \(newString1) "
        ///
        ref.child("User").child(UID!).observe(.value, with: {(snapshot) in
                   if let dec = snapshot.value as? [String :Any]
                   {
                    let Fname = dec["firstName"] as! String
                       let lname = dec["lastName"] as! String
                       print("hi\(Fname)")
                       self.name_report.text = Fname+" "+lname
                       self.namerequest.text = "\(Fname)'s Request"
       
                   }
       
               })
        //print(UID)
      //  DOB.text="WHY\(UID)"
        readDatabase()
    }
    @IBAction func back_butten(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func readDatabase()
    
    {
        
//        var userName :String!
//        ref.child("User/\(UID)/firstName").observeSingleEvent(of: .value, with: { snapshot in  guard let value1 = snapshot.value as? String else {return}
//            print(value1)
//          userName = String(value1)
//                })
//       DOB.text = "\(userName)"
       
        
//        Database.database().reference().child("User").queryOrdered(byChild: "email")equalTo(2) { snapshot in
//
//            let object = snapshot.value as! [String: Any]
//    }
//        ref.child("User").queryOrdered(byChild: "time_stamp").observe(.childAdded) { snapshot in
//            let object = snapshot.value as! [String: Any]
//            let request = Request(user_id: object["user_id"] as! String, sensor_id: object["sensor_id"] as! String, request_id: object["request_id"] as! String, dateTime: object["time_stamp"] as! String, longitude: object["longitude"] as! String, latitude: object["latitude"] as! String, vib: object["vib"] as! String, rotation: object["rotation"] as! String, status: object["status"] as! String)
            
        
    
    }}
