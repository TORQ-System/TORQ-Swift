//
//  viewSOSRequestDetailsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 18/11/2021.
//

import UIKit
import Firebase

class viewSOSRequestDetailsViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var requestTime: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var medicalReportButton: UIButton!
    @IBOutlet weak var requestDetailsButton: UIButton!
    
    
    //MARK: - Variables
    var sosRequester: String?
    var sosRequestTime: String?
    var sosRequestName: String?
    var sosRequestAge: String?

    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()

    }
    
    //MARK: - functions
    private func layoutViews(){
        
        //1- back button
        backButton.backgroundColor = UIColor(red: 0.784, green: 0.267, blue: 0.337, alpha: 0.17)
        backButton.layer.cornerRadius = 10
        backButton.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
        //2- profile container
        
        //3- chat button
        
        //4- process button
        
        //5- directions button
        
        //6- Medical Report button
        
        //7- Report Deatils button
        
        //8- stack view
        
        //9- container view
        
        
    }
    
    private func fetchMedicalReports(){
        
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - extension
