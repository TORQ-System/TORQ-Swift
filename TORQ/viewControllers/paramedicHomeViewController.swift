import UIKit
import CoreLocation

class paramedicHomeViewController: UIViewController {

    //MARK: - @IBOutlets
    @IBOutlet weak var closest: UILabel!
    
    //MARK: - Variables
    var loggedInCenterEmail: String!
    var loggedInCenter: [String: Any]?
    var numOfRequests: Int = 0
    let accidentLocation = [ "latitude": 24.812892146472297, "longitude": 46.60365306012578 ];
    
    //MARK: - Overriten Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheHardcoded()
        configureCenter()
        nearest()
        
    }
    
    //MARK: - Functions
    func nearest(){
        let nearest = SCRACenters.getNearest(accidentLoacation: accidentLocation)
        if nearest["name"] as! String == "almalqa" {
            numOfRequests+=1
        }
        closest.text = "the malqa Center has \(numOfRequests) requests"
    }
    
    func setupTheHardcoded(){
        loggedInCenterEmail = "almalqa@srca.org.sa"
    }
    
    func configureCenter(){
        let domainRange = loggedInCenterEmail.range(of: "@")!
        let centerName = loggedInCenterEmail[..<domainRange.lowerBound]
        loggedInCenter = SCRACenters.getSRCAInfo(name: String(centerName))
    }
    
    //MARK: - @IBActions
    
    

}

