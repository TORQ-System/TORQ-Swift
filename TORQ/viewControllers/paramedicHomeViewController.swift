import UIKit
import FirebaseAuth

class paramedicHomeViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    
    //MARK: - Variables
    var loggedinEmail: String!
    
    
    //MARK: - Overriden funtions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Functions
    func showALert(message:String){
        //show alert based on the message that is being paased as parameter
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func goToLoginScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! loginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - @IBActions
    @IBAction func viewRequestsPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "requestsViewController") as! requestsViewController
        vc.loggedInCenterEmail = self.loggedinEmail
        print("home: \(String(describing: loggedinEmail))")
        print("home: \(String(describing: vc.loggedInCenterEmail))")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let userDefault = UserDefaults.standard
            userDefault.setValue(false, forKey: "isUserSignedIn")
            goToLoginScreen()
        } catch let error {
            self.showALert(message: error.localizedDescription)
        }
    }
    


}
