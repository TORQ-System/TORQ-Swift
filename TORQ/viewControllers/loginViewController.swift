import UIKit
import FirebaseAuth

class loginViewController: UIViewController {

    //MARK:- @IBOutlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //MARK: - Vraibales
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    //MARK: - Functions
    
    func goToUserHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func showALert(message:String){
        //show alert based on the message that is being paased as parameter
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - @IBActions
    @IBAction func loginpressed(_ sender: Any) {
        
        //1- fields validation:
        
        
        //1- login functionality
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { authResult, error in
            guard error == nil else{
                self.showALert(message: error!.localizedDescription)
                return
            }
            
            // go to user home screen
            _ = authResult?.user.uid
            self.goToUserHome()
            
        }
    }
    
}
