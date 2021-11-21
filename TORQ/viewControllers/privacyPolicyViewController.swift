//
//  privacyPolicyViewController.swift
//  TORQ
//
//  Created by a w on 18/11/2021.
//

import UIKit
import Firebase
import FirebaseDatabase

class privacyPolicyViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var bodyLabel : UILabel!
    
    //MARK: - Variables
    // DB reference
    var ref = Database.database().reference()
    var bodyText : String?
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchInfo()
    }
    
    //MARK: - Functions
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func fetchInfo(){
        ref.child("PrivacyPolicy").observeSingleEvent(of: .value, with: { snapshot in
            for terms in snapshot.children{
                let obj = terms as! DataSnapshot
                let body = obj.childSnapshot(forPath: "body").value as! String
                self.bodyText = body
                DispatchQueue.main.async{
                    self.bodyLabel.text = self.bodyText
                }
            }
        })
    }

}
