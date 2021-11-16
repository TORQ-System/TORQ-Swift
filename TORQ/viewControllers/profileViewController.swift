//
//  profileViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit

class profileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func editAccountPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "editAccountViewController") as! editAccountViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        

    }
    
    @IBAction func changePasswordPressed(_ sender: Any) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "changePasswordViewController") as! changePasswordViewController
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
    }
    
}
