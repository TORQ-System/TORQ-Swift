//
//  viewSOSRequestDetailsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 18/11/2021.
//

import UIKit
import Firebase
import SCLAlertView

class viewSOSRequestDetailsViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var requestTime: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var medicalReportButton: UIButton!
    @IBOutlet weak var requestDetailsButton: UIButton!
    @IBOutlet weak var MedicalInfromationView: UIView!
    @IBOutlet weak var RequestInformationView: UIView!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var bloodTypeView: UIView!
    @IBOutlet weak var bloodTypeLabel: UILabel!
    @IBOutlet weak var allergiesView: UIView!
    @IBOutlet weak var disabilitiesView: UIView!
    @IBOutlet weak var diseasesView: UIView!
    @IBOutlet weak var medicationView: UIView!
    @IBOutlet weak var allergiesCollectionView: UICollectionView!
    @IBOutlet weak var disabilitiesColletionView: UICollectionView!
    @IBOutlet weak var diseasesCollectionView: UICollectionView!
    @IBOutlet weak var medicationsCollectionView: UICollectionView!
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var check1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var check2: UIImageView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var check3: UIImageView!
    @IBOutlet weak var label3: UILabel!
    
    
    
    //MARK: - Variables
    var sosRequestStatus: String?
    var sosRequester: String?
    var sosRequestTime: String?
    var sosRequestName: String?
    var sosRequestAge: Int?
    var ref = Database.database().reference()
    var MedicalReports: [MedicalReport] = []
    var allergiesArray: [String] = []
    var disabilitiesArray: [String] = []
    var diseasesArray: [String] = []
    var medicationArray: [String] = []
    var medicalReport = false
    var requestDetails = true
    var medicalReportID: String?
    var phoneNumber: String?
    var conversations: [Conversation]?
    var centerEmail = Auth.auth().currentUser!.email!
    var userEmail: String?
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(contentViewCornerRadius: 15, buttonCornerRadius: 7, hideWhenBackgroundViewIsTapped: true)
    var longitude: Double?
    var latitude: Double?
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMedicalReports()
        layoutViews()
        subLayoutRequestDetails()
        conversations = []

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchSOSRequests()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        conversations = []
    }
    
    //MARK: - functions
    private func layoutViews(){
        
        //1- back button
//        backButton.backgroundColor = UIColor(red: 0.784, green: 0.267, blue: 0.337, alpha: 0.17)
//        backButton.layer.cornerRadius = 10
//        backButton.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
        
        //2- profile container
        profileContainer.layer.cornerRadius = profileContainer.layer.frame.width/2
        profileContainer.layer.masksToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = profileContainer.frame
        gradientLayer.colors = [
            UIColor(red: 0.102, green: 0.157, blue: 0.345, alpha: 1).cgColor,
            UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor
          ]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0.98, c: -0.75, d: 1.6, tx: 0.38, ty: -0.77))
        gradientLayer.bounds = profileContainer.bounds.insetBy(dx: -0.5*profileContainer.bounds.size.width, dy: -0.5*profileContainer.bounds.size.height)
        gradientLayer.position = profileContainer.center
        profileContainer.layer.addSublayer(gradientLayer)
        profileContainer.layer.insertSublayer(gradientLayer, at: 0)
        
        //3- user Name label
        patientName.text = sosRequestName
        
        //4- occured at label
        requestTime.text = "Occured at: \(String(describing: sosRequestTime!))"
        
        //5- chat button
        chatButton.layer.cornerRadius = 10
        chatButton.layer.masksToBounds = true
        chatButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.1)
        chatButton.tintColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        chatButton.setTitleColor(UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1), for: .normal)
        
        //6- process button
        processButton.layer.cornerRadius = 10
        processButton.layer.masksToBounds = true
        processButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.1)
        processButton.tintColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        processButton.setTitleColor(UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1), for: .normal)
        if sosRequestStatus == "Processed" || sosRequestStatus == "Cancelled" {
            processButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            processButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            processButton.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.1), for: .normal)
            processButton.isEnabled = false
        }
        
        //7- directions button
        directionsButton.layer.cornerRadius = 10
        directionsButton.layer.masksToBounds = true
        directionsButton.backgroundColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 0.1)
        directionsButton.tintColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
        directionsButton.setTitleColor(UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1), for: .normal)
        
        //8- Medical Report button
        let buttonColor = UIColor(red: 0.788, green: 0.271, blue: 0.341, alpha: 1)
        medicalReportButton.setTitleColor(buttonColor, for: .normal)
        medicalReportButton.layer.cornerRadius = 10
        
        //9- Report Deatils button
        requestDetailsButton.setTitleColor(buttonColor, for: .normal)
        requestDetailsButton.layer.cornerRadius = 10
        requestDetailsButton.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)


        //10- container view
//        containerView.layer.cornerRadius = 20
//        containerView.backgroundColor = .white
//        containerView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
//        y: containerView.bounds.maxY - containerView.layer.shadowRadius,width: containerView.bounds.width,height: containerView.layer.shadowRadius)).cgPath
//        containerView.layer.masksToBounds = false
//        containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        containerView.layer.shadowOpacity = 0.5
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: containerView.bounds.origin.x, y: containerView.frame.size.height))
        shadowPath.addLine(to: CGPoint(x: containerView.bounds.width / 2, y: containerView.bounds.height + 7.0))
        shadowPath.addLine(to: CGPoint(x: containerView.bounds.width, y: containerView.bounds.height))
        shadowPath.close()

        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.masksToBounds = false
        containerView.layer.shadowPath = shadowPath.cgPath
        containerView.layer.shadowRadius = 5
        
        //11- background view
        view.backgroundColor = UIColor(red: 0.976, green: 0.988, blue: 0.992, alpha: 1)
        
        //12- age view
        let color  = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        addTopBorder(with: color, andWidth: 1, view: ageView)
        addBottomBorder(with: color, andWidth: 1, view: ageView)
        addRightBorder(with: color, andWidth: 1, view: ageView)
        
        //13- blood type view
        addTopBorder(with: color, andWidth: 1, view: bloodTypeView)
        addBottomBorder(with: color, andWidth: 1, view: bloodTypeView)
        
        //14- age label
        ageLabel.text = "\(sosRequestAge!)"
        
        //15- allergies view
        addBottomBorder(with: color, andWidth: 1, view: allergiesView)
        
        //16- disabilities view
        addBottomBorder(with: color, andWidth: 1, view: disabilitiesView)
        
        //17- diseases view
        addBottomBorder(with: color, andWidth: 1, view: diseasesView)
        
        //18- Medical View
        MedicalInfromationView.isHidden = true

        
        //19- Request View
        RequestInformationView.isHidden = false
    }
    
    private func subLayoutRequestDetails(){
        
        //1- background view
        RequestInformationView.backgroundColor = UIColor(red: 0.976, green: 0.988, blue: 0.992, alpha: 1)
        self.label1.text = "\(self.patientName.text!)'s request has been assgined to your center"

        
        if self.sosRequestStatus == "Cancelled" {
            
            //1- circle one
            circle1.layer.cornerRadius = circle1.layer.frame.width/2
            self.check1.alpha = 1.0
            self.circle1.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            self.label1.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            
            //2- circle two
            circle2.layer.cornerRadius = circle2.layer.frame.width/2
            self.check2.alpha = 1.0
            self.circle2.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            self.label2.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            
            //3- circle three
            circle3.layer.cornerRadius = circle3.layer.frame.width/2
            self.check3.alpha = 1.0
            self.circle3.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            self.label3.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            self.label3.text = "This SOS Request has been Cancelled"
            
        } else if self.sosRequestStatus == "Processed" || self.sosRequestStatus == "Active" {
            //1- circle one
            circle1.layer.cornerRadius = circle1.layer.frame.width/2
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                UIView.animate(withDuration: 1) {
                    self.check1.alpha = 1.0
                    self.circle1.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                    self.label1.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                }
            }
            
            //2- circle two
            circle2.layer.cornerRadius = circle2.layer.frame.width/2
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                UIView.animate(withDuration: 1) {
                    self.check2.alpha = 1.0
                    self.circle2.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                    self.label2.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                }
            }
            
            //3- circle three
            circle3.layer.cornerRadius = circle3.layer.frame.width/2
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                UIView.animate(withDuration: 1) {
                    self.circle3.alpha = 1.0
                    self.circle3.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                    self.label3.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                    self.label3.text = "This SOS Request has been processed"
                }
            }
        }
    }
    
    private func fetchMedicalReports(){
        // getting the user's Medical information
        let usersQueue = DispatchQueue.init(label: "usersQueue")
        usersQueue.sync {
            ref.child("MedicalReport").observe(.value) { snapshot in
                self.MedicalReports = []
                for report in snapshot.children{
                    let obj = report as! DataSnapshot
                    let allergies = obj.childSnapshot(forPath: "allergies").value as! String
                    let blood_type = obj.childSnapshot(forPath: "blood_type").value as! String
                    let chronic_disease = obj.childSnapshot(forPath: "chronic_disease").value as! String
                    let disabilities = obj.childSnapshot(forPath: "disabilities").value as! String
                    let prescribed_medication = obj.childSnapshot(forPath: "prescribed_medication").value as! String
                    let user_id = obj.childSnapshot(forPath: "user_id").value as! String

                    let medicalReport = MedicalReport(userID: user_id, bloodType: blood_type, allergies: allergies, chronic_disease: chronic_disease, disabilities: disabilities, prescribed_medication: prescribed_medication)
                    
                    if medicalReport.getUserID() == self.sosRequester {
                        self.MedicalReports.append(medicalReport)
                        self.bloodTypeLabel.text = medicalReport.getBloodType()
                        self.medicalReportID = obj.key
                        
                        //1-translate allergies
                        self.allergiesArray = medicalReport.getAllergies().components(separatedBy: ",")
                        
                        //2- translate chronic_disease
                        self.diseasesArray = medicalReport.getDiseases().components(separatedBy: ",")
                        
                        //3- transalte disabilities
                        self.disabilitiesArray = medicalReport.getDisabilities().components(separatedBy: ",")
                        
                        //4- translate prescribed_medication
                        self.medicationArray = medicalReport.getMedications().components(separatedBy: ",")
                        
                        
                    }
                    self.allergiesCollectionView.reloadData()
                    self.disabilitiesColletionView.reloadData()
                    self.diseasesCollectionView.reloadData()
                    self.medicationsCollectionView.reloadData()
                }
                print("usersInfo: \(self.MedicalReports)")
            }
        }
    }
    
    private func fetchSOSRequests(){
        // getting the user's SOS request's status
        let usersQueue = DispatchQueue.init(label: "usersQueue")
        usersQueue.sync {
            ref.child("SOSRequests").observe(.value) { snapshot in
                for req in snapshot.children{
                    let obj = req as! DataSnapshot
                    let status = obj.childSnapshot(forPath: "status").value as! String
                    
                    if status == "Processed"{
                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                            UIView.animate(withDuration: 1) {
                                self.check3.alpha = 1.0
                                self.circle3.backgroundColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                                self.label3.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
                            }
                        }
                    }
                }
                print("usersInfo: \(self.MedicalReports)")
            }
        }
    }
    
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat, view: UIView) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: borderWidth)
        view.addSubview(border)
        view.sendSubviewToBack(border)
    }

    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat, view: UIView) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: view.frame.size.height - borderWidth, width: view.frame.size.width, height: borderWidth)
        view.addSubview(border)
        view.sendSubviewToBack(border)
    }
    
    func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat, view: UIView) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: view.frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        view.addSubview(border)
        view.sendSubviewToBack(border)
    }

    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat, view: UIView) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: view.frame.size.width - borderWidth, y: 0, width: borderWidth, height: view.frame.size.height)
        view.addSubview(border)
        view.sendSubviewToBack(border)
    }
    
    private func getAllConversations(for email:String, completion: @escaping (Result<[Conversation], Error>)-> Void){
        ref.child("\(email)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                print("value is nil")
                completion(.failure(NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "Invalid access token"])))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let id = dictionary["id"] as? String, let lm = dictionary["latest_message"] as? [String: Any], let date = lm["date"] as? String, let isRead = lm["is_read"] as? Bool, let message = lm["message"] as? String, let otherUserEmail = dictionary["otherUserEmail"] as? String else{
                    print("one of the conversation attribute is nil")
                    return nil
                }
                
                let lMessage = latestMessage(date: date, text: message, isRread: isRead)
                
                return Conversation(id: id, latestMessage: lMessage, otherUserEmail: otherUserEmail)
            }
            print(conversations)
            completion(.success(conversations))
        }
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func medicalReportButton(_ sender: Any) {
        medicalReportButton.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)
        requestDetailsButton.backgroundColor = .clear
        MedicalInfromationView.isHidden = false
        RequestInformationView.isHidden = true
    }
    
    @IBAction func requestDetailsButton(_ sender: Any) {
        requestDetailsButton.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)
        medicalReportButton.backgroundColor = .clear
        MedicalInfromationView.isHidden = true
        RequestInformationView.isHidden = false
    }
    @IBAction func processButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "selectHealthCareCenterViewController") as! selectHealthCareCenterViewController
        vc.sosRequestUserID = self.patientName.text
        let filteredEmail = self.centerEmail.replacingOccurrences(of: "@", with: "-")
        let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-")
        let filteredOtherUserEmail = userEmail!.replacingOccurrences(of: "@", with: "-")
        let finalOtherUserEmail = filteredOtherUserEmail.replacingOccurrences(of: ".", with: "-")
        vc.userID = sosRequester
        vc.finalEmail = finalEmail
        vc.finalOtherUserEmail = finalOtherUserEmail
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func chat(_ sender: Any) {
        
        let filteredEmail = self.centerEmail.replacingOccurrences(of: "@", with: "-")
        let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-")
        let filteredOtherUserEmail = userEmail!.replacingOccurrences(of: "@", with: "-")
        let finalOtherUserEmail = filteredOtherUserEmail.replacingOccurrences(of: ".", with: "-")
        
        let checkQueue = DispatchQueue.init(label: "checkQueue")
        let fetchQueue = DispatchQueue.init(label: "fetchQueue")
        fetchQueue.sync {
            self.getAllConversations(for: finalOtherUserEmail) { result in
                switch result {
                case .success(let conversations):
                    print("successfuly got conversations model")
                    guard !conversations.isEmpty else {
                        print("conversations is empty")
                        return
                    }
                    print("line232\(conversations)")
                    self.conversations = conversations
                case .failure(let error):
                    print("faliure case: \(error.localizedDescription)")
                }
                checkQueue.sync {
                    if self.conversations == nil || self.conversations!.isEmpty{
                        print("empty")
                        SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "Please wait for \(String(describing: self.patientName.text!)) to initiate the conversation", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Got it!", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
//                        let vc = paramedicChatViewController(with: "\(finalOtherUserEmail)",id: nil)
//                        vc.Name = self.patientName.text
//                        vc.phoneNumber = self.phoneNumber
//                        vc.isNewConversation = true
//                        vc.modalPresentationStyle = .fullScreen
//                        let navController = UINavigationController(rootViewController: vc)
//                        navController.modalPresentationStyle = .fullScreen
//                        self.present(navController, animated:true, completion: nil)
                    }else{
                        var c: Conversation?
                        for conv in self.conversations!{
                            if conv.id == "conversation_\(finalEmail)_\(finalOtherUserEmail)" {
                                print("found c that matches")
                                c = conv
                                break
                            }
                        }
                        
                        if c == nil {
                            print("c is nil")
                            SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "an error occured please try again", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Got it!", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
//                            let vc = paramedicChatViewController(with: "\(finalOtherUserEmail)",id: nil)
//                            vc.Name = self.patientName.text
//                            vc.phoneNumber = self.phoneNumber
//                            vc.isNewConversation = true
//                            vc.modalPresentationStyle = .fullScreen
//                            let navController = UINavigationController(rootViewController: vc)
//                            navController.modalPresentationStyle = .fullScreen
//                            self.present(navController, animated:true, completion: nil)
                        }else{
                            print("the user has initiated the conversation")
                            let vc = paramedicChatViewController(with: "\(finalOtherUserEmail)",id: c!.id)
                            vc.Name = self.patientName.text
                            vc.phoneNumber = self.phoneNumber
                            vc.finalEmail = finalEmail
                            vc.finalOtherUserEmail = finalOtherUserEmail
                            vc.modalPresentationStyle = .fullScreen
                            let navController = UINavigationController(rootViewController: vc)
                            navController.modalPresentationStyle = .fullScreen
                            self.present(navController, animated:true, completion: nil)
                        }
                    }
                }
            }
        }
        conversations = []
    }
    
    @IBAction func launchDirections(_ sender: Any) {
    
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(String(describing: latitude!)),\(String(describing: longitude!))&directionsmode=driving") {
            UIApplication.shared.open(url, options: [:])
        }
    
    }
    
    
}

//MARK: - extension

extension viewSOSRequestDetailsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        switch collectionView {
        case allergiesCollectionView:
            count = allergiesArray.count
        case disabilitiesColletionView:
            count = disabilitiesArray.count
        case diseasesCollectionView:
            count = diseasesArray.count
        case medicationsCollectionView:
            count = medicationArray.count
        default:
            print("unknown")
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "medicalCell", for: indexPath) as! medicalCollectionViewCell
        switch collectionView {
        case allergiesCollectionView:
            cell.label.text = allergiesArray[indexPath.row]
            cell.label.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            cell.layer.cornerRadius = 10
            cell.contentView.layer.cornerRadius = 10
            cell.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)
            return cell
        case disabilitiesColletionView:
            cell.label.text = disabilitiesArray[indexPath.row]
            cell.label.textColor = UIColor(red: 0.286, green: 0.671, blue: 0.875, alpha: 1)
            cell.layer.cornerRadius = 10
            cell.contentView.layer.cornerRadius = 10
            cell.backgroundColor = UIColor(red: 0.906, green: 0.957, blue: 0.98, alpha: 1)
            return cell
        case diseasesCollectionView:
            cell.label.text = diseasesArray[indexPath.row]
            cell.label.textColor = UIColor(red: 0.622, green: 0.742, blue: 0.423, alpha: 1)
            cell.layer.cornerRadius = 10
            cell.contentView.layer.cornerRadius = 10
            cell.backgroundColor = UIColor(red: 0.941, green: 0.965, blue: 0.937, alpha: 1)
            return cell
        case medicationsCollectionView:
            cell.label.text = allergiesArray[indexPath.row]
            cell.label.textColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
            cell.layer.cornerRadius = 10
            cell.contentView.layer.cornerRadius = 10
            cell.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)
            return cell
        default:
            print("unknown")
        }
        return cell
    }
}

public func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 2.5
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }

