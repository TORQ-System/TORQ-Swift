//
//  notificationCenterViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit
import Firebase

class notificationCenterViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var notificationCollectionView: UICollectionView!
    @IBOutlet weak var noNotificationsView: UIStackView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var userID: String? = Auth.auth().currentUser?.uid
    var allNotifications: [notification] = []
    var emergencyNotifications: [notification] = []
    var wellbeingNotifications: [notification] = []
    var all = true
    var emergency = false
    var wellbeing = false
    
    //MARK: - Constants
    let filterBy = ["All", "From Contacts", "From TORQ"]
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indexPath = IndexPath(row: 0, section: 0)
        filterCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        getNotifications()
        configureGradient()
        
    }
    
    //MARK: - Functions
    func configureGradient() {
        backgroundView.layer.cornerRadius = 40
        backgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundView.layer.shouldRasterize = true
        backgroundView.layer.rasterizationScale = UIScreen.main.scale
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [
            UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = backgroundView.layer.frame
        
        backgroundView.layer.insertSublayer(gradient, at: 0)
        
    }
    
    func getNotifications() {
        let notificationsQueue = DispatchQueue.init(label: "notificationsQueue")
        notificationsQueue.sync {
            ref.child("Notification").observe(.value) { snapshot in
                self.allNotifications = []
                self.emergencyNotifications = []
                self.wellbeingNotifications = []
                for notif in snapshot.children{
                    let obj = notif as! DataSnapshot
                    let body = obj.childSnapshot(forPath: "body").value as! String
                    let date = obj.childSnapshot(forPath: "date").value as! String
                    let receiver = obj.childSnapshot(forPath: "receiver").value as! String
                    let sender = obj.childSnapshot(forPath: "sender").value as! String
                    let subtitle = obj.childSnapshot(forPath: "subtitle").value as! String
                    let time = obj.childSnapshot(forPath: "time").value as! String
                    let title = obj.childSnapshot(forPath: "title").value as! String
                    let type = obj.childSnapshot(forPath:  "type").value as! String
                    
                    let alert = notification(title: title, subtitle: subtitle, body:body, date: date, time: time, type: type, sender: sender, receiver: receiver)
                    
                    if (alert.getReceiver() == Auth.auth().currentUser?.uid){
                        
                        self.allNotifications.append(alert)
                        
                        switch alert.getType() {
                        case "emergency":
                            self.emergencyNotifications.append(alert)
                            break
                        case "wellbeing":
                            self.wellbeingNotifications.append(alert)
                            break
                        default:
                            print("unknown status")
                        }
                    }
                }
                self.notificationCollectionView.reloadData()
            }
        }
    }
}

//MARK: - Extensions
extension notificationCenterViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == filterCollectionView else{
            return
        }
        
        all = false; wellbeing = false; emergency = false
        
        switch indexPath.row {
        case 0:
            all = true
            notificationCollectionView.reloadData()
            break
        case 1:
            emergency = true
            notificationCollectionView.reloadData()
            break
        case 2:
            wellbeing = true
            notificationCollectionView.reloadData()
            break
        default:
            notificationCollectionView.reloadData()
        }
    }
}

extension notificationCenterViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView == filterCollectionView else{
            var count: Int = 4
            
            if all{
                count = allNotifications.count
            } else if wellbeing {
                count = wellbeingNotifications.count
            } else if emergency {
                count = emergencyNotifications.count
            }
            
            noNotificationsView.alpha = count == 0 ? 1.0 : 0.0
            
            return count
        }
        return filterBy.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard collectionView == filterCollectionView else{
            let notificationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "notificationCell", for: indexPath) as! notificationCollectionViewCell
            
            notificationCell.configureCellView()
            
            let notifications: [notification]
            
            if all {
                notifications = allNotifications
            } else if emergency {
                notifications = emergencyNotifications
            } else{
                notifications = wellbeingNotifications
            }
            
            notificationCell.title.text = notifications[indexPath.row].getTitle()
            notificationCell.details.text = notifications[indexPath.row].getBody()
            notificationCell.time.text = notifications[indexPath.row].getTime()
            notificationCell.date.text = notifications[indexPath.row].getDate()
            
            return notificationCell
        }
        
        let colors = [UIColor(red: 21.0/255.0, green: 143.0/255.0, blue: 211.0/255.0, alpha: 0.65),
                      UIColor(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 0.7),
                      UIColor(red: 106.0/255.0, green: 61.0/255.0, blue: 142.0/255.0, alpha: 0.7)]
        
        let backgroundView = UIView()
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! filterCollectionViewCell
        var color = colors[0]
        
        filterCell.layer.cornerRadius = 15
        filterCell.layer.masksToBounds = true
        filterCell.filterLabel.text = filterBy[indexPath.row]
        
        switch indexPath.row {
        case 0:
            color = colors[0]
            break
        case 1:
            color = colors[1]
            break
        case 2:
            color = colors[2]
            break
        default:
            color = .yellow
        }
        
        backgroundView.backgroundColor = color.withAlphaComponent(0.95)
        filterCell.backgroundColor = color
        filterCell.selectedBackgroundView = backgroundView
        
        return filterCell
    }
}

extension notificationCenterViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView == filterCollectionView else{
            return CGSize(width: collectionView.frame.width/1.1, height: 160)
        }
        return CGSize(width: filterBy[indexPath.item].size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]).width+25, height: 30)
    }
}

extension UICollectionViewCell {
    func configureCellView() {
        let radius: CGFloat = 25
        contentView.layer.cornerRadius = radius
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 25
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}
