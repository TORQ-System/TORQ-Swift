//
//  notificationCenterViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit
import Firebase
import SwipeCellKit

class notificationCenterViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var notificationCollectionView: UITableView!
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
    var usesTallCells = true
    
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
        backgroundView.layer.cornerRadius = 80
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
        _ = notificationsQueue.sync { ref.child("Notification").observe(.value) { snapshot in
            self.allNotifications = []
            self.emergencyNotifications = []
            self.wellbeingNotifications = []
            for notif in snapshot.children{
                let obj = notif as! DataSnapshot
                let body = obj.childSnapshot(forPath: "body").value as! String
                let date = obj.childSnapshot(forPath: "date").value as! String
                let receiver = obj.childSnapshot(forPath: "receiver").value as! String
                let request_id = obj.childSnapshot(forPath:  "request_id").value as! String
                let sender = obj.childSnapshot(forPath: "sender").value as! String
                let subtitle = obj.childSnapshot(forPath: "subtitle").value as! String
                let time = obj.childSnapshot(forPath: "time").value as! String
                let title = obj.childSnapshot(forPath: "title").value as! String
                let type = obj.childSnapshot(forPath:  "type").value as! String
                
                let alert = notification(title: title, subtitle: subtitle, body:body, date: date, time: time, type: type, sender: sender, receiver: receiver, request_id: request_id, notification_id: obj.key)
                
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
            
            self.allNotifications.reverse()
            self.emergencyNotifications.reverse()
            self.wellbeingNotifications.reverse()
            self.notificationCollectionView.reloadData()
        }
        }
    }
    
    @objc func viewDetails(_ sender: ViewNotificationTapGesture) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "notificationDetailsViewController") as! notificationDetailsViewController
        vc.notificationDetails = sender.notificationDetails
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Extensions
extension notificationCenterViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var notifications: [notification]
        if self.all {
            notifications = self.allNotifications
        } else if self.emergency {
            notifications = self.emergencyNotifications
        } else{
            notifications = self.wellbeingNotifications
        }
        
        let delete = UIContextualAction(style: .destructive, title: "Delete notification") { (action, sourceView, completionHandler) in
            print(notifications[indexPath.row].getNotificationID())
            self.ref.child("Notification").child(notifications[indexPath.row].getNotificationID()).removeValue()
            completionHandler(true)
        }
        
        let deleteActionImage = UIImage(named: "deleteCircle")
        delete.image = deleteActionImage
        delete.backgroundColor = UIColor.white.withAlphaComponent(0)
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = true
        
        return swipeActionConfig
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "notificationDetailsViewController") as! notificationDetailsViewController
        let notifications: [notification]
        
        if all {
            notifications = allNotifications
        } else if emergency {
            notifications = emergencyNotifications
        } else{
            notifications = wellbeingNotifications
        }
        
        vc.notificationDetails = notifications[indexPath.row]
        print(notifications[indexPath.row].getNotificationID())
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension notificationCenterViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

extension notificationCenterViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationCell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! notificationTableViewCell
        
        notificationCell.configureCellView()
        notificationCell.configureButton()
        
        var notifications: [notification]
        
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
        
        let viewDetails = ViewNotificationTapGesture(target: self, action: #selector(self.viewDetails(_:)))
        viewDetails.notificationDetails = notifications[indexPath.row]
        notificationCell.button.addGestureRecognizer(viewDetails)
        notificationCell.button.isUserInteractionEnabled = true
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0)
        notificationCell.selectedBackgroundView = backgroundView
        
        return notificationCell
        
    }
}
extension notificationCenterViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterBy.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colors = [UIColor(red: 49.0/255.0, green: 90.0/255.0, blue: 149.0/255.0, alpha: 1.0),
                      UIColor(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 0.75),]
        
        let backgroundView = UIView()
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! filterCollectionViewCell
        
        filterCell.layer.cornerRadius = 15
        filterCell.layer.masksToBounds = true
        filterCell.filterLabel.text = filterBy[indexPath.row]
        filterCell.backgroundColor = colors[1]
        
        backgroundView.backgroundColor = colors[0].withAlphaComponent(1)
        filterCell.selectedBackgroundView = backgroundView
        
        return filterCell
    }
    
}

extension notificationCenterViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: filterBy[indexPath.item].size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]).width+25, height: 30)
    }
}

//MARK: - Classes
class ViewNotificationTapGesture: UITapGestureRecognizer {
    var notificationDetails: notification?
}

