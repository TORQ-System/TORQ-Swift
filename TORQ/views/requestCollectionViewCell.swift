import UIKit
import FirebaseDatabase
import MapKit

class requestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewDetailsButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var map: MKMapView!
    
    
    override func layoutSubviews() {
        viewDetailsButton.layer.cornerRadius = viewDetailsButton.layer.frame.width/2
    }
}
