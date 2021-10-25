//
//  AccidentsViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit
import MapKit

class AccidentsViewController: UIViewController {

    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    //MARK: - Functions
    
    //MARK: - @IBActions
}


   //MARK: - Map View Delegate Extension
extension AccidentsViewController: MKMapViewDelegate{
    
}
