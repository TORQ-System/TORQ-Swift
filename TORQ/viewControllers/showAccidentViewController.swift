//
//  showAccidentViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 27/10/2021.
//

import UIKit
import MapKit

class showAccidentViewController: UIViewController {
    
    var location: [String: String]? = [:]

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationRegion()

    }
    
    func LocationRegion(){
        let longitude = Double(location!["longitude"]!)
        print("map view\(String(describing: longitude!))")
        let latitude = Double(location!["latitude"]!)
        print("map view\(String(describing: latitude!))")
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = "Accident Location: \(String(describing: longitude!)) \(String(describing: latitude!))"
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func backToHomeView(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let tb = storyboard.instantiateViewController(identifier: "Home") as! UITabBarController
//        let vcs = tb.viewControllers!
//        let map = vcs[2] as! AccidentsViewController
//        map.modalPresentationStyle = .fullScreen
//        present(tb, animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
}

//extension showAccidentViewController: MKMapViewDelegate{
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !(annotation is MKUserLocation)else{
//            return nil
//        }
//        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "accidentView")
//        if pin == nil {
//            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "accidentView")
//            pin?.canShowCallout = true
//        }else{
//            pin?.annotation = annotation
//        }
//        let img = UIImageView(image: UIImage(named: "pin"))
//        img.tintColor = .blue
//        pin?.image = img.image
//        pin?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        return pin
//    }
//    
//
//
//}
