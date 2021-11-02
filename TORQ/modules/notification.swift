//
//  notification.swift
//  TORQ
//
//  Created by Norua Alsalem on 02/11/2021.
//

import Foundation

struct notification {
    
    var title: String
    var subtitle: String
    var body: String
    var date: String
    var time: String
    var type: String
    var sender: String
    var receiver: String

    
    init(title: String, subtitle: String, body:String, date: String, time: String, type: String, sender: String, receiver: String) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.type = type
        self.date = date
        self.sender = sender
        self.receiver = receiver
        self.time = time
    
}
    
    func getTitle()-> String{
        return title
    }
    
    func getSubtitle()-> String{
        return subtitle
    }
    
    func getBody()-> String{
        return body
    }
    
    func getType()-> String{
        return type
    }
    
    func getDate()-> String{
        return date
    }
    
    func getSender()-> String{
        return sender
    }
    
    func getReceiver()-> String{
        return receiver
    }
    
    func getTime()-> String{
        return time
    }
    
}
