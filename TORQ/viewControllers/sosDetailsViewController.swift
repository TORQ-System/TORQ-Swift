//
//  sosDetailsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 06/11/2021.
//

import UIKit
import Firebase
import SCLAlertView

class sosDetailsViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var customerService: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var liveLocation: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var check1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var check2: UIImageView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var check3: UIImageView!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var circle4: UIView!
    @IBOutlet weak var check4: UIImageView!
    @IBOutlet weak var label4: UILabel!
    
    
    
    //MARK: - Variables
    var SOSRequest: SOSRequest?
    var userID = Auth.auth().currentUser?.uid
    var ref = Database.database().reference()
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    
    
    //MARK: - Overriden Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()

    }
    
    
    //MARK: - Functions
    private func setLayout(){
        //1- background view
        backgroundView.layer.cornerRadius = 50
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundView.frame
        gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.96, b: 0.95, c: -0.95, d: -1.56, tx: 1.43, ty: 0.83))
        gradientLayer.bounds = backgroundView.bounds.insetBy(dx: -0.5*backgroundView.bounds.size.width, dy: -0.5*backgroundView.bounds.size.height)
        gradientLayer.position = backgroundView.center
        backgroundView.layer.addSublayer(gradientLayer)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        //2- customer service button
        customerService.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        customerService.layer.cornerRadius = customerService.layer.frame.width/2
        customerService.layer.masksToBounds = true
        
        //3- cancel button
        cancel.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        cancel.layer.cornerRadius = cancel.layer.frame.width/2
        cancel.layer.masksToBounds = true


        //4- live location button
        liveLocation.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        liveLocation.layer.cornerRadius = liveLocation.layer.frame.width/2
        liveLocation.layer.masksToBounds = true
        
        //5- circle one
        circle1.layer.cornerRadius = circle2.layer.frame.width/2
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            UIView.animate(withDuration: 1) {
                self.check1.alpha = 1.0
                self.circle1.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                self.label1.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            }
        }
        
        //6- circle two
        circle2.layer.cornerRadius = circle2.layer.frame.width/2
        label2.text = "Your request has been assigned to \(SOSRequest!.getAssignedCenter()) SRCA  center"
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            UIView.animate(withDuration: 1) {
                self.check2.alpha = 1.0
                self.circle2.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                self.label2.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            }
        }
        
        
        //7- circle three
        circle3.layer.cornerRadius = circle2.layer.frame.width/2
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            UIView.animate(withDuration: 1) {
                self.check3.alpha = 1.0
                self.circle3.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                self.label3.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            }
        }
        
        //8- circle four
        circle4.layer.cornerRadius = circle4.layer.frame.width/2
        checkProcessedStatus()
        
        
        
    }
    
    private func checkProcessedStatus(){
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            self.ref.child("SOSRequests").observe(.value) { snapshot in
                for req in snapshot.children{
                    let obj = req as! DataSnapshot
                    let status = obj.childSnapshot(forPath: "status").value as! String
                    if status == "Processed" {
                        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                            UIView.animate(withDuration: 1) {
                                self.check4.alpha = 1.0
                                self.circle4.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                                self.label4.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                            }
                            self.dismiss(animated: true, completion: nil)
                        }
                    }

            }
            print("out of ref")
        }
        
        }
    }
    
    private func updateSOSRequestsStatus(update: String){
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            self.ref.child("SOSRequests").observeSingleEvent(of: .value, with: { snapshot in
                for requests in snapshot.children{
                    let obj = requests as! DataSnapshot
                    let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                    let status = obj.childSnapshot(forPath: "status").value as! String
                    if user_id == self.userID && status == "1" {
                        self.ref.child("SOSRequests").child(obj.key).updateChildValues(["status":update])
                    }
                }
            })
            print("out of ref")
        }
    }
    
    
    //MARK: - @IBActions
    @IBAction func goChat(_ sender: Any) {
        
    }
    
    @IBAction func cancelSOSrequest(_ sender: Any) {
        let alertView = SCLAlertView(appearance: self.apperance)
        alertView.addButton("Yes, I'm sure", backgroundColor: self.redUIColor){
            // update status to cancel
            self.updateSOSRequestsStatus(update: "cancelled")
            self.dismiss(animated: true, completion: nil)
        }
        alertView.showCustom("Warning", subTitle: "Once you confirm the cancellation your SOS Request will be canceled, Are you sure ?", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Cancel", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
    }
    
    @IBAction func seeLiveLocation(_ sender: Any) {
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
