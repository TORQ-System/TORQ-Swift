import UIKit
import FirebaseDatabase

class requestCollectionViewCell: UICollectionViewCell {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    
    
    //MARK: - Variables
    
    
    //MARK: - Functions
    
    override func layoutSubviews() {
        
        
    }
    
    //MARK: - @IBAction
    @IBAction func goToAccidentLink(_ sender: Any){
        print("will be implemented later")
    }
}
