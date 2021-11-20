//  profileViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit
import Firebase
import SCLAlertView


class profileViewController: UIViewController {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var strokeView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Variables
    var userID = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    var user: User?
    var services = ["Terms and conditions","Privacy and Policies","Edit Account","Change passowrd","Logout"]
    var servicesImages = ["terms","privacy","edit account","change password","logout"]
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            retreieveUser()
        }
                
        strokeView.layer.cornerRadius = 85
        strokeView.layer.masksToBounds = true
        strokeView.backgroundColor = .clear
        strokeView.layer.borderWidth = 1
        strokeView.layer.borderColor = UIColor(red: 0.83921569, green: 0.33333333, blue: 0.42352941, alpha: 1).cgColor
        
        imageContainer.layer.cornerRadius = 75
        imageContainer.layer.masksToBounds = true
        imageContainer.backgroundColor = UIColor(red: 0.83921569, green: 0.33333333, blue: 0.42352941, alpha: 1)
        
        
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
    }
    
    
    //MARK: - Functions
    private func retreieveUser(){
            ref.child("User").observe(.value) { snapshot in
                for user in snapshot.children{
                    let obj = user as! DataSnapshot
                    let phone = obj.childSnapshot(forPath: "phone").value as! String
                    let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                    let email = obj.childSnapshot(forPath: "email").value as! String
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    let gender = obj.childSnapshot(forPath: "gender").value as! String
                    let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                    let password = obj.childSnapshot(forPath: "password").value as! String
                    if obj.key == self.userID {
                        self.user = User(dateOfBirth: dateOfBirth,          email: email, fullName: fullName, gender:        gender, nationalID: nationalID, password:      password, phone: phone)
                        
                        DispatchQueue.main.async {
                            //update UI here
                            self.userName.text = fullName
                            self.userEmail.text = email
                            
                            //get the day
                            let date = Auth.auth().currentUser!.metadata.creationDate!
                            let difference = Calendar.current.dateComponents([.month], from: date, to: Date()).month
                            if difference == 0{
                                let differenceD = Calendar.current.dateComponents([.day], from: date, to: Date()).day
                                if differenceD == 0 {
                                    self.joinedLabel.text = "Joined today"
                                }else{
                                    self.joinedLabel.text = "Joined \(differenceD!) days ago"
                                }
                            }else{
                                if difference! > 11{
                                    self.joinedLabel.text = "Joined \(difference! / 12) yaers ago"
                                }else{
                                    self.joinedLabel.text = "Joined \(difference!) months ago"
                                }
                            }
                            
                        }
                    }
                }
            }
    }
    
    func goToLoginScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! loginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func showAlert(message: String){
        SCLAlertView(appearance: self.apperance).showCustom("Error", subTitle: message, color: self.redUIColor, icon: alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
    }
}

//MARK: - UITableViewDataSource Extension

extension profileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! profileTableViewCell
        cell.serviceLabel.text = services[indexPath.row]
        cell.serviceImage.image = UIImage(named: servicesImages[indexPath.row])
        return cell
    }

}


//MARK: - UITableViewDataSource Extension

extension profileViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        var vc = UIViewController()
        switch indexPath.row {
        case 0:
            //terms and conditions
            let TermsVC = storyboard.instantiateViewController(identifier: "termsAndConditionsViewController") as! termsAndConditionsViewController
            vc = TermsVC
            break
        case 1:
            //plicies and privacy
            let PrivacyVC = storyboard.instantiateViewController(identifier: "privacyPolicyViewController") as! privacyPolicyViewController
            vc = PrivacyVC
            break
        case 2:
            //edit Account
            let editVC = storyboard.instantiateViewController(identifier: "editAccountViewController") as! editAccountViewController
            vc = editVC
            break
        case 3:
            //change password
            let changePassVC = storyboard.instantiateViewController(identifier: "changePasswordViewController") as! changePasswordViewController
            vc = changePassVC
            break
        case 4:
            //logout
            do {
                try Auth.auth().signOut()
                let userDefault = UserDefaults.standard
                userDefault.setValue(false, forKey: "isUserSignedIn")
                goToLoginScreen()
            } catch let error {
                self.showAlert(message: error.localizedDescription)
            }
            break
        default:
            print("unknown")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}

