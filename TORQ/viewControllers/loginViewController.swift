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
    
    func validateFields()->[String: String]{
        var errors = ["email":"", "password":""]
        
        //CASE-1: when the user leaves the email field empty
        if email.text == nil || email.text == ""{
            errors["email"] = "the email field can't be empty , try again"
        }
        
        //CASE-1: when the user leaves the password field empty
        if password.text == nil || password.text == ""{
            errors["password"] = "the password field can't be empty , try again"
        }
    
        return errors
        
    }
    
    func goToUserHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func goToParamedicHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "paramedicHomeViewController") as! paramedicHomeViewController
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
        let errors = validateFields()
        
        guard errors["email"] == "" else {
            //handle the error
            showALert(message: errors["email"]!)
            return
        }
        
        guard errors["password"] == "" else {
             //handle the error
             showALert(message: errors["password"]!)
             return
         }
        
        
        //login if the credintaials belong to a SRCA center.
        if email.text!.isParamedicUser {
            // validate if it's correct credintials of the center.
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { authResult, error in
                
                guard error == nil else {
                    self.showALert(message: error!.localizedDescription)
                    return
                }
                
                self.goToParamedicHome()
            }
            return
        }
        
        
        //1- login if the credintials belongs to a user.
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
