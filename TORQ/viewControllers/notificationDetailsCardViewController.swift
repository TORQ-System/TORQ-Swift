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
    @IBOutlet weak var canceledRequest: UIView!
    @IBOutlet weak var activeRequest: UIView!
    @IBOutlet weak var processedRequest: UIView!
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
    var locationTap = UITapGestureRecognizer()
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
        
        notificationTitle.text = notificationDetails.getTitle()
        body.text = notificationDetails.getBody()
        
        if notificationDetails.getType() == "emergency"{
            subtitle.isHidden = true
        } else {
            from.text = "TORQ"
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
                            self.from.text = fullName
                        }
                    }
                }
            })
        }
        
        getRequest()
        configureTapGesture()
        configureButtonsView()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
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
        
    func configureTapGesture(){
        /* When the user taps cancel */
        cancelTap = UITapGestureRecognizer(target: self, action: #selector(self.cancelPressed(_:)))
        cancelTap.numberOfTapsRequired = 1
        cancelTap.numberOfTouchesRequired = 1
        cancelButton.addGestureRecognizer(cancelTap)
        cancelButton.isUserInteractionEnabled = true
        
        /* When the user taps view location        locationTap = UITapGestureRecognizer(target: self, action: #selector(self.locationPressed(_:)))
        locationTap.numberOfTapsRequired = 1
        locationTap.numberOfTouchesRequired = 1
        viewLocationButtonView.addGestureRecognizer(locationTap)
        viewLocationButtonView.isUserInteractionEnabled = true
         */

    }
    
    func configureButtonsView(){
        /* Adjust the view location button's UI
        viewLocationButtonView.layer.cornerRadius = 15
        viewLocationButtonView.layer.masksToBounds = true
        viewLocationButtonView.layer.shouldRasterize = true
        viewLocationButtonView.layer.rasterizationScale = UIScreen.main.scale
        viewLocationButtonView.layer.shadowColor = UIColor.black.cgColor
        viewLocationButtonView.layer.shadowOffset = CGSize(width: 1, height: 2)
        viewLocationButtonView.layer.shadowRadius = 5
        viewLocationButtonView.layer.shadowOpacity = 0.25
        viewLocationButtonView.layer.masksToBounds = false
         */
        
        /* Adjust the cancel button's UI */
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
        /* Set requests radius */
        canceledRequest.layer.cornerRadius = canceledRequest.frame.height/2
        activeRequest.layer.cornerRadius = activeRequest.frame.height/2
        processedRequest.layer.cornerRadius = processedRequest.frame.height/2
        
        /* Set status color and dropshadow */
        switch assignedRequest.getStatus() {
        case "0":
            setBackgroundColor(requestView: activeRequest, type: "blue")
            setBackgroundColor(requestView: canceledRequest, type: "gray")
            setBackgroundColor(requestView: processedRequest, type: "gray")
            cancelButton.isHidden = false
            break
        case "1":
            setBackgroundColor(requestView: processedRequest, type: "red")
            setBackgroundColor(requestView: activeRequest, type: "gray")
            setBackgroundColor(requestView: canceledRequest, type: "gray")
            guard notificationDetails.getType() == "emergency" else{
                cancelButton.isHidden = true
                return
            }
            cancelButton.isHidden = false
            break
        case "2":
            setBackgroundColor(requestView: canceledRequest, type: "yellow")
            setBackgroundColor(requestView: activeRequest, type: "gray")
            setBackgroundColor(requestView: processedRequest, type: "gray")
            cancelButton.isHidden = true
            break
        default:
            break
        }
    }
    
    func setBackgroundColor(requestView: UIView, type: String){
        let gradient = CAGradientLayer()
        let color: [CGColor]?
        let shadowColor: CGColor?
        
        if(type == "red"){
            color = [UIColor(red: 0.871, green: 0.408, blue: 0.471, alpha: 1).cgColor,
                     UIColor(red: 0.754, green: 0.149, blue: 0.231, alpha: 1).cgColor]
            shadowColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 0.8).cgColor
        } else if(type == "blue"){
            color = [UIColor(red: 0.446, green: 0.667, blue: 0.812, alpha: 1).cgColor,
                     UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor]
            shadowColor = UIColor(red: 0.318, green: 0.506, blue: 0.698, alpha: 0.8).cgColor
        } else if type == "yellow"{
            color = [UIColor(red: 0.988, green: 0.762, blue: 0.442, alpha: 1).cgColor,
                     UIColor(red: 1, green: 0.587, blue: 0, alpha: 1).cgColor,]
            shadowColor = UIColor(red: 0.988, green: 0.741, blue: 0.384, alpha: 0.7).cgColor
        } else{
            color = [UIColor.lightGray.cgColor, UIColor.lightGray.cgColor]
            shadowColor = UIColor.clear.cgColor
        }
        
        requestView.backgroundColor = nil
        gradient.colors = color!
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = requestView.bounds
        gradient.cornerRadius = requestView.frame.height/2
        requestView.layer.shadowColor = shadowColor!
        requestView.layer.shadowOffset = CGSize(width: 0, height: 0)
        requestView.layer.shadowRadius = 15
        requestView.layer.shadowOpacity = 1
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
                    SCLAlertView(appearance: self.apperance).showCustom("Sucess", subTitle: "Request has been cancelled", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", animationStyle: SCLAnimationStyle.topToBottom)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        alertView.showCustom("Are you sure?", subTitle: "A cancelled request will not go through to paramedics", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Go back", animationStyle: SCLAnimationStyle.topToBottom)
    }
    
    @objc func locationPressed(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "viewLocationViewController") as! viewLocationViewController
        vc.latitude = Double(assignedRequest.getLatitude())
        vc.longitude = Double(assignedRequest.getLongitude())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
        
        

}
