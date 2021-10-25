import UIKit
import MapKit
import Firebase

class AccidentsViewController: UIViewController {

    //MARK: - Varibales
    var ref = Database.database().reference()
    var accidentRequests: [Request]?
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    //MARK: - Functions
    private func retreiveAccidents(){
        
        
    }
    
    //MARK: - @IBActions
}


   //MARK: - Map View Delegate Extension
extension AccidentsViewController: MKMapViewDelegate{
    
}
