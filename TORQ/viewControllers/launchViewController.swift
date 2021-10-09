//
//  launchViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 09/10/2021.
//

import UIKit

class launchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func goToLogin(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "onboardingScreen1") as! onboardingScreen1ViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}
