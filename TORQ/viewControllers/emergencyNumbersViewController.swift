//
//  emergencyNumbersViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 10/12/2021.
//

import UIKit
import Firebase

class emergencyNumbersViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var emergencyNumbers: UITableView!
    
    //MARK: - Variables
    var userID = Auth.auth().currentUser?.uid
    var ref = Database.database().reference()
    var emergencyNumbersArray : [emergencyNumber] = []
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getEmergencyNumbers()
        setView()
    }
    
    //MARK: - Functions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getEmergencyNumbers(){
        let searchQueue = DispatchQueue.init(label: "searchQueue")
        
        searchQueue.sync {
            
            ref.child("EmergencyNumbers").observe(.value) { snapshot in
                self.emergencyNumbersArray = []
                for numbers in snapshot.children{
                    let obj = numbers as! DataSnapshot
                    let name = obj.childSnapshot(forPath: "name").value as! String
                    let phone = obj.childSnapshot(forPath: "phone").value as! String
                    
                    let en = emergencyNumber(name:name, phone:phone)
                    
                    self.emergencyNumbersArray.append(en)
                    self.emergencyNumbers.reloadData()
                                
                    }
                }
            
            self.emergencyNumbers.reloadData()
             
            }
            
        }
    
    func setView() {
        //background view
         background.layer.cornerRadius = 50
         background.layer.masksToBounds = true
         background.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
         let gradientLayer = CAGradientLayer()
         gradientLayer.frame = background.frame
         gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
         gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
         gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
         gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.96, b: 0.95, c: -0.95, d: -1.56, tx: 1.43, ty: 0.83))
         gradientLayer.bounds = background.bounds.insetBy(dx: -0.5*background.bounds.size.width, dy: -0.5*background.bounds.size.height)
         gradientLayer.position = background.center
         background.layer.addSublayer(gradientLayer)
         background.layer.insertSublayer(gradientLayer, at: 0)
         // table view style
//         emergencyNumbers.layer.cornerRadius = 15
         emergencyNumbers.separatorStyle = .none
         emergencyNumbers.showsVerticalScrollIndicator = false
    }
}
//MARK: - UITableViewDelegate
extension emergencyNumbersViewController : UITableViewDelegate {

}
extension emergencyNumbersViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emergencyNumbersArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = emergencyNumbers.dequeueReusableCell(withIdentifier: "emergencyNumberCell") as! emergencyNumberTableViewCell
        
        cell.nameLabel.text = emergencyNumbersArray[indexPath.row].getName()
        cell.phoneLabel.text = emergencyNumbersArray[indexPath.row].getPhone()
        
        // cell style
        cell.layer.cornerRadius = 20
        cell.clipsToBounds = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? emergencyNumberTableViewCell else { return }
        
        guard let url = URL(string: "tel://\(cell.phoneLabel.text!)"),
                UIApplication.shared.canOpenURL(url) else {
                return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        
    }
    
}
