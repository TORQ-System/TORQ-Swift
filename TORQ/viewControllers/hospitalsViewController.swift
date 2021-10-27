//
//  HospitaList.swift
//  TORQ
//
//  Created by  Alshahrani on 15/03/1443 AH.
//

import UIKit
import FirebaseDatabase
var ref = Database.database().reference()

class hospitalsViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource, UIAlertViewDelegate{
    
    //MARK: - @IBOutlet
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var tableList: UITableView!
    
    //MARK: - Variables
    var selhealth = "not"
    var numb = -1
    var UID1 : String!
    var text:String = ""
    
    //MARK: - Constants
    let hospitallist = ["none","Security Forces Hospital",
                        "King Salman Hospital",
                        "King Abdulaziz Hospital",
                        " Dallah Hospital",
                        " Green Crescent Hospital",
                        "King Faisal Specialist Hospital & Research Centre",
                        " King Saud Medical City-Pediatric Hospital","King Khalid Hospital","King Abduallah Hospital ","Prince Sultan Hospital"]
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableList.dataSource = self
        tableList.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: - @IBAction
    @IBAction func cancel_butt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirme(_ sender: Any) {
        if selhealth == "not"
        {
            print(selhealth)
            self.error.text = "Error,You have to select one first !!"
        }else{
            
            print(selhealth)
            print(UID1 as Any )
            ref.child("medical_info").child("medical1").removeValue()
            
            
            ref.child("Request").queryOrdered(byChild:"user_id").observe(.childAdded, with: {(snapshot) in
                if let dec = snapshot.value as? [String :Any]
                {
                    
                    if (dec["user_id"] as! String == self.UID1!){
                        print(snapshot.key)
                        let num = snapshot.key
                        ref.child("Request").child(num).updateChildValues(["status": "1"])
                        ref.child("processingRequest").childByAutoId().setValue(["healthcare":self.selhealth,"Rquest_id":dec["request_id"] as! String])
                        let alert = UIAlertController(title: "Confirmed", message: "The request has been send to the health care cenetr", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                            let presentingView = self.presentingViewController
                            self.dismiss(animated: false) {
                                presentingView?.dismiss(animated: true)
                            }
                        }
                                                     ))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        //                                       ref.child("Request").child(num).setValue(["user_id":dec["user_id"] as! String, "sensor_id": dec["sensor_id"] as! String, "request_id": dec["request_id"] as! String, "dateTime": dec["time_stamp"] as! String, "longitude": dec["longitude"] as! String, "latitude": dec["latitude"] as! String, "vib": dec["vib"] as! String, "rotation": dec["rotation"] as! String, "status": "1", "healthcare" : self.selhealth ])
                        
                        
                    }
                    //  self.name_report.text = Fname+" "+lname
                    //   self.namerequest.text = "\(Fname)'s Request"
                    //o
                }
                
            })
            
        }
    }
    
    // MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitallist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableList.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if hospitallist[indexPath.row] == "None"{
        cell.textLabel?.text = hospitallist[indexPath.row]
        cell.selectionStyle = .none
            cell.accessoryType = .checkmark}
        else{
            cell.textLabel?.text = hospitallist[indexPath.row]
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selhealth = hospitallist[indexPath.row]
       // tableList.ima
        numb = indexPath.row
        print(hospitallist[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .none
        print(hospitallist[indexPath.row] )
    }
    
    func goToViewRequests(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "viewRequests") as! requestsViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

}







