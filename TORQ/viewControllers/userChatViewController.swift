//
//  userChatViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 08/12/2021.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView

class userChatViewController: MessagesViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cName: UILabel!
    
    //MARK: - Variables
    var userID = Auth.auth().currentUser!.uid
    var userEmail = Auth.auth().currentUser!.email!
    var centerName: String?
    var messgaes = [Message]()
    var sender: SenderType?
    var isNewConversation = false
    let otherUserEmail: String
    
    
    //MARK: - Constructure
    
    init(with email:String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Overriden Function

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupLayout()
        setDelegate()
        setbackButton()
        configuration()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    //MARK: - Private functions
    @objc private func backClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setDelegate(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func setbackButton(){
        let back = UIButton()
        back.setTitle("back", for: .normal)
        back.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        back.tintColor = .systemBlue
        back.setTitleColor(.systemBlue, for: .normal)
        back.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: back)
        navigationItem.leftBarButtonItem = barButton
    }
    
    private func configuration(){
        navigationItem.title = centerName
        //TODO pass the name of the user
        sender = Sender(senderId: userEmail, displayName: "userEmail")
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
    
    private func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        
    }
    
    private func getAllConversation(for email:String, completion: @escaping (Result<String, Error>)-> Void){
        
    }
    
    private func getAllMessagesForConversation(with id:String, completion: @escaping (Result<String, Error>)-> Void){
        
    }
    
    private func sendMessage(to conversation: String ,message: Message, completion: @escaping (Bool)-> Void){
        
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

//MARK: - MessagesDisplayDelegate Extensions
extension userChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        
        print("sending: \(text)")
        
        //send meesage
        if isNewConversation{
            //create converstaion in db
            
            let message = Message(sender: <#T##SenderType#>, messageId: <#T##String#>, sentDate: Date(), kind: .text(text))
            self.createNewConversation(with: <#T##String#>, firstMessage: <#T##Message#>, completion: <#T##(Bool) -> Void#>)
        }else{
            //append to exsisting conversation in db
        }
    }
    
}


