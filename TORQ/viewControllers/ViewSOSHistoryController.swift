//
//  ViewSOSHistoryController.swift
//  TORQ
//
//  Created by  Lama Alshahrani on 20/04/1443 AH.
//

import UIKit
import FirebaseDatabase

class ViewSOSHistoryController: UIViewController {

    @IBOutlet weak var noSos: UILabel!
    @IBOutlet weak var collectionViewSOS: UICollectionView!
    @IBOutlet weak var BackgroundView: UIView!
    
    var requests: [SOSRequest] = []
    var ref = Database.database().reference()
    var userID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        background()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    func background() {
        //background view
        BackgroundView.layer.cornerRadius = 50
        BackgroundView.layer.masksToBounds = true
        BackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
         let gradientLayer = CAGradientLayer()
         gradientLayer.frame = BackgroundView.frame
         gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
         gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
         gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
         gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.96, b: 0.95, c: -0.95, d: -1.56, tx: 1.43, ty: 0.83))
         gradientLayer.bounds = BackgroundView.bounds.insetBy(dx: -0.5*BackgroundView.bounds.size.width, dy: -0.5*BackgroundView.bounds.size.height)
         gradientLayer.position = BackgroundView.center
        BackgroundView.layer.addSublayer(gradientLayer)
        BackgroundView.layer.insertSublayer(gradientLayer, at: 0)
         // add corner radius to the clooection view as a whole
        // accidents.layer.cornerRadius = 15
    }
    func getRequests(){
      
       
        ref.child("SOSRequests").observe(.value) { snapshot in
            for contact in snapshot.children{
             //   print("enter")

                let obj = contact as! DataSnapshot
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                let time_stamp = obj.childSnapshot(forPath: "timeDate").value as! String
                let lonitude = obj.childSnapshot(forPath: "longitude").value as! String
                let latitude = obj.childSnapshot(forPath: "latitude").value as! String
                let center = obj.childSnapshot(forPath: "latitude").value as! String
                let sent = obj.childSnapshot(forPath: "sent").value as! String
                let status = obj.childSnapshot(forPath: "assigned_center").value as! String
              
                
               
             
                let request = SOSRequest(user_id: user_id, status: status, assignedCenter: center, sent: sent, longitude: lonitude, latitude: latitude, timeDate:time_stamp)
                if(user_id==request.user_id){
                    self.requests.append(request)
                }
            }}}
      
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
