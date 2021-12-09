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
    var ref = Database.database().reference()
    var centerName: String?
    var messgaes = [Message]()
    var sender: SenderType?
    var isNewConversation = false
    let otherUserEmail: String
    let converstationID: String?
    var userName: String?
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    
    //MARK: - Constructure
    
    init(with email:String, id: String?) {
        self.otherUserEmail = email
        self.converstationID = id
        super.init(nibName: nil, bundle: nil)
        if let id = converstationID {
            print("id is not nil")
            listenForMessages(id: id)
        }
        print("id is nil")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Overriden Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func listenForMessages(id: String){
        self.getAllMessagesForConversation(with: id, completion: { result in
            switch result{
            case .success(let message):
                guard !message.isEmpty else{
                    return
                }
                self.messgaes = message
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
            case.failure(let error):
                print(error.localizedDescription)
            }
        })
        
        
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
        sender = Sender(senderId: userEmail, displayName: userName!)
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
        let filteredEmail = self.userEmail.replacingOccurrences(of: "@", with: "-")
        let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-")
        let filteredOtherUserEmail = otherUserEmail.replacingOccurrences(of: "@", with: "-")
        let finalOtherUserEmail = filteredOtherUserEmail.replacingOccurrences(of: "@", with: "-")
        let filteredMessageId = firstMessage.messageId.replacingOccurrences(of: "@", with: "-")
        let finalMessageId = filteredMessageId.replacingOccurrences(of: ".", with: "-")
        
        ref.child("\(finalEmail)").observeSingleEvent(of: .value) { snapshot in
            var userNode = snapshot.value as! [String: Any]
            let messageDate = firstMessage.sentDate
            let dateString = self.dateFormatter.string(from: messageDate)
            var message:String?
            
            switch firstMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let newConversationData:[String:Any] = ["id":"conversation_\(finalMessageId)","otherUserEmail":"\(finalOtherUserEmail)","latest_message":["date":dateString, "message":message!,"is_read":false]]
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                // there exist a converstation for this user
                // append message to the conversation
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                self.ref.child("\(finalEmail)").setValue(userNode)
                self.finishCreatingConversation(conversationID: "conversation_\(finalMessageId)", firstMessage: firstMessage, completion: completion)
            }else{
                //converstaion array dont exists , create it
                userNode["conversations"] = [newConversationData]
                self.ref.child("\(finalEmail)").setValue(userNode)
                self.finishCreatingConversation(conversationID: "conversation_\(finalMessageId)", firstMessage: firstMessage, completion: completion)
            }
        }
        
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        
        let filteredEmail = self.userEmail.replacingOccurrences(of: "@", with: "-")
        let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-")
        let messageDate = firstMessage.sentDate
        let dateString = self.dateFormatter.string(from: messageDate)
        var message:String?
        
        switch firstMessage.kind{
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        
        let collectionMessage:[String: Any] = ["id":firstMessage.messageId
                                               ,"type":firstMessage.kind.messageKindString,"content":message!,"date":dateString,"sender_email":finalEmail,"is_read":false]
        let value:[String: Any] = ["messages":collectionMessage]
        
        
        ref.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    private func getAllConversations(for email:String, completion: @escaping (Result<[Conversation], Error>)-> Void){
        ref.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                return
            }
            
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let id = dictionary["id"] as? String, let lm = dictionary["latest_message"] as? [String: Any], let date = lm["date"] as? String, let isRead = lm["is_read"] as? Bool, let message = lm["message"] as? String, let otherUserEmail = dictionary["otherUserEmail"] as? String else{
                    return nil
                }
                
                let lMessage = latestMessage(date: date, text: message, isRread: isRead)
                
                return Conversation(id: id, latestMessage: lMessage, otherUserEmail: otherUserEmail)
            }
            completion(.success(conversations))
        }
    }
    
    private func getAllMessagesForConversation(with id:String, completion: @escaping (Result<[Message], Error>)-> Void){
        ref.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                return
            }
            
            let messagess: [Message] = value.compactMap { dictionary in
                guard let content = dictionary["content"] as? String, let date = dictionary["date"] as? String, let id = dictionary["id"] as? String, let _ = dictionary["is_read"] as? Bool, let senderEmail = dictionary["sender_email"] as? String, let _ = dictionary["type"] as? String? else{
                    return nil
                }
                
                let stringDate = self.dateFormatter.date(from: date)
                let senderr = Sender(senderId: senderEmail, displayName: self.userName!)
                return Message(sender: senderr, messageId: id, sentDate: stringDate!, kind: .text(content))

            }
            
            completion(.success(messagess))
        }
    }
    
    private func sendMessage(to conversation: String ,message: Message, completion: @escaping (Bool)-> Void){
        
    }
    
    private func createMessageId() -> String{
        //date , otherUserEmail, senderEmail, randomInt
        let dateString = self.dateFormatter.string(from: Date())
        let newIdentefier = "\(otherUserEmail)_\(userEmail)_\(dateString)"
        print("created message id: \(newIdentefier)")
        return newIdentefier
    }
    
    
    //MARK: - @IBActions
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - MessagesDataSource Extensions
extension userChatViewController: MessagesDataSource{
    func currentSender() -> SenderType {
        if let s = sender {
            return s
        }
        fatalError()
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
            
            let message = Message(sender: sender!, messageId: createMessageId(), sentDate: Date(), kind: .text(text))
            self.createNewConversation(with: otherUserEmail, firstMessage: message) { success in
                if success{
                    print("message sent")
                }else{
                    print("failed to sent")
                }
            }
        }else{
            //append to exsisting conversation in db
        }
    }
    
}


