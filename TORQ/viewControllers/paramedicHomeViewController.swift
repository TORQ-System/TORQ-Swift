import UIKit
import CoreLocation

class paramedicHomeViewController: UIViewController {

    //MARK: - @IBOutlets
    @IBOutlet weak var closest: UILabel!
    
    //MARK: - Variables
    var loggedInCenterEmail: String!
    var loggedInCenter: [String: Any]?
    
    
    //MARK: - Overriten Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheHardcoded()
        configureCenter()
        
    }
    
    //MARK: - Functions
    func neraest(){
        
        
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

