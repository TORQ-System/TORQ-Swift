//
//  profileViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit
import Firebase

class profileViewController: UIViewController {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var strokeView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Variables
    var userID: String?
    let ref = Database.database().reference()
    var user: User?
    var services = ["Terms and conditions","Settings","Edit Account","Sensor Information","Change passowrd","Logout"]
    var servicesImages = ["list.bullet.rectangle","list.bullet.rectangle","list.bullet.rectangle","list.bullet.rectangle","list.bullet.rectangle","list.bullet.rectangle"]
    
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            retreieveUser()
        }
        tableView.backgroundColor = .lightGray
        
        
        

    }
    
    
    //MARK: - Functions
    private func retreieveUser(){
            ref.child("User").observe(.value) { snapshot in
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                    let email = obj.childSnapshot(forPath: "email").value as! String
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    let gender = obj.childSnapshot(forPath: "gender").value as! String
                    let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                    let password = obj.childSnapshot(forPath: "password").value as! String
                    let phone = obj.childSnapshot(forPath:  "phone").value as! String
                    if obj.key == self.userID {
                        self.user = User(dateOfBirth: dateOfBirth,          email: email, fullName: fullName, gender:        gender, nationalID: nationalID, password:      password, phone: phone)
                        DispatchQueue.main.async {
                            //update UI here
                            self.userName.text = fullName
                            self.userEmail.text = email
                            self.joinedLabel.text = "Joined 8 months ago"
                        }
                    }
                }
            }
    }
}

//MARK: - Extension

extension profileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! profileTableViewCell
        cell.serviceLabel.text = services[indexPath.row]
        cell.serviceImage.image = UIImage(systemName: servicesImages[indexPath.row])
        return cell
    }
    
    
}
