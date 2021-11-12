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
    var services = ["Terms and conditions","Settings","Edit Account","Sensor Information","Change passowrd","Logout"]
    var servicesImages = ["terms and conditions","settings","edit account","sensor information","change password","logout"]
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
            print("before retrieve call")
            retreieveUser()
            print("after retrieve call")
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
                    let joinedDate = obj.childSnapshot(forPath: "joined_at").value as! String
                    let dateOfBirth = obj.childSnapshot(forPath: "dateOfBirth").value as! String
                    let email = obj.childSnapshot(forPath: "email").value as! String
                    let fullName = obj.childSnapshot(forPath: "fullName").value as! String
                    let gender = obj.childSnapshot(forPath: "gender").value as! String
                    let nationalID = obj.childSnapshot(forPath: "nationalID").value as! String
                    let password = obj.childSnapshot(forPath: "password").value as! String
                    let phone = obj.childSnapshot(forPath:  "phone").value as! String
                    print(obj.key)
                    if obj.key == self.userID {
                        print("inside loop")
                        self.user = User(dateOfBirth: dateOfBirth,          email: email, fullName: fullName, gender:        gender, nationalID: nationalID, password:      password, phone: phone)
                        let date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        print(dateFormatter.string(from: date))
                        print("________________________________________________________________________________")
                        DispatchQueue.main.async {
                            //update UI here
                            self.userName.text = fullName
                            self.userEmail.text = email
                            self.joinedLabel.text = "Joined \(joinedDate) ago"
                        }
                    }
                    print("after loop")
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
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vc = UIViewController()
//        vc.presentationStyle = .fullScreen
        switch indexPath.row {
        case 0:
            //terms and conditions
            //let TermsVC = storyboard.instantiateViewController(identifier: "termsAndConditionsViewController") as! termsAndConditionsViewController
            //vc = TermsVC
            break
        case 1:
            //settings
            //let settingsVC = storyboard.instantiateViewController(identifier: "settingsViewController") as! settingsViewController
            //vc = settingsVC
            break
        case 2:
            //edit Account
            //let editVC = storyboard.instantiateViewController(identifier: "editAccountViewController") as! editAccountViewController
            //vc = editVC
            break
        case 3:
            //sensor Information
            //let sensorVC = storyboard.instantiateViewController(identifier: "SensorViewController") as! SensorViewController
            //vc = sensorVC
            break
        case 4:
            //change password
            //let changePassVC = storyboard.instantiateViewController(identifier: "changePasswordViewController") as! changePasswordViewController
            //vc = changePassVC
            break
        case 5:
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
//        self.present(vc, animated: true, completion: nil)
    }
    
}

