//
//  viewMedicalReportViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 27/10/2021.
//

import UIKit

class viewMedicalReportViewController: UIViewController {
    
    
    //MARK: - @IBOutlts
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var addMedicalReport: UIButton!
    @IBOutlet weak var deleteMedicalReport: UIButton!
    
    
    //MARK: - Variables
    var userID: String?
    
    
    //MARK: - Overriden Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()

    }
    
    
    //MARK: - Functions
    private func configureLayout(){
        profileView.layer.cornerRadius = 60
        profileView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 80
        cardView.layer.masksToBounds = true
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
    }
    
}

//MARK: - Extensions
