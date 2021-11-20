//
//  SOSRequestViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 05/11/2021.
//

import UIKit
import Firebase
import SCLAlertView

class SOSRequestViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var asteriskContainer: UIView!
    @IBOutlet weak var sosLabel: UILabel!
    @IBOutlet weak var sosView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var seeDetails: UIButton!
    @IBOutlet var sendSOSrequest: UITapGestureRecognizer!
    
    
    
    //MARK: - Variables
    var userID = Auth.auth().currentUser?.uid
    var ref = Database.database().reference()
    var secondsRemaining = 15
    var longitude: String?
    var latitude: String?
    var flag:Bool = false
    var SOS: SOSRequest?
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    var sosRequestID: String?
    
    

    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        checkSOSRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkSOSRequests()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        flag = false
    }
    
    //MARK: - Functions
    
    private func layoutSubviews(){
        //1- asteriskContainer view
        asteriskContainer.layer.cornerRadius = asteriskContainer.layer.frame.height/2
        asteriskContainer.layer.masksToBounds = true
        asteriskContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        asteriskContainer.layer.borderWidth = 1
        
        //2- SOS container View
        sosView.layer.cornerRadius = sosView.layer.frame.height/2
        sosView.layer.masksToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = sosView.frame
        gradientLayer.colors = [UIColor(red: 0.749, green: 0.192, blue: 0.275, alpha: 1).cgColor,UIColor(red: 0.886, green: 0.435, blue: 0.502, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.53, b: -0.48, c: 0.48, d: 0.53, tx: 0.09, ty: 0.37))
        gradientLayer.bounds = sosView.bounds.insetBy(dx: -0.5*sosView.bounds.size.width, dy: -0.5*sosView.bounds.size.height)
        gradientLayer.position = sosView.center
        sosView.layer.addSublayer(gradientLayer)
        sosView.bringSubviewToFront(sosLabel)

        //3- first Layer View
        firstView.layer.cornerRadius = firstView.layer.frame.height/2
        firstView.layer.masksToBounds = true
        firstView.backgroundColor = UIColor(red: 0.768627451, green: 0.2235294118, blue: 0.3058823529, alpha: 0.3)
        
        //4- second Layer View
        secondView.layer.cornerRadius = secondView.layer.frame.height/2
        secondView.layer.masksToBounds = true
        secondView.backgroundColor = UIColor(red: 0.768627451, green: 0.2235294118, blue: 0.3058823529, alpha: 0.2)

        //5- third Layer View
        thirdView.layer.cornerRadius = thirdView.layer.frame.height/2
        thirdView.layer.masksToBounds = true
        thirdView.backgroundColor = UIColor(red: 0.768627451, green: 0.2235294118, blue: 0.3058823529, alpha: 0.1)
        
        //6- see datails button
        seeDetails.isEnabled = false
        seeDetails.alpha = 0
    }
    
    private func checkSOSRequests(){
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            self.ref.child("SOSRequests").observe(.value, with: { snapshot in
                for requests in snapshot.children{
                    let obj = requests as! DataSnapshot
                    let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                    let status = obj.childSnapshot(forPath: "status").value as! String
                    let sent = obj.childSnapshot(forPath: "sent").value as! String
                    let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                    let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                    let assigned_center = obj.childSnapshot(forPath: "assigned_center").value as! String
                    
                    let date = Date()
                    let calendar = Calendar.current
                    let day = calendar.component(.day, from: date)
                    let month = calendar.component(.month, from: date)
                    let year = calendar.component(.year, from: date)
                    let hour = calendar.component(.hour, from: date)
                    let minutes = calendar.component(.minute, from: date)
                    
                    let sos = SOSRequest(user_id: user_id, user_name: "user_name", status: status, assignedCenter: assigned_center, sent: sent, longitude: longitude, latitude: latitude, timeDate: "\(month)/\(day)/\(year)   \(hour):\(minutes)")
                    

                    if user_id == self.userID && (status != "Processed" && status != "Cancelled") {
                        self.flag = true
                        //update UI
                        if ( (self.secondsRemaining == 0) || (self.secondsRemaining != 15) ) {
                            self.SOS = sos
                            self.sosLabel.text = "SOS Sent!"
                            self.seeDetails.alpha = 1
                            self.seeDetails.isEnabled = true
                        }
                        else if self.secondsRemaining == 15 && (status == "1") {
                            self.SOS = sos
                            self.sosLabel.text = "SOS Sent!"
                            self.seeDetails.alpha = 1
                            self.seeDetails.isEnabled = true
                        }else if ( (self.secondsRemaining == 15) && (status == "0") ){
                            self.SOS = sos
                            self.sosLabel.text = "00:15"
                            self.seeDetails.alpha = 0
                            self.seeDetails.isEnabled = false
                        }
                        
                        print("flag in checkSOSRequests \(self.flag)")
                    }else{
                        self.flag = false
                        self.sosLabel.text = "SOS"
                        self.seeDetails.alpha = 0
                        self.seeDetails.isEnabled = false
                    }
                }
            })
            print("flag out checkSOSRequests")
        }
    }
    
    private func updateSOSRequestsStatus(update: String){
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            self.ref.child("SOSRequests").observeSingleEvent(of:.value, with: { snapshot in
                for requests in snapshot.children{
                    let obj = requests as! DataSnapshot
                    let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                    let status = obj.childSnapshot(forPath: "status").value as! String
                    if user_id == self.userID && status == "0" {
                        self.ref.child("SOSRequests").child(obj.key).updateChildValues(["status":update])
                    }
                }
            })
            print("flag out checkSOSRequests \(self.flag)")
        }
    }
    
    func nearest() -> String{
        let nearest = SRCACenters.getNearest(longitude: Double(longitude!)!, latitude: Double(latitude!)!)
        return nearest["name"] as! String
    }
    
    private func goToDetails(){
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "sosDetailsViewController") as! sosDetailsViewController
        vc.SOSRequest = SOS
        vc.sosId = sosRequestID
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        if secondsRemaining > 0 && secondsRemaining != 15{
            let alertView = SCLAlertView(appearance: self.apperance)
            alertView.addButton("Yes, I’m sure", backgroundColor: self.redUIColor){
                // set flag to false
                self.flag = false
                // update status to cancel
                self.updateSOSRequestsStatus(update: "Cancelled")
                self.dismiss(animated: true, completion: nil)
            }
            alertView.showCustom("Warning", subTitle: "Once you exit this screen, your SOS request will be canceled. Are you sure you want to cancel your request?", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "No, I’ll wait", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sosRequest(_ sender: Any) {
        
        // check if there is an active sos request for this user
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            checkSOSRequests()
        }
        if flag {
            SCLAlertView(appearance: self.apperance).showCustom("Oh no!", subTitle: "you have an active request, please chat with your assigned paramedic or cancel your request", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
        }else{
            let alertView = SCLAlertView(appearance: self.apperance)
            alertView.addButton("Yes, I'm sure", backgroundColor: self.redUIColor){
                print("seconds remaining: \(self.secondsRemaining)")
                
                //1-  create SOS Request object
                let date = Date()
                let calendar = Calendar.current
                let day = calendar.component(.day, from: date)
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                let hour = calendar.component(.hour, from: date)
                let minutes = calendar.component(.minute, from: date)
                let sosRequest = SOSRequest(user_id: self.userID!, user_name: "user", status: "0", assignedCenter: self.nearest(), sent: "Yes", longitude: self.longitude!, latitude: self.latitude!, timeDate: "\(month)/\(day)/\(year)   \(hour):\(minutes)")
                
                //2- write the child into the node in firebase
                let random = UUID().uuidString
                self.sosRequestID = random
                self.ref.child("SOSRequests").child(random).setValue(["user_id":sosRequest.getUserID(),"status":sosRequest.getStatus(),"assigned_center":sosRequest.getAssignedCenter(),"sent":sosRequest.getSent(),"longitude":sosRequest.getLongitude(),"latitude":sosRequest.getLatitude(),"time_date":sosRequest.getTimeDate()])
                
                self.sosLabel.text = "00:15"
                self.seeDetails.alpha = 0
                self.seeDetails.isEnabled = false
                
                //3- update timer
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
                    //TODO:- check if the user clicks on the button while the timer is fired
                    if self.secondsRemaining > 0 || self.secondsRemaining == 15{
                        self.SOS = sosRequest
                        self.seeDetails.alpha = 0
                        self.seeDetails.isEnabled = false
                        self.secondsRemaining -= 1
                        if self.secondsRemaining < 10 {
                            self.sosLabel.text = "00:0\(self.secondsRemaining)"
                        }else{
                            self.sosLabel.text = "00:\(self.secondsRemaining)"
                        }
                    } else {
                        self.SOS = sosRequest
                        self.sosLabel.text = "SOS Sent!"
                        self.seeDetails.alpha = 1
                        self.seeDetails.isEnabled = true
                        //upadte the status to 1
                        self.updateSOSRequestsStatus(update: "1")
                        //show notification that the request is sent
                        // direct the user to next page
                        self.goToDetails()
                        Timer.invalidate()
                    }
                }

            }
            alertView.showCustom("Warning", subTitle: "Are you sure you need SOS help?", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Cancel", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
        }
    }
    
    
    @IBAction func sosDetails(_ sender: Any) {
        //upadte the status to 1
        self.updateSOSRequestsStatus(update: "1")
        goToDetails()
    }
    
    
}

