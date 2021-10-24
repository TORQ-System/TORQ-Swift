//
//  ViewRequest_Report.swift
//  TORQ
//
//  Created by   Alshahrani on 13/03/1443 AH.
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
    
    @IBOutlet weak var blood: UILabel!
    @IBOutlet weak var disease: UILabel!
    @IBOutlet weak var medation: UILabel!
    @IBOutlet weak var algeer: UILabel!
    @IBOutlet weak var medation0: UILabel!
    @IBOutlet weak var algeer0: UILabel!
    ///
    var UID : String!
    var long : Double!
    var lang : Double!
    var time : String!
    var ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        contetnt()
        let vc = HospitaList()
        vc.text = "Hammock lomo literally microdosing street art pour-over"
        vc.UID1 = UID
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
//        ref.child("User").child(UID!).observe(.value, with: {(snapshot) in
//                   if let dec = snapshot.value as? [String :Any]
//                   {
//                    let Fname = dec["firstName"] as! String
//                       let lname = dec["lastName"] as! String
//                       print("hi\(Fname)")
//                       self.name_report.text = Fname+" "+lname
//                       self.namerequest.text = "\(Fname)'s Request"
//
//                   }
//
//               })
        
        
        ref.child("User").child(UID!).observe(.value, with: {(snapshot) in
                        if let dec = snapshot.value as? [String :Any]
                        {
                         let Fname1 = dec["firstName"] as! String
                            let lname1 = dec["lastName"] as! String
                            print("hi\(Fname1)")
                            self.name_report.text = Fname1+" "+lname1
                            self.namerequest.text = "\(Fname1)'s Request"
     
                        }
     
                    })
        ref.child("medical_info").queryOrdered(byChild:"user_id").observe(.childAdded, with: {(snapshot) in
                           if let dec = snapshot.value as? [String :Any]
                           {
                               
                               if (dec["user_id"] as! String == self.UID!){
                               
                            let try1 = dec["Blood"] as! String
                            let try2 = dec["allergies"] as! String
                            let try3 = dec["chronic_disease"] as! String
                            let try4 = dec["prescribes_medication"] as! String


                             //  let lname = dec["lastName"] as! String
                                   self.blood.text = try1
                                   self.disease.text = try3
                                   self.algeer0.text = try2
                                   self.medation0.text = try4
                                   print("2-\(try1)")
                                   print("1-\(try2)")
                                   print("1-\(try3)")
                                   print("1-\(try4)")


                                   
                               }
                             //  self.name_report.text = Fname+" "+lname
                            //   self.namerequest.text = "\(Fname)'s Request"
               //o
                           }
               
                       })
        //print(UID)
      //  DOB.text="WHY\(UID)"
        readDatabase()
        
    }
    @IBAction func back_butten(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func prosessing(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
               let vc = storyboard.instantiateViewController(identifier: "HospitaList") as! HospitaList
        vc.UID1 = String(UID)
               self.present(vc, animated: true, completion: nil)
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
