import UIKit
import MapKit

class viewLocationViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Variables
    var longitude: Double!
    var latitude: Double!
    var locationManager = CLLocationManager()
    
    //MARK: - Overriden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setPinUsingMKPlacemark(location: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)))
    }
    
    //MARK: - Functions
    func setPinUsingMKPlacemark(location: CLLocationCoordinate2D) {
        let pin = MKPlacemark(coordinate: location)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = "Accident Location"
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        map.setRegion(coordinateRegion, animated: true)
        map.addAnnotation(annotation)
    }
    
    func setView() {
        let viewRegion = MKCoordinateRegion.init(center: .init(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), latitudinalMeters: 800, longitudinalMeters: 800)
        map.setRegion(viewRegion, animated: true)
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - Map View Delegate Extension
extension viewLocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation)else{
            return nil
        }
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "accidentPin")
        if pin == nil {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "accidentPin")
            pin?.canShowCallout = true
            pin?.image = UIImage(named: "Vector")
        }else{
            pin?.annotation = annotation
        }

        
        
        
        return pin
    }

    
}
