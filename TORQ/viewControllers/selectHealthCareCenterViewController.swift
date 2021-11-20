//
//  selectHealthCareCenterViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 20/11/2021.
//

import UIKit
import FirebaseDatabase
import SCLAlertView

class selectHealthCareCenterViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource, UIAlertViewDelegate{
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var listUIView: UIView!
    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var Confirm: UIButton!
    
    //MARK: - Variables
    var selhealth = "None"
    var numb = -1
    var sosRequestUserID : String!
    var text:String = ""
    var rowDefaultSelected: Int = 0
    var ref = Database.database().reference()
    
    //MARK: - Constants
    let hospitallist = ["None","Security Forces Hospital",
                        "King Salman Hospital",
                        "King Abdulaziz Hospital",
                        "Dallah Hospital",
                        "Green Crescent Hospital",
                        "King Khalid Hospital",
                        "King Abduallah Hospital",
                        "Prince Sultan Hospital"]
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance(
        showCloseButton: false,
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    
    
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
        listUIView.layer.shadowOpacity = 0.65
        listUIView.layer.shadowOffset = CGSize(width: 5, height: 5)
        listUIView.layer.shadowRadius = 25
        listUIView.layer.shouldRasterize = true
        listUIView.layer.rasterizationScale = UIScreen.main.scale
        Cancel.layer.cornerRadius = 15
        Confirm.layer.cornerRadius = 15
    }
    
//    func goToViewRequests(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "viewRequests") as! requestsViewController
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true, completion: nil)
//    }
    
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
        print("pressed")
        if selhealth == "None"{
            print(selhealth)
            SCLAlertView(appearance: self.apperance).showCustom("Select a Hospital", subTitle: "You must select a hospital to process the request or cancel." , color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
        }
        else {
            ref.child("SOSRequests").observeSingleEvent(of: .childAdded, with: { snapshot in
                if let dec = snapshot.value as? [String :Any]{
                    
                    if (dec["user_id"] as? String == self.sosRequestUserID && dec["status"]as! String == "1"){
                        
                        let snapshotKey = snapshot.key
                        self.ref.child("SOSRequests").child(snapshotKey).updateChildValues(["status": "Processed"])
                        self.ref.child("ProcessingRequest").child(self.selhealth).childByAutoId().setValue(["Rquest_id":snapshotKey ,"User_id": self.sosRequestUserID])
                        
                        let alertView = SCLAlertView(appearance: self.apperanceWithoutClose)
                        
                        alertView.addButton("Okay", backgroundColor: self.blueUIColor){
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertView.showCustom("Confirmed!", subTitle: "The request has been send to the health care cenetr.", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
                }
                    
            }
                
            })
    }
}
}







