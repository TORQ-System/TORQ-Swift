//
//  emergencyNumber.swift
//  TORQ
//
//  Created by a w on 01/12/2021.
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
