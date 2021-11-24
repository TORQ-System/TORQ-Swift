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
    var request_id: String
    var notification_id: String
    
    
    init(title: String, subtitle: String, body:String, date: String, time: String, type: String, sender: String, receiver: String, request_id: String, notification_id:String) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.type = type
        self.date = date
        self.sender = sender
        self.receiver = receiver
        self.time = time
        self.request_id = request_id
        self.notification_id = notification_id
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
    
    func getRequestID()-> String{
        return request_id
    }
    
    func getNotificationID()-> String{
        return notification_id
    }
    
}
