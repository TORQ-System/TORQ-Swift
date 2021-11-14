import UIKit
import FirebaseDatabase
import MapKit

class requestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var viewbutten: UIButton!
    
    @IBOutlet weak var status: UILabel!    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var map: MKMapView!
}
