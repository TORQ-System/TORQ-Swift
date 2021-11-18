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
        profileContainer.layer.cornerRadius = profileContainer.layer.frame.width/2
        profileContainer.layer.masksToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = profileContainer.frame
        gradientLayer.colors = [
            UIColor(red: 0.102, green: 0.157, blue: 0.345, alpha: 1).cgColor,
            UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor
          ]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0.98, c: -0.75, d: 1.6, tx: 0.38, ty: -0.77))
        gradientLayer.bounds = profileContainer.bounds.insetBy(dx: -0.5*profileContainer.bounds.size.width, dy: -0.5*profileContainer.bounds.size.height)
        gradientLayer.position = profileContainer.center
        profileContainer.layer.addSublayer(gradientLayer)
        profileContainer.layer.insertSublayer(gradientLayer, at: 0)
        
        //3- user Name label
        patientName.text = sosRequestName
        
        //4- occured at label
        requestTime.text = "Occured at: \(String(describing: sosRequestTime!))"
        
        //5- chat button
        chatButton.layer.cornerRadius = 10
        chatButton.layer.masksToBounds = true
        chatButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.1)
        chatButton.tintColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        chatButton.setTitleColor(UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1), for: .normal)
        
        //6- process button
        processButton.layer.cornerRadius = 10
        processButton.layer.masksToBounds = true
        processButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.1)
        processButton.tintColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        processButton.setTitleColor(UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1), for: .normal)
        
        //7- directions button
        directionsButton.layer.cornerRadius = 10
        directionsButton.layer.masksToBounds = true
        directionsButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.1)
        directionsButton.tintColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        directionsButton.setTitleColor(UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1), for: .normal)
        
        //8- Medical Report button
        medicalReportButton.setTitleColor(UIColor(red: 0.788, green: 0.271, blue: 0.341, alpha: 1), for: .normal)
        
        //9- Report Deatils button
        requestDetailsButton.setTitleColor(UIColor(red: 0.788, green: 0.271, blue: 0.341, alpha: 1), for: .normal)

        
        //10- stack view
        
        //11- container view
        
        
    }
    
    private func fetchMedicalReports(){
        
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - extension
