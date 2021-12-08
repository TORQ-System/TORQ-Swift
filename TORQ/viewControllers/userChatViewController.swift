//
//  userChatViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 08/12/2021.
//

import UIKit
import MessageKit
import Firebase

class userChatViewController: MessagesViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cName: UILabel!
    
    //MARK: - Variables
    var userID = Auth.auth().currentUser!.uid
    var userEmail = Auth.auth().currentUser!.email!
    var centerName:String?
    var messgaes = [Message]()
    var sender: SenderType?
    
    //MARK: - creating UIKit Programmatically
//    private let backbutton: UIButton = {
//        let button = UIButton(frame: CGRect(x: 20, y: -50, width: 60, height: 30))
//        button.tintColor = .blue
//        button.setTitle("back", for: .normal)
//        button.setImage(UIImage(systemName: "back"), for: .normal)
//        button.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
//        return button
//    }()
    
    //MARK: - Overriden Function

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        let back = UIButton()
        back.setTitle("back", for: .normal)
        back.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        back.tintColor = .systemBlue
        back.setTitleColor(.systemBlue, for: .normal)
        let barButton = UIBarButtonItem(customView: back)
        navigationItem.leftBarButtonItem = barButton
        cName.text = centerName
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        sender = Sender(senderId: userID, displayName: userEmail)
        
        messgaes.append(Message(sender: sender!, messageId: "1", sentDate: Date(), kind: .text("hello world")))
        
        messgaes.append(Message(sender: sender!, messageId: "1", sentDate: Date(), kind: .text("hello worldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworldworld")))

    }
    
    //MARK: - Private functions
    @objc private func backClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func setupLayout(){
        //1- containerView
        containerView.layer.cornerRadius = 50
        containerView.layer.masksToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.frame
        gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.96, b: 0.95, c: -0.95, d: -1.56, tx: 1.43, ty: 0.83))
        gradientLayer.bounds = containerView.bounds.insetBy(dx: -0.5*containerView.bounds.size.width, dy: -0.5*containerView.bounds.size.height)
        gradientLayer.position = containerView.center
        containerView.layer.addSublayer(gradientLayer)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    //MARK: - @IBActions
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - MessagesDataSource Extensions
extension userChatViewController: MessagesDataSource{
    func currentSender() -> SenderType {
        return sender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messgaes[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messgaes.count
    }
}

//MARK: - MessagesLayoutDelegate Extensions
extension userChatViewController: MessagesLayoutDelegate{
    
}

//MARK: - MessagesDisplayDelegate Extensions
extension userChatViewController: MessagesDisplayDelegate{
    
}
