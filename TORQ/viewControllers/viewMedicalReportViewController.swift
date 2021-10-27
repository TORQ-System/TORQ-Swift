//
//  viewMedicalReportViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 27/10/2021.
//

import UIKit
import FirebaseDatabase
import SCLAlertView

class viewMedicalReportViewController: UIViewController {
    
    
    //MARK: - @IBOutlts
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var addMedicalReport: UIButton!
    @IBOutlet weak var deleteMedicalReport: UIButton!
    
    //MARK: - Variables
    var userID: String?
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    let ref = Database.database().reference()
    
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        
    }
    
    
    //MARK: - Functions
    private func configureLayout(){
        profileView.layer.cornerRadius = 40
        profileView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 30
        cardView.layer.masksToBounds = true
        addMedicalReport.layer.cornerRadius = 35
        addMedicalReport.layer.masksToBounds = true
        deleteMedicalReport.layer.cornerRadius = 35
        deleteMedicalReport.layer.masksToBounds = true
    }
    
    
    //MARK: - @IBActions
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addMedicalReport(_ sender: Any) {
        //        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        //        let addVC = storyboard.instantiateViewController(identifier: "addMedicalReportViewController") as! addMedicalReportViewController
        //        addVC.userID = userID
        //        self.present(addVC, animated: true, completion: nil)
    }
    
    @IBAction func deleteMedicalReport(_ sender: Any) {
        // Shahad's code goes here
        let alertView = SCLAlertView(appearance: self.apperance)
        
        alertView.addButton("Delete", backgroundColor: self.redUIColor){
            self.ref.child("medical_info").queryOrdered(byChild:"user_id").observe(.childAdded, with: {(snapshot) in
                if let dec = snapshot.value as? [String :Any]
                {
                    if (dec["user_id"] as! String == self.userID!){
                        self.ref.child("medical_info").child(snapshot.key).removeValue()
                        self.dismiss(animated: true, completion: nil)

                    }
                }
            })
        }
        
        alertView.showCustom("Are you sure?", subTitle: "We will delete your entire medical report", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Cancel", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
        
       
        
        //
        //    ref.child("EmergencyContact").queryOrdered(byChild:"reciver").observe(.childAdded, with: {(snapshot) in
        //        if let dec = snapshot.value as? [String :Any]
        //        {
        //            if (dec["reciver"] as! String == self.userID!){
        //                self.ref.child("EmergencyContact").child(snapshot.key).removeValue()
        //            }
        //        }
        //    })
        
        
    }
}

//MARK: - Extensions
