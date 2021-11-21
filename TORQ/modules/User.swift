//
//  User.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 28/10/2021.
//

import Foundation


struct User: Hashable {
    var dateOfBirth: String
    var email: String
    var fullName: String
    var gender: String
    var nationalID: String
    var password: String
    var phone: String
    
    
    init(dateOfBirth: String, email: String, fullName: String, gender: String, nationalID: String, password: String, phone: String){
        self.dateOfBirth = dateOfBirth
        self.email = email
        self.fullName = fullName
        self.gender = gender
        self.nationalID = nationalID
        self.password = password
        self.phone = phone
    }
    
    func getDateOfBirth()-> String{
        return dateOfBirth
    }
    
    func getEmail()-> String{
        return email
    }
    
    func getFullName()-> String{
        return fullName
    }
    
    func getGender()-> String{
        return gender
    }
    
    func getNationalID()-> String{
        return nationalID
    }
    
    func getPassword()-> String{
        return password
    }
    
    func getPhone()-> String{
        return phone
    }
}
