//
//  emergencyContact.swift
//  TORQ
//
//  Created by Norua Alsalem on 17/10/2021.
//

import Foundation
struct emergencyContact {
    var name: String
    var phone_number: String

    init(name: String, phone_number: String ) {
        self.name = name
        self.phone_number = phone_number

    }
    
    func getName()->String{
        return name
    }
    
    func getPhoneNumber()->String{
        return phone_number
    }

}
