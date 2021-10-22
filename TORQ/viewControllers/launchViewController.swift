//
//  launchViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 09/10/2021.
//

import UIKit

class launchViewController: UIViewController {
    
    
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.goToLogin()
        }
    }

    //MARK: - Functions
    func goToLogin() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "onboardingScreen1") as! onboardingScreen1ViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}
