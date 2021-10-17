//
//  ViewEmergencyContactViewController.swift
//  TORQ
//
//  Created by Norua Alsalem on 17/10/2021.
//

import UIKit
import FirebaseDatabase

class ViewEmergencyContactViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var contacts: UICollectionView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var EmergencyContacts: [emergencyContact] = []
    var userEmail: String?
    var userID: String?
    var myRequests: [emergencyContact] = []
    
    //MARK: - Overriden function
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
