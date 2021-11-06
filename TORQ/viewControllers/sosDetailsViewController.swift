//
//  sosDetailsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 06/11/2021.
//

import UIKit

class sosDetailsViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var customerService: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var liveLocation: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    
    
    //MARK: - Variables
    var SOSRequest: SOSRequest?
    
    
    //MARK: - Overriden Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()

    }
    
    
    //MARK: - Functions
    private func setLayout(){
        //1- background view
        backgroundView.layer.cornerRadius = 50
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

    }
    
    
    //MARK: - @IBActions
    @IBAction func goChat(_ sender: Any) {
        
    }
    
    @IBAction func cancelSOSrequest(_ sender: Any) {
        
    }
    
    @IBAction func seeLiveLocation(_ sender: Any) {
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
