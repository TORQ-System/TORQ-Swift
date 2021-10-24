import UIKit

class onboardingScreen1ViewController: UIViewController {

    //MARK: - @IBOutlets
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shapeContainer: UIView!
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let shape = CAShapeLayer()
        shape.path = bPath.cgPath
        shape.lineWidth = 21
        shape.strokeColor = UIColor(red: 0.83921569, green: 0.33333333, blue: 0.42352941, alpha: 1).cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeEnd = 0
        shapeContainer.layer.addSublayer(shape)
        
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue = 0.33333334
            anim.duration = 1
            anim.isRemovedOnCompletion = false
            anim.fillMode = .forwards
            shape.add(anim, forKey: "strokeEnd")
        
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

