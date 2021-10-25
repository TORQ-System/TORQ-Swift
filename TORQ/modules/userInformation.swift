//
//  userInformation.swift
//  TORQ
//
//  Created by a w on 25/10/2021.
//
import Foundation
struct userInformation {
    var dateOfBirth : String
    var email : String
    var fullName : String
    var gender : String
    var nationalID : String
    var password : String
    var phone : String
    
    init(fullName : String, email : String, password : String, nationalID : String, dateOfBirth : String,  phone : String ,gender : String) {
        self.fullName = fullName
        self.email = email
        self.password = password
        self.nationalID = nationalID
        self.dateOfBirth = dateOfBirth
        self.phone = phone
        self.gender = gender
    }
    func getUserFullName() -> String {
        return fullName
    }
    func getUserEmail() -> String {
        return email
    }
    func getPassword() -> String {
        return password
    }
    func getNationalID() -> String {
        return nationalID
    }
    func getPhone() -> String {
        return phone
    }
    func getGender() -> String {
        return gender
    }
    func getDOB() -> String {
        return dateOfBirth
    }
}
