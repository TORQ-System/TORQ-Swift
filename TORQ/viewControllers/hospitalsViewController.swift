//
//  HospitaList.swift
//  TORQ
//
//  Created by  Alshahrani on 15/03/1443 AH.
//

import UIKit
import FirebaseDatabase

class hospitalsViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource, UIAlertViewDelegate{
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var listUIView: UIView!
    
    //MARK: - Variables
    var selhealth = "None"
    var numb = -1
    var userMedicalReportID : String!
    var text:String = ""
    var rowDefaultSelected: Int = 0
    var ref = Database.database().reference()
    
    //MARK: - Constants
    let hospitallist = ["None","Security Forces Hospital",
                        "King Salman Hospital",
                        "King Abdulaziz Hospital",
                        "Dallah Hospital",
                        "Green Crescent Hospital",
                        "King Saud Medical City-Pediatric Hospital",
                        "King Khalid Hospital",
                        "King Abduallah Hospital",
                        "Prince Sultan Hospital"]

    
    //MARK: - Overriden Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Default select none
        let indexPath = IndexPath(row: 0, section: 0)
        tableList.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableList.dataSource = self
        tableList.delegate = self
        
        configureView()
    }
    
    // MARK: - Functions
    func configureView(){
        listUIView.layer.cornerRadius = 20
        listUIView.layer.shadowColor = UIColor.black.cgColor
        listUIView.layer.shadowOpacity = 0.5
        listUIView.layer.shadowOffset = CGSize(width: 5, height: 5)
        listUIView.layer.shadowRadius = 25
        listUIView.layer.shouldRasterize = true
        listUIView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func goToViewRequests(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "viewRequests") as! requestsViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitallist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableList.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = hospitallist[indexPath.row]
        cell.textLabel?.highlightedTextColor = UIColor(red: 201/255, green: 69/255, blue: 87/255, alpha: 1)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 201/255, green: 69/255, blue: 87/255, alpha: 0.1)
        cell.selectedBackgroundView = backgroundView
        
        if hospitallist[indexPath.row] != "None"{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selhealth = hospitallist[indexPath.row]
        numb = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    //MARK: - @IBAction
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        if selhealth == "None"{
            print(selhealth)
            let alert = UIAlertController(title: "You must select", message: "Select or cancel", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            ref.child("Request").queryOrdered(byChild:"user_id").observe(.childAdded, with: {(snapshot) in
                if let dec = snapshot.value as? [String :Any]{
                    if (dec["user_id"] as! String == self.userMedicalReportID!){
                        let snapshotKey = snapshot.key
                        self.ref.child("Request").child(snapshotKey).updateChildValues(["status": "1"])
                        self.ref.child("processingRequest").childByAutoId().setValue(["healthcare":self.selhealth,"Rquest_id":dec["request_id"] as! String])
                        
                        let alert = UIAlertController(title: "Confirmed", message: "The request has been send to the health care cenetr", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                            let presentingView = self.presentingViewController
                            self.dismiss(animated: false) {
                                presentingView?.dismiss(animated: true)
                            }}))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
}







