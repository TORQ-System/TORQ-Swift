//
//  viewSOSRequestDetailsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 18/11/2021.
//

import UIKit
import Firebase

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
    @IBOutlet weak var progress1: UIProgressView!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var progress2: UIProgressView!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var progress3: UIProgressView!
    @IBOutlet weak var circle4: UIView!
    @IBOutlet weak var progress4: UIProgressView!
    @IBOutlet weak var circle5: UIView!
    
    
    //MARK: - Variables
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
    var medicalReport = true
    var requestDetails = false
    
    //MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        fetchMedicalReports()

    }
    
    //MARK: - functions
    private func layoutViews(){
        
        //1- back button
        backButton.backgroundColor = UIColor(red: 0.784, green: 0.267, blue: 0.337, alpha: 0.17)
        backButton.layer.cornerRadius = 10
        backButton.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
        
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
        medicalReportButton.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)
        
        //9- Report Deatils button
        requestDetailsButton.setTitleColor(buttonColor, for: .normal)
        requestDetailsButton.layer.cornerRadius = 10


        //10- container view
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = .white
        let shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 20)
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        containerView.layer.shadowOffset = CGSize(width: 4, height: 9)
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowPath = shadowPath.cgPath
        
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
                        
                        //1-translate allergies
                        self.allergiesArray = medicalReport.getAllergies().components(separatedBy: ", ")
                        
                        //2- translate chronic_disease
                        self.diseasesArray = medicalReport.getDiseases().components(separatedBy: ", ")
                        
                        //3- transalte disabilities
                        self.disabilitiesArray = medicalReport.getDisabilities().components(separatedBy: ", ")
                        
                        //4- translate prescribed_medication
                        self.medicationArray = medicalReport.getMedications().components(separatedBy: ", ")
                        
                        
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
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func medicalReportButton(_ sender: Any) {
        medicalReportButton.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)
        requestDetailsButton.backgroundColor = .clear
        MedicalInfromationView.isHidden = false
        requestDetailsButton.isHidden = true
    }
    
    @IBAction func requestDetailsButton(_ sender: Any) {
        requestDetailsButton.backgroundColor = UIColor(red: 0.965, green: 0.922, blue: 0.937, alpha: 1)
        medicalReportButton.backgroundColor = .clear
        MedicalInfromationView.isHidden = true
        requestDetailsButton.isHidden = false
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
