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
    var userID: String?
    var all: [notification] = []
    var notifications: [notification] = []
    
    //MARK: - Constants
    let filterBy = ["All", "From Contacts", "From TORQ"]
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNotifications(userID: userID!)
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
            UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = backgroundView.layer.frame
        
        backgroundView.layer.insertSublayer(gradient, at: 0)
        
    }
    
    func getNotifications(userID: String) {
        notifications.removeAll()
        all.removeAll()
        
        ref.child("Notification").observe(.childAdded) {snapshot in
            let obj = snapshot.value as! [String: Any]
            let title = obj["title"] as! String
            let subtitle = obj["subtitle"] as! String
            let body = obj["body"] as! String
            let type = obj["type"] as! String
            let date = obj["date"] as! String
            let sender = obj["sender"] as! String
            let receiver = obj["receiver"] as! String
            let time = obj["time"] as! String
            
            let alert = notification(title: title, subtitle: subtitle, body:body, date: date, time: time, type: type, sender: sender, receiver: receiver)
            
            if alert.getReceiver() == userID {
                self.notifications.append(alert)
                self.all.append(alert)
                self.notificationCollectionView.reloadData()
            }
        }
    }
    
    func classifyNotifications(userID: String, type: String) {
        notifications.removeAll()
        for (_, alert) in all.enumerated(){
            if(alert.getType() == type){
                notifications.append(alert)
            }
        }
        self.notificationCollectionView.reloadData()
    }
}

extension notificationCenterViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == filterCollectionView else{
            return
        }
        switch indexPath.row {
        case 0:
            getNotifications(userID: userID!)
            break
        case 1:
            classifyNotifications(userID: userID!, type: "emergency")
            break
        case 2:
            classifyNotifications(userID: userID!, type: "wellbeing")
            break
        default:
            getNotifications(userID: userID!)
        }
    }
}

extension notificationCenterViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView == filterCollectionView else{
            noNotificationsView.alpha = notifications.count == 0 ? 1.0 : 0.0
            return notifications.count
        }
        return filterBy.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colors = [UIColor(red: 0.314, green: 0.663, blue: 0.859, alpha: 1),
                      UIColor.gray,
                      UIColor(red: 0.133, green: 0.192, blue: 0.404, alpha: 0.63)]
        
        guard collectionView == filterCollectionView else{
            let notificationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "notificationCell", for: indexPath) as! notificationCollectionViewCell
            notificationCell.configureCellView()
            
            notificationCell.title.text = notifications[indexPath.row].getTitle()
            notificationCell.details.text = notifications[indexPath.row].getBody()
            notificationCell.time.text = notifications[indexPath.row].getTime()
            notificationCell.date.text = notifications[indexPath.row].getDate()
            
            return notificationCell
        }
        
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! filterCollectionViewCell
        
        filterCell.layer.cornerRadius = 15
        filterCell.layer.masksToBounds = true
        filterCell.filterLabel.text = filterBy[indexPath.row]
        
        switch indexPath.row {
        case 0:
            filterCell.backgroundColor = colors[0]
        case 1:
            filterCell.backgroundColor = colors[1]
        case 2:
            filterCell.backgroundColor = colors[2]
        default:
            filterCell.backgroundColor = .yellow
        }
        
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


