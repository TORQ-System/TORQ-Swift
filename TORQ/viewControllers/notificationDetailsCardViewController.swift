//
//  notificationDetailsCardViewController.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 04/12/2021.
//

import UIKit
import Firebase
import SCLAlertView

class notificationDetailsCardViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var requestStatus: UIView!
    @IBOutlet weak var requestStatusLabel: UILabel!
    @IBOutlet weak var requestStatusDetails: UILabel!
    @IBOutlet weak var requestStatusIcon: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var cancelButton: UIView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var from: UILabel!
    
    //MARK: - Variables
    var cancelTap = UITapGestureRecognizer()
    var requestChanged = -1
    var notificationDetails: notification!
    var assignedRequest: Request!
    
    //MARK: - Constants
    let ref = Database.database().reference()
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperance = SCLAlertView.SCLAppearance(contentViewCornerRadius: 15,buttonCornerRadius: 7,hideWhenBackgroundViewIsTapped: true)
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.isHidden = true
        requestChanged = -1
        configureNotification()
        configureCancelButton()
        getRequest()
    }
    
    //MARK: - Functions
    func configureNotification(){
        notificationTitle.text = notificationDetails.getTitle()
        body.text = notificationDetails.getBody()
        
        if notificationDetails.getType() == "emergency"{
            subtitle.isHidden = true
        } else {
            from.text = "from TORQ"
            subtitle.text = notificationDetails.getSubtitle()
        }
        
        date.text = notificationDetails.getDate()
        time.text = notificationDetails.getTime()
        
        if(notificationDetails.getType() == "emergency"){
            self.ref.child("User").getData(completion:{error, snapshot in
                guard error == nil else { return }
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    if obj.key == self.notificationDetails.getSender() {
                        print(fullName)
                        DispatchQueue.main.async() {
                            self.from.text = "from \(fullName)"
                        }
                    }
                }
            })
        }
    }
    func getRequest(){
        ref.child("Request").observe(.value) { snapshot in
            for request in snapshot.children{
                let obj = request as! DataSnapshot
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let longitude = obj.childSnapshot(forPath: "longitude").value as! String
                let request_id = obj.childSnapshot(forPath: "request_id").value as! String
                let rotation = obj.childSnapshot(forPath: "rotation").value as! String
                let sensor_id = obj.childSnapshot(forPath: "sensor_id").value as! String
                let status = obj.childSnapshot(forPath: "status").value as! String
                let time_stamp = obj.childSnapshot(forPath: "time_stamp").value as! String
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                let vib = obj.childSnapshot(forPath: "vib").value as! String
                
                if self.notificationDetails.getRequestID() == request_id{
                    print(request)
                    self.requestChanged+=1
                    self.assignedRequest = Request(user_id: user_id, sensor_id: sensor_id, request_id: request_id, dateTime: time_stamp, longitude: longitude, latitude: latitude, vib: vib, rotation: rotation, status: status)
                    self.configureRequestStatus()
                }
            }
        }
    }
    
    func configureCancelButton(){
        /* Add tap gesture */
        cancelTap = UITapGestureRecognizer(target: self, action: #selector(self.cancelPressed(_:)))
        cancelTap.numberOfTapsRequired = 1
        cancelTap.numberOfTouchesRequired = 1
        cancelButton.addGestureRecognizer(cancelTap)
        cancelButton.isUserInteractionEnabled = true
        
        /* Add UI config */
        let gradient: CAGradientLayer = CAGradientLayer()
        roundView.layer.cornerRadius = 20
        roundView.layer.shouldRasterize = true
        roundView.layer.rasterizationScale = UIScreen.main.scale
        gradient.cornerRadius = 20
        gradient.colors = [UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
                           UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = roundView.bounds
        roundView.layer.insertSublayer(gradient, at: 0)
    }
    
    
    func configureRequestStatus(){
        requestStatus.layer.cornerRadius = 15
        switch assignedRequest.getStatus() {
        case "0":
            setBackgroundColor(requestView: requestStatus, type: "blue")
            requestStatusLabel.text = "Active Request"
            requestStatusDetails.text = "waiting for paramedics to arrive!"
            requestStatusIcon.image = UIImage(named: "activeIcon")
            guard notificationDetails.getType() == "emergency" else{
                cancelButton.isHidden = false
                return
            }
            cancelButton.isHidden = true
            break
        case "1":
            setBackgroundColor(requestView: requestStatus, type: "red")
            requestStatusLabel.text = "Processed Request"
            requestStatusIcon.image = UIImage(named: "processedIcon")
            findProcessedHospital()
            cancelButton.isHidden = true
            break
        case "2":
            setBackgroundColor(requestView: requestStatus, type: "yellow")
            requestStatusLabel.text = "Cancelled Request"
            requestStatusDetails.text = "has been cancelled by the user"
            requestStatusIcon.image = UIImage(named: "cancelledIcon")
            cancelButton.isHidden = true
            break
        default:
            setBackgroundColor(requestView: requestStatus, type: "gray")
            break
        }
    }
    
    func findProcessedHospital(){
        ref.child("ProcessingRequest").observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children{
                let hospital = child as! DataSnapshot
                for hospitalChild in hospital.children{
                    let processedRequest = hospitalChild as! DataSnapshot
                    let request_id = processedRequest.childSnapshot(forPath: "Rquest_id").value as! String
                    if(request_id == self.notificationDetails.getRequestID()){
                        DispatchQueue.main.async() {
                            self.requestStatusDetails.text = "processed at \(hospital.key)"
                        }
                    }
                }
            }
        }
    }
    
    func setBackgroundColor(requestView: UIView, type: String){
        let gradient = CAGradientLayer()
        let color: [CGColor]?
        
        if(type == "red"){
            color = [UIColor(red: 0.887, green: 0.294, blue: 0.375, alpha: 1).cgColor,
                     UIColor(red: 0.933, green: 0.453, blue: 0.518, alpha: 1).cgColor]
        } else if(type == "blue"){
            color = [UIColor(red: 0.29, green: 0.67, blue: 0.871, alpha: 1).cgColor,
                     UIColor(red: 0.54, green: 0.771, blue: 0.9, alpha: 1).cgColor]
        } else if type == "yellow"{
            color = [UIColor(red: 1, green: 0.644, blue: 0.139, alpha: 1).cgColor,
                     UIColor(red: 1, green: 0.782, blue: 0.473, alpha: 1).cgColor]
        } else{
            color = [UIColor.lightGray.cgColor, UIColor.lightGray.cgColor]
        }
        
        requestView.backgroundColor = nil
        gradient.colors = color!
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = requestView.bounds
        gradient.cornerRadius = 15
        requestView.layer.shadowColor = color?[0]
        requestView.layer.shadowOffset = CGSize(width: 1, height: 10)
        requestView.layer.shadowRadius = 10
        requestView.layer.shadowOpacity = 0.5
        requestView.layer.masksToBounds = false
        
        guard requestChanged == 0 else {
            requestView.layer.sublayers?[0].removeFromSuperlayer()
            requestView.layer.insertSublayer(gradient, at: 0)
            requestView.setNeedsDisplay()
            return
        }
        
        requestView.layer.insertSublayer(gradient, at: 0)
    }
    
    @objc func cancelPressed(_ sender: UITapGestureRecognizer) {
        let alertView = SCLAlertView(appearance: self.apperance)
        alertView.addButton("Cancel request", backgroundColor: self.redUIColor){
            self.ref.child("Request").child("Req\(self.assignedRequest.getRequestID())").updateChildValues(["status": "2"]){(error, ref) in
                if error == nil{
                    SCLAlertView(appearance: self.apperance).showCustom("Success", subTitle: "Request has been cancelled", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", animationStyle: SCLAnimationStyle.topToBottom)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        alertView.showCustom("Are you sure?", subTitle: "A cancelled request will not go through to paramedics", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Go back", animationStyle: SCLAnimationStyle.topToBottom)
    }
    
}
