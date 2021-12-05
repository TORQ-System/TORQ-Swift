//
//  paramedicChatViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 05/12/2021.
//

import UIKit

class paramedicChatViewController: UIViewController {

    
    //MARK: - @IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    //MARK: - Variables
    
    //MARK: - Overriden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

    }
    
    //MARK: - Functions
    private func setupLayout(){
        //1- background view
        containerView.layer.cornerRadius = 50
        containerView.layer.masksToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.frame
        gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.96, b: 0.95, c: -0.95, d: -1.56, tx: 1.43, ty: 0.83))
        gradientLayer.bounds = containerView.bounds.insetBy(dx: -0.5*containerView.bounds.size.width, dy: -0.5*containerView.bounds.size.height)
        gradientLayer.position = containerView.center
        containerView.layer.addSublayer(gradientLayer)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: - @IBActions
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extension
