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

    }
    
    //MARK: - @IBActions
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extension
