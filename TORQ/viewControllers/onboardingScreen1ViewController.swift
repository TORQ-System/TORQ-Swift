import UIKit

class onboardingScreen1ViewController: UIViewController {

    //MARK: - @IBOutlets
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Functions
    
    //MARK: - @IBActions
    @IBAction func skipButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "loginViewController") as! loginViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "onboardingScreen2") as! onboardingScreen2ViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}
