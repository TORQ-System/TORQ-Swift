//
//  emergencyNumber.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 10/12/2021.
//

import Foundation

struct emergencyNumber {
    var name: String
    var phone: String
    
    init(name:String, phone: String){
        self.name = name
        self.phone = phone
    }
    
    func getName()-> String{
        return name
    }
    
    func getPhone()-> String{
        return phone
    }
}
