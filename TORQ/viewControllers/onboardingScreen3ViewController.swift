import UIKit

class onboardingScreen3ViewController: UIViewController {

    
    //MARK: - @IBOutlets
    @IBOutlet weak var shapeContainer: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var joinusButton: UIButton!

    //MARK:- Variables
    let shape = CAShapeLayer()

    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        ToggleButtonsAlpha(flag: true)
        configureLevelLayer()
    }
    
    //MARK: - Functions
    
    private func configureButtons() -> Void{
        joinusButton.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 0.5
    }
    
    private func configureLevelLayer(){
        nextButton.layer.cornerRadius = 30
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = UIColor.white
        let bPath = UIBezierPath(arcCenter: CGPoint(x: shapeContainer.frame.width/2, y: shapeContainer.frame.height/2), radius: shapeContainer.frame.height/2, startAngle: 0, endAngle: (.pi * 2), clockwise: true)
        
        let trackLayer = CAShapeLayer()
        trackLayer.path = bPath.cgPath
        trackLayer.lineWidth = 21
        trackLayer.strokeColor = UIColor.clear.cgColor
         trackLayer.fillColor = UIColor.clear.cgColor
        shapeContainer.layer.addSublayer(trackLayer)
        shape.path = bPath.cgPath
        shape.lineWidth = 21
        shape.strokeColor = UIColor(red: 0.83921569, green: 0.33333333, blue: 0.42352941, alpha: 1).cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeEnd = 0
        shapeContainer.layer.addSublayer(shape)
        
        animateProgress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.shapeContainer.alpha = 0
            self.nextButton.alpha = 0
            self.animateOpacity()
        }
    }
    
    private func animateOpacity()-> Void{
        UIButton.animate(withDuration: 1) {
            self.joinusButton.alpha = 1
            self.loginButton.alpha = 1
        }
    }
    
    
    private func animateProgress()-> Void{
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0.66666664
        anim.toValue = 1
        anim.duration = 1
        anim.isRemovedOnCompletion = false
        anim.fillMode = .forwards
        shape.add(anim, forKey: "strokeEnd")
    }
    
    private func ToggleButtonsAlpha(flag: Bool) -> Void{
        if flag {
            joinusButton.alpha = 0
            loginButton.alpha = 0
        }else{
            joinusButton.alpha = 1
            loginButton.alpha = 1
        }
    }
    
    //MARK: - @IBActions
    @IBAction func joinUsButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "signUpFirstViewController") as! signUpFirstViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "loginViewController") as! loginViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func geToLoginButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "loginViewController") as! loginViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backbutton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "loginViewController") as! loginViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
