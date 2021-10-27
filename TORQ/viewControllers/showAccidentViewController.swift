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
        let latitude = Double(location!["latitude"]!)
        let pin = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        annotation.title = "Accident Location"
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
