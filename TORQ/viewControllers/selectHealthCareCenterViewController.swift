//
//  selectHealthCareCenterViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 20/11/2021.
//

import UIKit
import FirebaseDatabase
import SCLAlertView

class selectHealthCareCenterViewController: UIViewController, UIAlertViewDelegate{
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var listUIView: UIView!
    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var Confirm: UIButton!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var sosRequestUserID : String!
    var selhealth = "None"
    var text = ""
    var numb = -1
    var rowDefaultSelected: Int = 0
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance(showCloseButton: false,contentViewCornerRadius: 15,buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance(contentViewCornerRadius: 15,buttonCornerRadius: 7,hideWhenBackgroundViewIsTapped: true)
    let hospitallist = ["None","Security Forces Hospital","King Salman Hospital","King Abdulaziz Hospital","Dallah Hospital","Green Crescent Hospital","King Khalid Hospital","King Abduallah Hospital","Prince Sultan Hospital"]
    
    
    //MARK: - Overriden Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Default select none
        let indexPath = IndexPath(row: 0, section: 0)
        tableList.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // 1- cancel button view
        Cancel.layer.cornerRadius = 15
        Cancel.layer.masksToBounds = true
        let gradientLayerr = CAGradientLayer()
        gradientLayerr.frame = Cancel.frame
        gradientLayerr.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayerr.startPoint = CGPoint(x: 0, y: 0)
        gradientLayerr.endPoint = CGPoint(x: 1, y: 0)
        gradientLayerr.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0.98, c: -0.75, d: 1.6, tx: 0.38, ty: -0.77))
        gradientLayerr.bounds = Cancel.bounds.insetBy(dx: -0.5*Cancel.bounds.size.width, dy: -0.5*Cancel.bounds.size.height)
        gradientLayerr.position = Cancel.center
        Cancel.layer.addSublayer(gradientLayerr)
        Cancel.layer.insertSublayer(gradientLayerr, at: 0)
        


        
        //2- confirm button view
        Confirm.layer.cornerRadius = 15
        Confirm.layer.masksToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = Confirm.frame
        gradientLayer.colors =  [
            UIColor(red: 0.102, green: 0.157, blue: 0.345, alpha: 1).cgColor,
            UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0.98, c: -0.75, d: 1.6, tx: 0.38, ty: -0.77))
        gradientLayer.bounds = Confirm.bounds.insetBy(dx: -0.5*Confirm.bounds.size.width, dy: -0.5*Confirm.bounds.size.height)
        gradientLayer.position = Confirm.center
        Confirm.layer.addSublayer(gradientLayer)
        Confirm.layer.insertSublayer(gradientLayer, at: 0)

    }
    
    func goToViewSOSRequests(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tb = storyboard.instantiateViewController(identifier: "paramedicHome") as! UITabBarController
        let vcs = tb.viewControllers!
        let viewSOS = vcs[1] as! ViewSOSRequestsViewController
        viewSOS.modalPresentationStyle = .fullScreen
        viewSOS.modalTransitionStyle = .coverVertical
        tb.selectedIndex = 1
        present(tb, animated: true, completion: nil)
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
            print(selhealth)
            print(self.sosRequestUserID!)
            ref.child("SOSRequests").observeSingleEvent(of: .value, with: { snapshot in
                for req in snapshot.children{
                    let obj = req as! DataSnapshot
                    print(obj)
                    
                    let status = obj.childSnapshot(forPath: "status").value as! String
                    let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                    
                    if (user_id == self.sosRequestUserID && status == "1"){
                        print("inside if")
                        let snapshotKey = obj.key
                        self.ref.child("SOSRequests").child(snapshotKey).updateChildValues(["status": "Processed"])
                        self.ref.child("ProcessingRequest").child(self.selhealth).childByAutoId().setValue(["Rquest_id":snapshotKey ,"User_id": self.sosRequestUserID])
                        
                        let alertView = SCLAlertView(appearance: self.apperanceWithoutClose)
                        alertView.addButton("Okay", backgroundColor: self.blueUIColor){
                            self.goToViewSOSRequests()
                        }
                        alertView.showCustom("Confirmed!", subTitle: "The request has been send to the health care cenetr.", color: self.blueUIColor, icon: self.alertSuccessIcon!, animationStyle: SCLAnimationStyle.topToBottom)
                    }
                }
                
            })
        }
    }
}


//MARK: - Table View
extension selectHealthCareCenterViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selhealth = hospitallist[indexPath.row]
        numb = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
}

extension selectHealthCareCenterViewController: UITableViewDataSource{
    
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
    
}








