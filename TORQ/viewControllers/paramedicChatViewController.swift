//
//  paramedicChatViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 05/12/2021.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView


class paramedicChatViewController: MessagesViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    //MARK: - Variables
    var phoneNumber: String?
    var Name: String?
    var messgaes = [Message]()
    var sender: Sender?
    var isNewConversation = false
    let otherUserEmail: String
    let converstationID: String?
    var ref = Database.database().reference()
    let centerEmail = Auth.auth().currentUser!.email!
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    var centerName: String?
    var finalEmail: String?
    var finalOtherUserEmail: String?

    
    //MARK: - Overriden Functions
    
    init(with email:String, id: String?) {
        self.otherUserEmail = email
        self.converstationID = id
        let token = centerEmail.components(separatedBy: "@")
        centerName = token[0]
        super.init(nibName: nil, bundle: nil)
        if let id = converstationID {
            print("id is not nil")
            listenForMessages(id: id, shouldScrollToButtom: true)
        }else{
//            listenForMessages(id: "conversation_\(finalEmail!)_\(finalOtherUserEmail!)", shouldScrollToButtom: true)
            print("id is nil")
        }
//        listenForMessages(id: "conversation_\(finalEmail!)_\(finalOtherUserEmail!)", shouldScrollToButtom: true)
        self.messagesCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        setbackButton()
        configuration()
        listenForMessages(id: "conversation_\(String(describing: finalEmail))_\(String(describing: finalOtherUserEmail))", shouldScrollToButtom: true)
        self.messagesCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        self.messagesCollectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 70, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        listenForMessages(id: "conversation_\(finalEmail!)_\(finalOtherUserEmail!)", shouldScrollToButtom: true)
        self.messagesCollectionView.reloadData()

    }
    
    //MARK: - Functions
    
    @objc private func backClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func callClicked(){
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber!)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func setDelegate(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func setbackButton(){
        
        let callButton = UIButton()
        callButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        callButton.frame.size = CGSize(width: 50, height: 50)
        callButton.layer.cornerRadius = 20
        callButton.backgroundColor = .systemGreen
        callButton.tintColor = .white
        callButton.addTarget(self, action: #selector(callClicked), for: .touchUpInside)
        let calBarButton = UIBarButtonItem(customView: callButton)


        let back = UIButton()
        back.setTitle("back", for: .normal)
        back.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        back.tintColor = .systemBlue
        back.setTitleColor(.systemBlue, for: .normal)
        back.tintColor = UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1)
        back.setTitleColor(UIColor(red: 0.839, green: 0.333, blue: 0.424, alpha: 1), for: .normal)
        back.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: back)
        
        navigationItem.leftBarButtonItem = barButton
        navigationItem.rightBarButtonItem = calBarButton
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.barTintColor = .white
        
        
//        navigationController?.navigationBar.layer.cornerRadius = 30
//        navigationController?.navigationBar.layer.masksToBounds = true
//        navigationController?.navigationBar.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = (navigationController?.navigationBar.frame)!
//        gradientLayer.colors =  [
//            UIColor(red: 0.102, green: 0.157, blue: 0.345, alpha: 1).cgColor,
//            UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
//        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0.98, c: -0.75, d: 1.6, tx: 0.38, ty: -0.77))
//        gradientLayer.bounds = (navigationController?.navigationBar.bounds.insetBy(dx: -0.5*(navigationController?.navigationBar.bounds.size.width)!, dy: -0.5*(navigationController?.navigationBar.bounds.size.height)!))!
//        gradientLayer.position = (navigationController?.navigationBar.center)!
//        navigationController?.navigationBar.layer.addSublayer(gradientLayer)
//        navigationController?.navigationBar.layer.insertSublayer(gradientLayer, at: 0)
//        navigationController?.navigationBar.barTintColor = .lightGray
        
        
    }
    
    private func configuration(){
        navigationItem.title = Name!
        let filteredEmail = self.centerEmail.replacingOccurrences(of: "@", with: "-")
        let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-")
        sender = Sender(senderId: finalEmail, displayName: centerName!)
    }
    
    
    private func listenForMessages(id: String, shouldScrollToButtom: Bool){
        print("conv id: \(id)")
        self.getAllMessagesForConversation(with: "\(id)/messages", completion: { result in
            switch result{
            case .success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self.messgaes = messages
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.messagesCollectionView.reloadData()
                    if shouldScrollToButtom{
                        self.messagesCollectionView.scrollToLastItem()
                        self.messagesCollectionView.reloadData()
                    }
                }
                self.messagesCollectionView.reloadData()
            case.failure(let error):
                print(error.localizedDescription)
            }
            self.messagesCollectionView.scrollToLastItem(animated: false)

        })
        messagesCollectionView.scrollToLastItem(animated: false)

        
    }
    
    
    private func setupLayout(){
        //1- background view
        containerView.layer.cornerRadius = 30
        containerView.layer.masksToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.frame
        gradientLayer.colors =  [
            UIColor(red: 0.102, green: 0.157, blue: 0.345, alpha: 1).cgColor,
            UIColor(red: 0.192, green: 0.353, blue: 0.584, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0.98, c: -0.75, d: 1.6, tx: 0.38, ty: -0.77))
        gradientLayer.bounds = containerView.bounds.insetBy(dx: -0.5*containerView.bounds.size.width, dy: -0.5*containerView.bounds.size.height)
        gradientLayer.position = containerView.center
        containerView.layer.addSublayer(gradientLayer)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        //2- call button
        callButton.layer.cornerRadius = callButton.frame.width/2
    }
    
    private func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        let filteredEmail = self.centerEmail.replacingOccurrences(of: "@", with: "-")
        let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-")
        let filteredOtherUserEmail = otherUserEmail.replacingOccurrences(of: "@", with: "-")
        let finalOtherUserEmail = filteredOtherUserEmail.replacingOccurrences(of: "@", with: "-")
        
        ref.child("\(finalEmail)").observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else{
                completion(false)
                print("user not found")
                return
            }
            
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
            
            let newConversationData:[String:Any] = ["id":"conversation_\(finalOtherUserEmail)_\(finalEmail)","otherUserEmail":"\(finalOtherUserEmail)","latest_message":["date":dateString, "message":message!,"is_read":false]]
            
            let recipient_newConversation:[String:Any] = ["id":"conversation_\(finalOtherUserEmail)_\(finalEmail)","otherUserEmail":"\(finalEmail)","latest_message":["date":dateString, "message":message!,"is_read":false]]
            
            self.ref.child("\(finalOtherUserEmail)/conversations").observeSingleEvent(of: .value) { snap in
                if var conversations = snap.value as? [[String: Any]]{
                    conversations.append(recipient_newConversation)
                    self.ref.child("\(finalOtherUserEmail)/conversations").setValue("conversation_\(finalOtherUserEmail)_\(finalEmail)")
                }else{
                    self.ref.child("\(finalOtherUserEmail)/conversations").setValue([recipient_newConversation])
                }
            }
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                // there exist a converstation for this user
                // append message to the conversation
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                self.ref.child("\(finalEmail)").setValue(userNode)
                self.finishCreatingConversation(conversationID: "conversation_\(finalEmail)_\(finalOtherUserEmail)", firstMessage: firstMessage, completion: completion)
            }else{
                //converstaion array dont exists , create it
                userNode["conversations"] = [newConversationData]
                self.ref.child("\(finalEmail)").setValue(userNode)
                self.finishCreatingConversation(conversationID: "conversation_\(finalEmail)_\(finalOtherUserEmail)", firstMessage: firstMessage, completion: completion)
            }
        }
        self.messagesCollectionView.reloadData()
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        
        let filteredEmail = self.centerEmail.replacingOccurrences(of: "@", with: "-")
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
        let value:[String: Any] = ["messages":[collectionMessage]]
        
        
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
        self.messagesCollectionView.reloadData()
    }
    
    private func getAllMessagesForConversation(with id:String, completion: @escaping (Result<[Message], Error>)-> Void){
        ref.child("\(id)").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                return
            }
            
            let messages: [Message] = value.compactMap { dictionary in
                guard let content = dictionary["content"] as? String, let date = dictionary["date"] as? String, let id = dictionary["id"] as? String, let _ = dictionary["is_read"] as? Bool, let senderEmail = dictionary["sender_email"] as? String, let _ = dictionary["type"] as? String? else{
                    return nil
                }
                
                let stringDate = self.dateFormatter.date(from: date)
                let sender = Sender(senderId: senderEmail, displayName: self.centerName!)
                return Message(sender: sender, messageId: id, sentDate: stringDate!, kind: .text(content))
                
            }
            
            completion(.success(messages))
        }
    }
    
    private func sendMessage(to conversation: String , otherUserEmail: String ,newMessage: Message, completion: @escaping (Bool)-> Void){
        //add new message to messages
        //update sender latest messages
        //update reciever latest messages
        self.ref.child("\(conversation)/messages").observeSingleEvent(of: .value) { snapshot in
            guard var currentMessages = snapshot.value as? [[String:Any]] else{
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = self.dateFormatter.string(from: messageDate)
            var message:String?
            
            switch newMessage.kind{
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
            
            
            let collectionMessage:[String: Any] = ["id":newMessage.messageId
                                                   ,"type":newMessage.kind.messageKindString,"content":message!,"date":dateString,"sender_email":self.finalEmail!,"is_read":false]
            currentMessages.append(collectionMessage)
            
            self.ref.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                
                self.ref.child("\(self.finalEmail!)/conversations").observeSingleEvent(of: .value) { snapshot in
                    guard var currentUserConversatiosns = snapshot.value as? [[String: Any]] else{
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String:Any] = ["date":dateString,"message":message!,"is_read":false]
                    var targetConversation:[String: Any]?
                    var position = 0
                    
                    for conversationDictionary in currentUserConversatiosns {
                        if let currentID = conversationDictionary["id"] as? String, currentID == conversation {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else{
                        completion(false)
                        return
                    }
                    currentUserConversatiosns[position] = finalConversation
                    self.ref.child("\(self.finalEmail!)/conversations").setValue(currentUserConversatiosns) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        self.ref.child("\(self.finalOtherUserEmail!)/conversations").observeSingleEvent(of: .value) { snapshot in
                            guard var othertUserConversatiosns = snapshot.value as? [[String: Any]] else{
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String:Any] = ["date":dateString,"message":message!,"is_read":false]
                            var targetConversation:[String: Any]?
                            var position = 0
                            
                            for conversationDictionary in othertUserConversatiosns {
                                if let currentID = conversationDictionary["id"] as? String, currentID == conversation {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else{
                                completion(false)
                                return
                            }
                            othertUserConversatiosns[position] = finalConversation
                            self.ref.child("\(self.finalOtherUserEmail!)/conversations").setValue(othertUserConversatiosns) { error, _ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func createMessageId() -> String{
        //date , otherUserEmail, senderEmail, randomInt
        let filteredEmail = self.centerEmail.replacingOccurrences(of: "@", with: "-")
        let finalEmail = filteredEmail.replacingOccurrences(of: ".", with: "-")
        let filteredOtherUserEmail = otherUserEmail.replacingOccurrences(of: "@", with: "-")
        let finalOtherUserEmail = filteredOtherUserEmail.replacingOccurrences(of: "@", with: "-")
        
        //        let dateString = self.dateFormatter.string(from: Date())
        let newIdentefier = "\(finalOtherUserEmail)_\(finalEmail)"
        print("created message id: \(newIdentefier)")
        return newIdentefier
    }
    
    //MARK: - @IBActions
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callRequester(_ sender: Any) {
        
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber!)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
}

//MARK: - MessagesDataSource Extensions
extension paramedicChatViewController: MessagesDataSource{
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
extension paramedicChatViewController: MessagesLayoutDelegate{
    
}

//MARK: - MessagesDisplayDelegate Extensions
extension paramedicChatViewController: MessagesDisplayDelegate{
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
}

//MARK: - MessagesDisplayDelegate Extensions
extension paramedicChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        
        print("sending: \(text)")
        let message = Message(sender: sender!, messageId: createMessageId(), sentDate: Date(), kind: .text(text))
        //send meesage
        if isNewConversation{
            //create converstaion in db
            self.createNewConversation(with: otherUserEmail, firstMessage: message) { success in
                if success{
                    print("message sent for new conv")
                    self.messagesCollectionView.reloadData()
//                    self.isNewConversation = false
                }else{
                    print("failed to sent for new conv")
                }
            }
            self.messagesCollectionView.reloadData()
        }else{
            //append to exsisting conversation in db
            guard let conversationId = converstationID else {
                return
            }
            sendMessage(to: conversationId, otherUserEmail: self.finalOtherUserEmail!, newMessage: message) { success in
                if success{
                    print("message sent")
                    self.messagesCollectionView.reloadData()
                }else{
                    print("failed to send")
                }
            }
            self.messagesCollectionView.reloadData()
            
        }
        inputBar.inputTextView.text = ""
    }
    
}
