//
//  emergencyContact.swift
//  TORQ
//
//  Created by a w on 29/10/2021.
//

import Foundation

struct emergencyContact {
    var name: String
    var phone_number: String
    var senderID: String
    var recieverID: String
    var sent: String
    var contactID: Int
    var msg: String
    var relation: String

    init(name: String, phone_number: String, senderID: String, recieverID: String, sent: String, contactID: Int, msg: String, relation: String) {
        self.name = name
        self.phone_number = phone_number
        self.senderID = senderID
        self.recieverID = recieverID
        self.contactID = contactID
        self.msg = msg
        self.sent = sent
        self.relation = relation
    }

    func getName()->String{
        return name
    }

    func getPhoneNumber()->String{
        return phone_number
    }

    func getSenderID()->String{
        return senderID
    }

    func getReciverID()->String{
        return recieverID
    }

    func getContactID()->Int{
        return contactID
    }

    func getMsg()->String{
        return msg
    }

    func getSent()->String{
        return sent
    }

    func getRelation()->String{
        return relation
    }


}
