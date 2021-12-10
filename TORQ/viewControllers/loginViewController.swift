import UIKit
import FirebaseAuth
import SCLAlertView


class loginViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var roundGradientView: UIView!
    
    //MARK: - Vraibales
    var tap = UITapGestureRecognizer()
    var userID: String?
    var userEmail: String?
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(contentViewCornerRadius: 15, buttonCornerRadius: 7, hideWhenBackgroundViewIsTapped: true)
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        email.setBorder(color: "default", image: UIImage(named: "emailDefault")!)
        email.clearsOnBeginEditing = false
        password.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        
        configureTapGesture()
        configureButtonView()
    }
    
    //MARK: - Functions
    func configureTapGesture(){
        tap = UITapGestureRecognizer(target: self, action: #selector(self.loginClicked(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        buttonView.addGestureRecognizer(tap)
        buttonView.isUserInteractionEnabled = true
    }
    
    func configureButtonView(){
        roundGradientView.layer.cornerRadius = 20
        roundGradientView.layer.shouldRasterize = true
        roundGradientView.layer.rasterizationScale = UIScreen.main.scale
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.cornerRadius = 20
        gradient.colors = [
            UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = roundGradientView.bounds
        roundGradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    func validateFields()->[String: String]{
        var errors = ["email":"", "password":""]
        
        if email.text == nil || email.text == "" {
            errors["email"] = "Fields cannot be empty"
        } else if password.text == nil || password.text == "" {
            errors["password"] = "Fields cannot be empty"
        }
        return errors
        
    }
    
    func goToUserHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tb = storyboard.instantiateViewController(identifier: "Home") as! UITabBarController
        let vcs = tb.viewControllers!
        let home = vcs[0] as! userHomeViewController
        home.userEmail = email.text
        home.userID = userID
        home.modalPresentationStyle = .fullScreen
        present(tb, animated: true, completion: nil)
    }
    
    func goToParamedicHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tb = storyboard.instantiateViewController(identifier: "paramedicHome") as! UITabBarController
        let vcs = tb.viewControllers!
        let home = vcs[1] as! ViewSOSRequestsViewController
        let domainRange = email.text!.range(of: "@")!
        let centerName = email.text![..<domainRange.lowerBound]
        home.loggedinEmail = String(centerName)
        home.modalPresentationStyle = .fullScreen
        present(tb, animated: true, completion: nil)
    }
    
    func goToResetPassword(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "resetPasswordViewController") as! resetPasswordViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func loginClicked(_ sender: UITapGestureRecognizer) {
        let errors = validateFields()
        
        guard errors["email"] == ""  else {
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: errors["email"]!, color: self.redUIColor, icon: alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            
            return
        }
        
        guard errors["password"] == ""  else {
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: errors["password"]!, color: self.redUIColor, icon: alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        
        Auth.auth().signIn(withEmail: email.text!.trimWhiteSpace(), password: password.text!) { [self] authResult, error in
            
            guard error == nil else{
                SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: "Incorrect email or password", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Got it!", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
                return
            }
            if(self.email.text!.isParamedicUser){
                self.goToParamedicHome()
            }
            else{
                self.userID = authResult!.user.uid
                self.goToUserHome()
            }
        }
    }
    
    //MARK: - @IBActions
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        if sender.text == nil ||  sender.text == ""{
            sender.setBorder(color: "error", image: UIImage(named: "emailError")!)
        } else{
            sender.setBorder(color: "valid", image:  UIImage(named: "emailValid")!)
        }
    }
    
    @IBAction func passwordEditingChanged(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            sender.setBorder(color: "error", image: UIImage(named: "lockError")!)
        } else{
            sender.setBorder(color: "valid", image:  UIImage(named: "lockValid")!)
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        goToResetPassword()
    }
    
    @IBAction func goToSignUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUpFirstViewController") as! signUpFirstViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension loginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
